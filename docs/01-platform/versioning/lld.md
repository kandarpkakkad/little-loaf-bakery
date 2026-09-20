# Versioning & distribution — LLD

## 1. Constants and files

**Source of truth: [`schema.md`](schema.md)** — the build constants, `app.json`, and the APK release file.

## 2. Gate, on launch and on resume

```dart
Future<GateResult> check() async {
  final remote = await drive.readJson('app.json').catchError((_) => null);
  final cfg = remote ?? cache.lastKnown;      // unreadable → cached; still null → carry on
  if (cfg == null) return GateResult.ok;

  if (remote != null) cache.store(remote);

  if (kAppVersion > (cfg.latestVersion ?? 0)) {
    await drive.writeJson('app.json', {
      latestVersion: kAppVersion, minSupportedVersion: kMinSupported,
      publishedAt: now, apkUrl: kApkUrl,
    });
    return GateResult.ok;
  }
  if (kAppVersion < cfg.minSupportedVersion) {
    await sync.flushOutbox();                 // nothing is lost by being locked out
    return GateResult.blocked(cfg);
  }
  if (kAppVersion < cfg.latestVersion) return GateResult.banner(cfg);
  return GateResult.ok;
}
```

**Order matters:** flush the outbox *before* showing the block. A device that is about to be
locked out still has work only it knows about.

## 3. Journal-level guard

```dart
// pull, per peer
if (header.minReaderVersion > kAppVersion) {
  peerState[peer] = PeerState.needsUpgrade;
  continue;                                   // this peer only; others still apply
}
```

Surfaced on Sync & backup as *"Counter is on a newer version — update to see its changes"*.
Our own uploads continue throughout, so the other device keeps receiving our work.

## 4. Publishing an update

Actions → **Release** → *Run workflow*, level `minor`. That is the whole of it.

The workflow bumps the version with `tool/bump_version.sh`, commits it, tags it, and builds
that one number twice — a debug APK and the signed release APK — so what you try and what you
ship are the same build. Bump `kMinSupported` **by hand, in a normal commit, only** if the
change is genuinely breaking; nothing moves it automatically, because it locks devices out.

Install on one device: it finds itself newer than `app.json` and writes the new floor there,
which is how the rest of the fleet learns. Android asks once to allow installs from the
browser; one toggle, and it persists.

**Every push to main bumps the patch**, so a debug APK always carries a version higher than
the last one. The bump commit is pushed with `GITHUB_TOKEN`, which by design does not trigger
another workflow run — and carries `[skip ci]` as well, so the loop is closed twice.

**The version lives in two files** — `pubspec.yaml` and `version.dart` — and a test fails the
build if they drift. `tool/bump_version.sh` moves both, verifies both took the edit, and only
ever increases the build number: Android refuses an APK whose `versionCode` is not higher than
the installed one, so a build number that went backwards would be an update nobody can
install.

## 5. Edge cases

| Case | Handling |
|---|---|
| `app.json` malformed | Treated as unreadable → cached → never blocks |
| Clock wrong, `published_at` in the future | Ignored; only version integers are compared |
| Two devices both newer than `latest_version` | Both write; last wins; the values are the same anyway |
| Downgrade installed deliberately | It sees `kAppVersion < min_supported` and blocks — correct |
| APK URL requires sign-in | Expected. The phone's browser is signed into the bakery account |

## 6. What to test

- Blocked path: outbox is **empty** by the time the block screen renders.
- Unreadable `app.json` (404, malformed, offline) → **no block**, in all three cases.
- Journal guard skips one peer and keeps applying the rest.
- Install over with the same keystore → database intact. With a different keystore → Android
  refuses, and the docs say why.
