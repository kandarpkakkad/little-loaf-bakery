#!/bin/bash
# Start a Little Loaf emulator the only way that renders correctly on this Intel Mac.
#
# -gpu swiftshader_indirect is required. The AVD has hw.gpu.mode=auto, and both
# Android Studio and `flutter emulators --launch` pick the host OpenGL path, which
# draws frames but never presents them: the window stays blank until you resize it.
# Only the command-line flag overrides it.
#
# Each AVD gets its own console port, so the phone and the tablet run side by
# side. adb auto-detects emulators on even ports 5554–5584, which is why the
# ports below are even and in that range — an odd or out-of-range port would
# start fine and never appear in `adb devices`.
#
# Safe to run repeatedly. If that device is already booted it exits straight away.
#
#   ./tool/start_emulator.sh                    # phone  → emulator-5554
#   ./tool/start_emulator.sh oneplus_pad_a16    # tablet → emulator-5556

set -u

SDK="/usr/local/share/android-commandlinetools"
AVD="${1:-pixel_9_a16}"
ADB="$SDK/platform-tools/adb"
EMULATOR="$SDK/emulator/emulator"

# One console port per AVD, fixed rather than allocated, so the serial for a
# given device is the same every run and scripts can hard-code it.
#
# GRPC is the part that is easy to miss. The emulator only starts its gRPC
# bridge on its own when it is on the *default* console port; pass -port and it
# quietly skips it. No bridge means no `pid_*.ini` in
# ~/Library/Caches/TemporaryItems/avd/running/, and that file is exactly how
# Android Studio discovers a device to embed — so the emulator runs, adb sees
# it, and Running Devices stays empty. Combined with EMBED=1 hiding the window,
# the device becomes invisible. Hence an explicit -grpc port for every AVD.
case "$AVD" in
  pixel_9_a16)     PORT=5554; GRPC=8554 ;;
  oneplus_pad_a16) PORT=5556; GRPC=8556 ;;
  *)               PORT="${PORT:-5558}"; GRPC="${GRPC:-8558}" ;;
esac

SERIAL="emulator-$PORT"
LOG="/tmp/emu-$AVD.log"

# Every adb call is pinned to this device. Without -s, adb refuses to guess once
# a second emulator is up: "adb: more than one device/emulator".
adb_() { "$ADB" -s "$SERIAL" "$@"; }

booted() {
  [ "$(adb_ shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ] &&
  [ "$(adb_ shell getprop init.svc.bootanim 2>/dev/null | tr -d '\r')" = "stopped" ]
}

if booted; then
  echo "$AVD is already up on $SERIAL — Android $(adb_ shell getprop ro.build.version.release | tr -d '\r'). Nothing to do."
  exit 0
fi

# EMBED=1 hides the emulator's own window so it shows up only inside Android
# Studio's "Running Devices" tool window. Without it you get a standalone window.
# Either way the emulator advertises a gRPC endpoint under
# ~/Library/Caches/TemporaryItems/avd/running/, which is how Studio discovers it.
EXTRA=()
if [ "${EMBED:-0}" = "1" ]; then
  EXTRA+=(-qt-hide-window)
fi

if ! pgrep -f "qemu-system.*$AVD" >/dev/null; then
  echo "Starting $AVD — console $PORT, gRPC $GRPC${EMBED:+, window hidden for the IDE}..."
  # ${EXTRA[@]+...} rather than "${EXTRA[@]}": macOS bash 3.2 treats an empty
  # array as unbound under `set -u`, which killed this subshell silently and
  # left the script waiting for a boot that was never coming.
  # -grpc-use-token keeps the bridge authenticated. Without it -grpc opens an
  # unprotected port, which the emulator warns about.
  nohup "$EMULATOR" -avd "$AVD" -port "$PORT" -grpc "$GRPC" -grpc-use-token \
    -gpu swiftshader_indirect ${EXTRA[@]+"${EXTRA[@]}"} > "$LOG" 2>&1 &
  disown
else
  echo "$AVD is running but has not finished booting."
fi

# Boot is slow here (~80s idle, several minutes if a Gradle build or the other
# emulator is competing for CPU). Waiting matters: adb reports "device" well
# before the package manager exists, and installing into that window fails with
# "Can't find service: package".
echo "Waiting for boot to complete..."
for i in $(seq 1 180); do
  if booted; then
    echo
    echo "READY after $((i * 5))s — $AVD on $SERIAL, Android $(adb_ shell getprop ro.build.version.release | tr -d '\r')"
    grep -o 'gles_mode_selected:[a-z]*' "$LOG" | head -1 | sed 's/^/graphics: /'
    # If this is missing, Android Studio cannot embed the device no matter what
    # EMBED is set to — see the -grpc note above.
    if grep -q 'Advertising in:' "$LOG"; then
      echo "discoverable by Android Studio: yes (gRPC $GRPC)"
    else
      echo "discoverable by Android Studio: NO — Running Devices will stay empty"
    fi
    echo
    echo "Run the app on this one with:"
    echo "  flutter run --release -d $SERIAL"
    echo "In Android Studio, pick it in the device dropdown before pressing play."
    exit 0
  fi
  printf '.'
  sleep 5
done

echo
echo "Still not booted after 15 minutes. Check $LOG and host load with 'uptime'."
exit 1
