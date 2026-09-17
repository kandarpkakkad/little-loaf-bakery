# Versioning — schema

No tables. One Drive artefact and the build constants.

## `app.json`

```jsonc
{
  "latest_version":        14,
  "min_supported_version": 12,
  "published_at":          "2026-08-27T09:00:00Z",
  "apk_url":               "https://drive.google.com/uc?export=download&id=<file-id>"
}
```

| Field | Rules |
|---|---|
| `latest_version` | Written by whichever app finds its own version higher. Drives the update banner |
| `min_supported_version` | **Below this → hard block.** Bumped only when a change makes older builds unable to read what this one writes |
| `apk_url` | Optional. Absent → the block screen drops its Download button |
| — | **Unreadable or missing file never blocks.** Cached values are used |

Nobody hand-edits this. The newest app writes it.

## Build constants

```dart
const int kAppVersion       = 14;
const int kMinSupported     = 12;   // written into app.json
const int kSchemaVersion    = 7;    // storage
const int kMinReaderVersion = 12;   // written into our journal header
const String kApkUrl = 'https://drive.google.com/uc?export=download&id=<file-id>';
```

`kMinSupported` and `kMinReaderVersion` are the two numbers that lock devices out. Move them
only for a genuine incompatibility.

## `releases/little-loaf.apk`

**One file, replaced in place** — *Manage versions → Upload new version*, never a new upload.
A Drive download URL contains the file id, and that URL is baked into the build, so a new file
each release would need the address of an APK that does not exist yet (D24).

Drive keeps 30 days of prior versions, which is a free rollback.
