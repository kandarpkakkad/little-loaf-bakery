#!/bin/bash
# Build, install and approve the WhatsApp stub on every running emulator.
#
# Why a stub and not the real WhatsApp: the AVDs are google_apis images, so they
# have no Play Store, and WhatsApp ships ARM-only native libraries that will not
# run on these x86_64 images. Signing in would also need a real number and an SMS
# code. None of that is what we are testing — the question is only whether
# Little Loaf builds the right wa.me link and hands it over, so this app claims
# the same links and prints what it receives.
#
# Installs to every attached emulator, because the phone and the tablet each
# need their own copy and their own link approval.
#
# Safe to re-run. Takes about a minute the first time, seconds after that.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SDK="/usr/local/share/android-commandlinetools"
ADB="$SDK/platform-tools/adb"
PKG="com.littleloaf.whatsappstub"
APK="$HERE/whatsapp_stub/app/build/outputs/apk/debug/app-debug.apk"
DOMAINS="wa.me api.whatsapp.com chat.whatsapp.com"

# Column 1 of `adb devices`, skipping the header and anything not ready.
# Written as a read loop rather than `mapfile` because macOS ships bash 3.2,
# where mapfile does not exist.
DEVICES=""
while read -r serial; do
  [ -n "$serial" ] && DEVICES="$DEVICES $serial"
done < <("$ADB" devices | awk '$2 == "device" { print $1 }')
DEVICES="${DEVICES# }"

if [ -z "$DEVICES" ]; then
  echo "No booted emulator. Run tool/start_emulator.sh first." >&2
  exit 1
fi

echo "Building the stub..."
(cd "$HERE/whatsapp_stub" && ./gradlew :app:assembleDebug -q)

for serial in $DEVICES; do
  name=$("$ADB" -s "$serial" emu avd name 2>/dev/null | head -1 | tr -d '\r' || true)
  echo
  echo "── $serial ${name:+($name)}"

  if [ "$("$ADB" -s "$serial" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]; then
    echo "   still booting — skipped"
    continue
  fi

  echo "   installing..."
  "$ADB" -s "$serial" install -r "$APK" > /dev/null

  # Without this Chrome wins the link. On a phone WhatsApp is the verified owner
  # of wa.me; the stub cannot verify a domain it does not own, so we approve it
  # by hand. Both commands are needed: the first sets the verification state,
  # the second the user's choice for this profile.
  echo "   approving $DOMAINS..."
  "$ADB" -s "$serial" shell "pm set-app-links --package $PKG 2 $DOMAINS" || true
  "$ADB" -s "$serial" shell "pm set-app-links-user-selection --user 0 --package $PKG true $DOMAINS" || true

  "$ADB" -s "$serial" shell "pm get-app-links $PKG" \
    | tr -d '\r' | sed -n '/Domain verification state/,$p' | sed 's/^/   /'
done

echo
echo "Done. Open an order in Little Loaf and tap a WhatsApp action."
echo "To check one device without the app:"
echo "  $ADB -s ${DEVICES%% *} shell am start -a android.intent.action.VIEW \\"
echo "    -d 'https://wa.me/919876543210?text=hello'"
