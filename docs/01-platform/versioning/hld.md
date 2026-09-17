# Versioning & distribution — HLD

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
The APK lives at `releases/little-loaf.apk`, **replaced in place** — never a new file, because
a Drive download URL contains the file id and that URL is baked into the build (D24). Sharing
stays off; every device is signed into the account that can read it. Drive keeps 30 days of
prior versions, which is a free rollback.

## Failure modes
| Failure | Behaviour |
|---|---|
| A build sets `min_supported_version` too high | Every device blocks. **The block screen always carries the update link and Restore from backup** |
| Signing key changed | Android refuses to install over; an uninstall would delete the database. The keystore is the single most important file to back up |
| Download link dead | Block screen falls back to "install from the file you were sent" |

## Non-goals
No in-app update download or install. No Play Store. No staged rollout.
