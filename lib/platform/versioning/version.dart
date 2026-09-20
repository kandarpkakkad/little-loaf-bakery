/// What this build is, and the oldest build it can still talk to.
///
/// Kept here as constants rather than read from the package at runtime: the
/// gate has to work in a background isolate and before anything is initialised,
/// and a version that cannot be read is a version that cannot block. A test
/// asserts these match `pubspec.yaml`, so they cannot drift.
/// docs/01-platform/versioning/schema.md
library;

/// Matches `version:` in pubspec.yaml, and the release tag without its `v`.
const String kAppVersion = '0.2.3';

/// The build number after the `+`.
const int kAppBuild = 19;

/// The oldest version that can still read what this build writes.
///
/// Moving this locks every older device out of the app entirely, so it moves
/// only for a genuine incompatibility — not for a feature, and not for a
/// schema change that migrates cleanly.
const String kMinSupported = '0.1.0';

/// Where the app looks for what the newest release is.
const String kReleasesApi =
    'https://api.github.com/repos/kandarpkakkad/little-loaf-bakery/releases/latest';

const String kReleasesPage =
    'https://github.com/kandarpkakkad/little-loaf-bakery/releases/latest';

/// Compares two `major.minor.patch` strings.
///
/// Negative if [a] is older, zero if they are the same, positive if newer. A
/// missing or unparseable part counts as 0, so `0.1` and `0.1.0` are equal and
/// a tag like `v0.2.0` works once the `v` is off it.
int compareVersions(String a, String b) {
  final left = _parts(a);
  final right = _parts(b);
  for (var i = 0; i < 3; i++) {
    final d = left[i] - right[i];
    if (d != 0) return d;
  }
  return 0;
}

bool isOlder(String a, String b) => compareVersions(a, b) < 0;

List<int> _parts(String v) {
  // Tolerates a leading `v`, a `+build` suffix, and a `-rc1` suffix, because
  // all three turn up in tag names and none of them change the ordering here.
  final cleaned = v.trim().replaceFirst(RegExp('^[vV]'), '').split(RegExp('[+-]')).first;
  final bits = cleaned.split('.');
  return [
    for (var i = 0; i < 3; i++)
      i < bits.length ? (int.tryParse(bits[i].trim()) ?? 0) : 0,
  ];
}
