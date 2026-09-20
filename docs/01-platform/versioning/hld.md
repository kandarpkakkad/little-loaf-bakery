# Versioning & distribution — HLD


Built — `lib/platform/versioning/`, the block screen and banner in
`ui/shell/update_gate.dart`, 18 tests.

**The gate reads two sources, not one.** Distribution moved to GitHub
Releases, so that is where "what is the newest build" is answered — and it
answers for a device that has never connected Drive. But a GitHub release has
nowhere to carry `min_supported_version`, so the floor still lives in
`app.json` beside the journals. The gate merges them: the newer `latest`, and
the stricter floor either one names. One source being unreachable loses only
what that source knew.

Versions are **semver strings** rather than integers, because the release tag
is the version and the tag is `v0.1.1`. `v`, a `+build` suffix and an `-rc`
suffix all compare equal to the bare version, so a tag and a pubspec line are
the same thing to the comparator.

`app.json` sits at the **root** of the shared folder, beside `journal/` and
`snapshot/`: it is a fact about the app, not about one device's ops.

**Somebody has to go first.** When no source answers — no `app.json` yet, and a
GitHub source that cannot answer — this build counts as the newest by default
and writes `app.json` itself. Without that the file is never created, so it
never answers, so nothing ever finds itself newer than it: a closed loop with
no floor anywhere in it.

**While the repository is private the GitHub source never answers**, because an
unauthenticated call to a private repo's release API is a 404 and a 404 is "no
answer". The gate still works — `app.json` carries both numbers — but `latest`
then tracks *the newest installed device*, not the newest published release,
and the download link on the block screen asks for a GitHub sign-in. Making the
repository public is what turns the second source on.

## Purpose
Let devices run different versions safely, force an upgrade when they cannot, and get the APK
onto a phone without a store.

## Two independent mechanisms

| | Scope | Automatic? |
|---|---|---|
| **`min_reader_version`** on a journal | One peer's ops | Yes — stop applying *that journal* |
| **`min_supported_version`** in `app.json` | The whole app | Yes — hard block the app |

A breaking schema change usually bumps both: the journal guard stops bad reads immediately,
the version gate makes sure nobody stays on the old build.

## Three sources, not two

| Source | Answers | Carries a floor? |
|---|---|---|
| **GitHub Releases** | what has been *published* | No — a release has nowhere to put one |
| **`app.json`** in Drive | what the release pipeline announced | Yes |
| **peers' `device.json`** | what is actually *installed* around here | Yes — the strictest any peer asks for |

The third needs no new file and no extra read: `device.json` is already written on every sync
and already read from every peer on every sync, so the version rides along for free. It is
also the one that cannot go stale, because a device rewrites it every time it syncs — and it
answers the question the other two cannot, which is not "what exists" but "what is this
bakery actually running".

A newer build therefore propagates its own `kMinSupported` simply by syncing once.

## `app.json`
```jsonc
{ "latest_version": 14, "min_supported_version": 12,
  "published_at": "2026-08-27T09:00:00Z", "apk_url": "https://…" }
```
Written by whichever app finds its own version higher than `latest_version`. **Nobody
hand-edits JSON in Drive.**

| Case | Behaviour |
|---|---|
| Below `min_supported_version` | **Hard block** (S29). Outbox flushed first, so nothing is lost |
| Below `latest_version` | Dismissible banner |
| `app.json` unreadable or missing | **Never blocks.** Cached values used |
| `apk_url` missing | Block screen drops its Download button |

**Unreadable never blocks** is the rule that keeps an offline-first app from locking you out
because Drive hiccuped.

## Distribution
**GitHub Releases**, published by the tag-driven pipeline: pushing `v0.1.2` builds, signs,
verifies the signature and uploads `little-loaf-v0.1.2-arm64.apk` and the arm32 build. The
banner and the block screen link to the arm64 asset — arm32 exists for one old tablet and is
not what an update prompt should hand out.

This supersedes D24's Drive-hosted APK. The reason D24 existed — a Drive download URL contains
a file id, so a new file each release would need the address of an APK that does not exist yet
— does not apply to a release page whose URL is `/releases/latest`.

## Failure modes
| Failure | Behaviour |
|---|---|
| A build sets `min_supported_version` too high | Every device blocks. **The block screen always carries the update link and Restore from backup** |
| Signing key changed | Android refuses to install over; an uninstall would delete the database. The keystore is the single most important file to back up |
| Download link dead | Block screen falls back to "install from the file you were sent" |

## Non-goals
No in-app update download or install. No Play Store. No staged rollout.
