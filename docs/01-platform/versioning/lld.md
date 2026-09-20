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

**The pipeline never asks anyone for consent, and cannot.** There is no browser on a runner
and nobody watching it. The two halves happen at different times, and only one of them
involves a person:

| | Who | How often | What comes out |
|---|---|---|---|
| **Consent** | you, in a browser on your Mac | once | a refresh token |
| **Exchange** | the runner, machine to machine | every release | an access token, good for an hour |

A refresh token *is* the durable receipt of that one consent — that is the entire purpose of
asking for `access_type=offline`. The runner posts it to Google with `grant_type=refresh_token`
and gets back a short-lived access token. No browser, no prompt, nothing interactive.

So the answer to "shouldn't that be automatic?" is: it is, after one human act — the same
shape as the signing keystore, which you also produced once and handed to CI as a secret.

**The one thing that breaks the "once".** While the OAuth consent screen is in **Testing**,
Google expires refresh tokens after seven days, which would turn a one-time act into a weekly
chore. Setting the consent screen to **In production** stops it. Because `drive.file` is a
non-sensitive scope, publishing needs no verification review from Google — the app already
depends on that being true for its own sign-in. Publishing fixes both at once: the pipeline's
credential, and the devices' `silentToken()` dropping out every seven days.


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

```bash
# Cloud console → Credentials → the Web client → Authorised redirect URIs
#   add:  http://localhost:8765/
tool/mint_refresh_token.py
```

It reads the Web client out of `secrets/`, **refuses if it is not the one the app ships as
`kServerClientId`** — a token for the wrong project works perfectly and sees nothing, which is
the kind of failure you find out about during a release — opens a browser, catches the code on
localhost, and sets all three repository secrets with `gh`. The token is never pasted anywhere
and nothing is written to disk. Remove the redirect URI afterwards if you like.

It then **checks the token can actually see the app's Drive folder**, because the whole
approach rests on `drive.file` treating the Cloud project as "the app" rather than the
individual client. If that assumption is wrong, this is where it surfaces — not in a release
that silently announces nothing.

Google's OAuth Playground would do the same job, but it wants the client secret pasted into a
web page, and there is no reason to send it anywhere.

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
