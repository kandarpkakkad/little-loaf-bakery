#!/usr/bin/env bash
# Moves the version, in both places that hold it.
#
#   tool/bump_version.sh patch     0.1.1+2 -> 0.1.2+3
#   tool/bump_version.sh minor     0.1.1+2 -> 0.2.0+3
#   tool/bump_version.sh set 0.3.0 0.1.1+2 -> 0.3.0+3
#
# pubspec.yaml and lib/platform/versioning/version.dart must always agree: the
# update gate compares against the constant, and a test fails the build if the
# two drift. So they move together or not at all — never edit one by hand.
#
# Prints the new version to stdout. docs/01-platform/versioning/schema.md
set -euo pipefail

cd "$(dirname "$0")/.."

PUBSPEC=pubspec.yaml
CONSTANTS=lib/platform/versioning/version.dart

level="${1:?usage: bump_version.sh <patch|minor|major|set> [version]}"

current="$(grep -E '^version:' "$PUBSPEC" | head -1 | sed -E 's/^version:[[:space:]]*//')"
semver="${current%%+*}"
build="${current##*+}"

IFS=. read -r major minor patch <<<"$semver"

case "$level" in
  patch) patch=$((patch + 1)) ;;
  minor) minor=$((minor + 1)); patch=0 ;;
  major) major=$((major + 1)); minor=0; patch=0 ;;
  set)
    next="${2:?set needs a version, e.g. 0.3.0}"
    next="${next#v}"                       # a tag is fine too
    IFS=. read -r major minor patch <<<"$next"
    ;;
  *) echo "unknown level: $level" >&2; exit 1 ;;
esac

# The build number only ever goes up, whatever happens to the semver. Android
# refuses to install an APK whose versionCode is not higher than the one on the
# phone, so a build number that went backwards would be an update nobody can
# install.
build=$((build + 1))

version="$major.$minor.$patch"

perl -pi -e "s/^version:.*\$/version: $version+$build/" "$PUBSPEC"
perl -pi -e "s/^const String kAppVersion = '.*';\$/const String kAppVersion = '$version';/" "$CONSTANTS"
perl -pi -e "s/^const int kAppBuild = .*;\$/const int kAppBuild = $build;/" "$CONSTANTS"

# Proves the edit landed, rather than trusting that the regexes matched. A
# silent no-op here would ship an APK named after a version the app does not
# believe it is.
grep -q "^version: $version+$build\$" "$PUBSPEC" \
  || { echo "pubspec.yaml did not take the new version" >&2; exit 1; }
grep -q "^const String kAppVersion = '$version';\$" "$CONSTANTS" \
  || { echo "$CONSTANTS did not take the new version" >&2; exit 1; }

echo "$version"
