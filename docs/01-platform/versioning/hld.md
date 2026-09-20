# Versioning & distribution — HLD


Built — `lib/platform/versioning/`, the block screen and banner in
`ui/shell/update_gate.dart`, 18 tests.

**The gate reads two sources.** Distribution is GitHub Releases, so that is
where "what is the newest build" is answered — and because the repository is
public it answers for any device, including one that has never connected
Drive, with a download link that resolves without a sign-in. A GitHub release
has nowhere to carry `min_supported_version`, so the floor comes from the peers
instead: every device publishes its own version and its own floor in the
`device.json` it already writes on every sync.

Versions are **semver strings** rather than integers, because the release tag
is the version and the tag is `v0.1.1`. `v`, a `+build` suffix and an `-rc`
suffix all compare equal to the bare version, so a tag and a pubspec line are
the same thing to the comparator.

Were the repository private again, an unauthenticated call to the release API
would be a 404, a 404 is "no answer", and the gate would fall back to the peers
alone — still correct, but with `latest` tracking the newest *installed* device
rather than the newest published release.

## Purpose
Let devices run different versions safely, force an upgrade when they cannot, and get the APK
onto a phone without a store.

## Two independent mechanisms

| | Scope | Automatic? |
|---|---|---|
| **`min_reader_version`** on a journal | One peer's ops | Yes — stop applying *that journal* |
| **`min_supported`** in a peer's `device.json` | The whole app | Yes — hard block the app |

A breaking schema change usually bumps both: the journal guard stops bad reads immediately,
the version gate makes sure nobody stays on the old build.

## Two sources

| Source | Answers | Carries a floor? |
|---|---|---|
| **GitHub Releases** | what has been *published* | No — a release has nowhere to put one |
| **peers' `device.json`** | what is actually *installed* around here | Yes — the strictest any peer asks for |

`device.json` is already written on every sync and already read from every peer on every sync,
so the version rides along for free. It cannot go stale, because a device rewrites it every
time it syncs — and it answers the question GitHub cannot, which is not "what exists" but
"what is this bakery actually running". A newer build propagates its own `kMinSupported`
simply by syncing once.

**There was a third, and it was removed.** `app.json`, written into Drive by the release
pipeline, would have announced a floor the moment CI published — *before any device had
upgraded*. Raising `kMinSupported` would then have blocked every device at once, over an
incompatibility that had not happened yet, leaving the bakery locked out of its own order book
until each device was updated by hand. A floor carried by the peers rises only as devices
actually move, which is when the incompatibility becomes real. Dropping it also removed a
long-lived Google credential from CI, and with it the seven-day refresh-token expiry that
would have had to be nursed.

## The verdict

| Case | Behaviour |
|---|---|
| Below the strictest peer's `min_supported` | **Hard block** (S29). Outbox flushed first, so nothing is lost |
| Below the newest release | Dismissible banner, once per launch |
| No source answered | **Never blocks.** The last cached answer is used, then nothing |
| No APK link | Block screen falls back to the releases page, which is always there |

**Unreadable never blocks** is the rule that keeps an offline-first app from locking you out
because Drive or GitHub hiccuped. A device told to upgrade stays told, because the last answer
is cached — but an answer that never came is not an answer.

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
