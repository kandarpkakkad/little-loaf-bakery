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

The pipeline then writes `app.json` in Drive itself (`tool/publish_app_json.py`), so devices
hear about the build on their next sync rather than waiting for somebody to install it. If the
Drive secrets are not set the step is skipped with a notice, and the first device to install
the new build announces it instead — the same as before. Android asks once to allow installs from the
browser; one toggle, and it persists.

**Every push to main bumps the patch**, so a debug APK always carries a version higher than
the last one. The bump commit is pushed with `GITHUB_TOKEN`, which by design does not trigger
another workflow run — and carries `[skip ci]` as well, so the loop is closed twice.

**The version lives in two files** — `pubspec.yaml` and `version.dart` — and a test fails the
build if they drift. `tool/bump_version.sh` moves both, verifies both took the edit, and only
ever increases the build number: Android refuses an APK whose `versionCode` is not higher than
the installed one, so a build number that went backwards would be an update nobody can
install.

## 4b. The Drive credential, once

The release runner has no Google account of its own, so it borrows one. Three repository
secrets, all from the **same Cloud project as the app** — `drive.file` grants access to files
the *app* created, and the app is the project rather than any one client in it, which is the
only reason a Web client can touch a folder the Android client made.

| Secret | What |
|---|---|
| `GOOGLE_CLIENT_ID` | The **Web** OAuth client — the same one the app passes as `serverClientId` |
| `GOOGLE_CLIENT_SECRET` | Its secret, from the Cloud console |
| `GOOGLE_REFRESH_TOKEN` | A refresh token for the bakery account, scoped `drive.file` |

Getting the refresh token, once:

1. In the Cloud console, add `https://developers.google.com/oauthplayground` as an authorised
   redirect URI on the Web client.
2. Open the OAuth Playground → the gear icon → *Use your own OAuth credentials*, and paste the
   client id and secret.
3. Step 1: enter the scope `https://www.googleapis.com/auth/drive.file`. Authorise as the
   bakery account.
4. Step 2: *Exchange authorisation code for tokens*. Copy the **refresh token**.
5. Put all three in GitHub → Settings → Secrets and variables → Actions.
6. Remove the Playground redirect URI again.

**While the OAuth project is in Testing, Google expires refresh tokens after seven days.**
The release will then fail at the announcement step with a clear message, and the fix is to
repeat the steps above — or to publish the consent screen, which stops the expiry.

## 5. Edge cases

| Case | Handling |
|---|---|
| `app.json` malformed | Treated as unreadable → cached → never blocks |
| Clock wrong, `published_at` in the future | Ignored; only version integers are compared |
| Two devices both newer than `latest_version` | Both write; last wins; the values are the same anyway |
| Downgrade installed deliberately | It sees `kAppVersion < min_supported` and blocks — correct |
| APK URL requires sign-in | **While the repository is private this is a GitHub sign-in, not a Google one**, and the bakery account is unlikely to have one. The block screen still shows the link; installing the APK by hand is the fallback it names |
| Drive secrets missing or expired | The announcement step skips (missing) or fails loudly (expired). The release is already published either way, and a device that installs it still announces the version |

## 6. What to test

- Blocked path: outbox is **empty** by the time the block screen renders.
- Unreadable `app.json` (404, malformed, offline) → **no block**, in all three cases.
- Journal guard skips one peer and keeps applying the rest.
- Install over with the same keystore → database intact. With a different keystore → Android
  refuses, and the docs say why.
