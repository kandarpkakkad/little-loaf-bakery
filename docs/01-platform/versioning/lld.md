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

1. Bump `kAppVersion`. Bump `kMinSupported` **only** if genuinely breaking.
2. Build a signed release APK **with the same keystore as always**.
3. In Drive: right-click `releases/little-loaf.apk` → **Manage versions → Upload new version**.
   Never "upload a new file" — a new file gets a new id and the baked-in URL breaks.
4. Install on one device (it writes `app.json`), then the rest.

Android asks once to allow installs from the browser. One toggle, persists.

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
