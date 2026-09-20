# Versioning — schema

No tables. One Drive artefact and the build constants.

## Where the numbers come from

No Drive artefact of its own. The two the gate reads are:

| | Where | Shape |
|---|---|---|
| Newest release | GitHub Releases API | the tag, e.g. `v0.1.2`, plus the arm64 asset URL |
| The floor | each peer's `journal/<device-id>/device.json` | `app_version` and `min_supported`, written on every sync |

Versions are semver **strings**, matching the release tag. `v0.1.2`, `0.1.2` and `0.1.2+7`
all compare equal.

## Build constants

`lib/platform/versioning/version.dart`:

```dart
const String kAppVersion   = '0.1.1';   // matches pubspec, and the tag without its v
const int    kAppBuild     = 2;
const String kMinSupported = '0.1.0';   // published in this device's device.json
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
