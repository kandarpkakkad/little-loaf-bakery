# Versioning — schema

No tables. One Drive artefact and the build constants.

## `app.json`

At the **root** of the shared folder, beside `journal/` and `snapshot/` — it is a fact about
the app, not about one device's ops.

```jsonc
{
  "latest_version":        "0.1.2",
  "min_supported_version": "0.1.0",
  "published_at":          "2026-08-27T09:00:00Z",
  "apk_url":               "https://github.com/…/little-loaf-v0.1.2-arm64.apk"
}
```

Versions are semver **strings**, matching the release tag. `v0.1.2`, `0.1.2` and `0.1.2+7`
all compare equal.

| Field | Rules |
|---|---|
| `latest_version` | Written by whichever app finds its own version higher. Drives the update banner |
| `min_supported_version` | **Below this → hard block.** Bumped only when a change makes older builds unable to read what this one writes |
| `apk_url` | Optional. Absent → the block screen drops its Download button |
| — | **Unreadable or missing file never blocks.** Cached values are used |

Nobody hand-edits this. The newest app writes it.

## Build constants

`lib/platform/versioning/version.dart`:

```dart
const String kAppVersion   = '0.1.1';   // matches pubspec, and the tag without its v
const int    kAppBuild     = 2;
const String kMinSupported = '0.1.0';   // written into app.json
```

Constants rather than read from the package at runtime: the gate has to work before anything
is initialised, and a version that cannot be read is a version that cannot block. A test
asserts they match `pubspec.yaml`, so they cannot drift — and that `kMinSupported` is not
newer than `kAppVersion`, which would block every device including the one that wrote it.

Elsewhere: `kSchemaVersion` (storage) and `SyncEngine.kMinReaderVersion` (journal header) are
separate numbers with separate jobs.

`kMinSupported` and `kMinReaderVersion` are the two numbers that lock devices out. Move them
only for a genuine incompatibility.

## The APK

**GitHub Releases**, one per tag, built and signed by `.github/workflows/release.yml`. Every
release keeps its own assets, so any prior version is still installable — a better rollback
than the 30 days D24 was buying from Drive.
