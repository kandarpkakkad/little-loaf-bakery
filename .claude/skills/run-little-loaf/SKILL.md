---
name: run-little-loaf
description: Build, install and run the Little Loaf Bakery Flutter app on the Android emulator on this Mac. Use when asked to run the app, test it on the emulator, rebuild after code changes, or when the emulator shows a blank/black/frozen screen. Also covers running from Android Studio (which run configuration to pick) and the Intel-Mac graphics problem that makes the emulator look broken when it is not.
---

# Running Little Loaf on the emulator

Everything here is verified on this machine (Intel Mac, macOS 26). Commands are
written to be copied and pasted whole. You do not need to know Flutter.

## The three facts everything depends on

| | |
|---|---|
| Project | `/Users/mac/Downloads/GitHub/litte-loaf-bakery` |
| Phone AVD | `pixel_9_a16` — Android 16, SDK 36, 1080×2424 @420dpi, 4 GB RAM |
| Tablet AVD | `oneplus_pad_a16` — Android 16, SDK 36, 2000×2800 @320dpi (1000dp portrait / 1400dp landscape), 4 GB RAM |
| Android SDK | `/usr/local/share/android-commandlinetools` |

Both AVDs run the same Android 16 x86_64 image, and **both can run at once**:
each has its own console port, so they get distinct adb serials.

| AVD | Console port | gRPC port | Serial |
|---|---|---|---|
| `pixel_9_a16` | 5554 | 8554 | `emulator-5554` |
| `oneplus_pad_a16` | 5556 | 8556 | `emulator-5556` |

Console ports must be **even and within 5554–5584** — that is the range adb
scans. An odd or out-of-range port starts fine and then never shows up in
`adb devices`.

**The gRPC port is not optional once you pass `-port`.** The emulator starts its
gRPC bridge by itself only on the default console port; give it any other port
and it silently skips it. See *Running Devices stays empty* below — this is the
one that wastes an afternoon.

With two devices attached, every `adb` command needs `-s <serial>` or it refuses
with "more than one device/emulator", and `flutter run` needs `-d <serial>`.

The tablet exists to exercise the ≥840dp layout: navigation rail instead of the
bottom bar, and Orders as two panes. Both of its orientations are past that
breakpoint, so the tablet layout shows either way up.

## Start the emulator

**Use this exact command. The `-gpu` part is not optional.**

```bash
# phone
/usr/local/share/android-commandlinetools/emulator/emulator \
  -avd pixel_9_a16 -port 5554 -gpu swiftshader_indirect > /tmp/emu-phone.log 2>&1 &

# tablet — note the explicit -grpc, without which Studio cannot embed it
/usr/local/share/android-commandlinetools/emulator/emulator \
  -avd oneplus_pad_a16 -port 5556 -grpc 8556 -grpc-use-token \
  -gpu swiftshader_indirect > /tmp/emu-tablet.log 2>&1 &
```

The `> /tmp/emu.log 2>&1` part keeps the emulator's own messages out of your
terminal and puts them in a file, which the troubleshooting steps below read.

The `&` at the end lets you keep using the same terminal.

Or run the wrapper, which does the same thing and then waits for boot instead of
leaving you to guess when the device is ready:

```bash
cd /Users/mac/Downloads/GitHub/litte-loaf-bakery
./tool/start_emulator.sh                    # phone  → emulator-5554
./tool/start_emulator.sh oneplus_pad_a16    # tablet → emulator-5556
```

Run both if you want both. Each invocation only waits for its own device, and
exits straight away if that one is already booted.

Do **not** start it with `flutter emulators --launch pixel_9_a16`. That works,
but it cannot pass `-gpu`, and without that flag the emulator renders through
the Mac's graphics driver and the screen goes blank after every tap. This was
diagnosed on 28 Aug 2026; see *Blank screen* below for the full reason.

Wait for the Android home screen to appear. First start after a shutdown is slow
(a minute or more) because there is no saved snapshot.

## Run the app

```bash
cd /Users/mac/Downloads/GitHub/litte-loaf-bakery
flutter run --release                       # only when one emulator is up
flutter run --release -d emulator-5554      # phone
flutter run --release -d emulator-5556      # tablet
```

`--release` is much faster on this emulator and is the right choice for
click-through testing. Use plain `flutter run` only if you want hot reload —
it is noticeably slower and prints "Skipped N frames" warnings that are normal
in that mode and can be ignored.

While `flutter run` is attached:

- `r` — hot reload (debug mode only)
- `R` — hot restart
- `q` — quit and stop the app

## Run from Android Studio instead of the terminal

Android Studio cannot pass `-gpu swiftshader_indirect` when it launches an AVD
itself, and the AVD has `hw.gpu.mode=auto`, so an emulator started from Studio's
device dropdown picks the broken `host` path and the screen goes blank. The way
around that is a **Start Emulator** run configuration that calls the launcher
script, so you never leave the IDE.

Two Shell Script run configurations are already set up in this project:

| Configuration | Starts | File |
|---|---|---|
| **Start Phone Emulator** | `pixel_9_a16` | `.idea/runConfigurations/Start_Emulator.xml` |
| **Start Tablet Emulator** | `oneplus_pad_a16` | `.idea/runConfigurations/Start_Tablet_Emulator.xml` |

Both run `tool/start_emulator.sh`, differing only in the AVD passed as a script
argument. Both set `EMBED=1`, which hides the emulator's own window so it appears
in Studio's **Running Devices** panel instead.

Pick one in the run-configuration dropdown and press play. It
passes the GPU flag, then waits for boot and prints `READY` — roughly 90 seconds
cold. Running it when the emulator is already up costs about 3 seconds and does
nothing, so it is safe to press any time you are unsure.

Then switch the dropdown to **main.dart** and press play again to launch the app.
Start whichever devices you want; both can be up together. Pick the target in
Studio's device dropdown before pressing play — with two attached it will not
guess for you.

To collapse that into one button, chain them: *Run > Edit Configurations >
main.dart > Before launch > + > Run Another Configuration > Start Emulator*.
After that, play on **main.dart** boots the emulator if needed and then runs the
app.

**One-time setup — pick the right run configuration.**

In the toolbar at the top there are three controls: a device chip, a target chip,
and a run-configuration dropdown next to the green play button.

1. Open the run-configuration dropdown. If it says **app**, that is the wrong one.
   `app` is the plain Android module configuration Android Studio generates by
   itself. It builds `android/app` as an ordinary Android app, knows nothing about
   Dart, and gives you no hot reload.
2. Choose **main.dart** instead. It already exists in the project at
   `.idea/runConfigurations/main_dart.xml`. If it is missing, recreate it with
   *Run > Edit Configurations > + > Flutter* and set Dart entrypoint to
   `lib/main.dart`.
3. In the device chips, make sure only the **Pixel 9** emulator is selected.
   If **macOS (desktop)** is also selected, deselect it — the Android build cannot
   deploy to a Mac desktop target and the run fails before it starts.

**Every time you run:**

1. Run **Start Phone Emulator** or **Start Tablet Emulator** and wait for `READY`.
2. Confirm Studio sees it — the device chip should read `Pixel 9 Android 16`.
3. Switch to **main.dart** and press the green play button.

Hot reload is the lightning-bolt button; hot restart is the one next to it. These
only work in debug mode, which is what the play button uses by default.

**Why the terminal is still worth using:** `flutter run --release` is much faster on
this emulator for click-through testing. Use Studio when you want breakpoints and
hot reload, the terminal when you want speed.

## After changing code

Just stop (`q`) and run again.

**After a schema change**, uninstall first. The migration map in
`lib/platform/storage/database.dart` is deliberately empty, so opening a database
written by an older `kSchemaVersion` throws `no migration step from schema vN`
rather than guessing. Uninstalling wipes the database and `onCreate` rebuilds it:

```bash
export PATH="/usr/local/share/android-commandlinetools/platform-tools:$PATH"
adb uninstall com.littleloaf.little_loaf
``` If the change touched database tables
(`lib/platform/storage/tables.dart`), regenerate first:

```bash
cd /Users/mac/Downloads/GitHub/litte-loaf-bakery
dart run build_runner build --force-jit --delete-conflicting-outputs
```

`--force-jit` is required. Without it the build fails with "Failed to compile
build script" — `dart compile` cannot handle the build hooks that the `sqlite3`
and `objective_c` packages ship.

## Check whether the app is actually broken

Before assuming a bug, run these. They take seconds and usually show the app is
fine and something else is on top of it.

```bash
export PATH="/usr/local/share/android-commandlinetools/platform-tools:$PATH"

# Is the app running?
adb shell pidof com.littleloaf.little_loaf

# Any real Dart errors? 0 means the app is healthy.
adb logcat -d | grep -c "E/flutter"

# What is actually on screen right now?
adb shell dumpsys activity activities | grep -m1 topResumedActivity

# What does the screen look like? (writes a PNG you can open)
adb exec-out screencap -p > /tmp/screen.png && open /tmp/screen.png
```

`screencap` reads what Android composited, which is not always what the emulator
window shows. When the window is blank but `screencap` is correct, the app is
fine and the problem is the emulator's graphics — not the code.

---

# Troubleshooting

## Blank screen, or content flashes for 1–2 seconds when you resize the window

**Cause:** the emulator is rendering through the Mac's host OpenGL. Frames are
drawn but never presented to the window until a resize forces a redraw.

**Confirm it:**

```bash
grep gles_mode_selected /tmp/emu.log
```

`gles_mode_selected:host` is the broken state. `swangle` is the good state.

**Fix:** shut the emulator down and start it again with
`-gpu swiftshader_indirect` as shown above.

Setting `hw.gpu.mode` in `~/.android/avd/pixel_9_a16.avd/config.ini` does **not**
work — the emulator reads it and still selects `host`. Only the command-line
flag changes it.

**If it still blanks**, the second thing to try is Flutter's renderer:

```bash
flutter run --release --no-enable-impeller
```

Change one thing at a time so you know which one fixed it.

## Black screen with a microphone icon, or a dark panel over the app

Google Assistant has taken the foreground. The app is untouched underneath.
A long-press of Home or the power button triggers it on the emulator.

```bash
export PATH="/usr/local/share/android-commandlinetools/platform-tools:$PATH"
adb shell input keyevent KEYCODE_BACK
adb shell am start -n com.littleloaf.little_loaf/.MainActivity
```

Confirm with the `topResumedActivity` command above: if it says
`com.google.android.googlequicksearchbox`, this is what happened.

## Install fails: "Can't find service: package" or "device is still booting"

```
adb: failed to install app-release.apk: cmd: Can't find service: package
adb: failed to install app-release.apk: Error: device is still booting.
```

**This is not a build failure.** The APK built fine. The emulator accepted the adb
connection before Android had finished starting its system services, so there was
no package manager to install into yet.

`adb devices` reporting `device` is **not** enough. Check the real signals:

```bash
export PATH="/usr/local/share/android-commandlinetools/platform-tools:$PATH"
adb shell getprop sys.boot_completed     # must print 1
adb shell getprop init.svc.bootanim      # must print stopped
```

**Cause on this machine:** a Gradle release build and the emulator compete for CPU.
Observed on 28 Aug 2026 — a release build drove host load average to 34, boot took
over eight minutes, and keystore2 logged `await_boot_completed ... Overdue 227s`.
The same starvation makes Android throw **"System UI isn't responding"** dialogs over
the app. That dialog is SystemUI, not this app: check `pidof` and `E/flutter` before
believing the app crashed. Tap **Wait**, not Close app.

**Fix:** let boot finish before building or running. Nothing needs rebuilding — the
APK is already there, so just install it:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
adb shell monkey -p com.littleloaf.little_loaf -c android.intent.category.LAUNCHER 1
```

Check host load with `uptime` before starting a build; above ~10 on this Mac,
expect the emulator to crawl.

## Wrong Android version

```bash
export PATH="/usr/local/share/android-commandlinetools/platform-tools:$PATH"
adb shell getprop ro.build.version.release   # must print 16
```

If it prints anything else, a second emulator is running and took the port
first. Kill it and start `pixel_9_a16`:

```bash
adb -s emulator-5554 emu kill
```

## Running Devices stays empty, and there is no emulator window either

**Cause:** the emulator is running without its gRPC bridge, so Android Studio
cannot see it. With `EMBED=1` also hiding the window, the device is invisible
even though `adb devices` lists it and the app deploys fine.

The bridge only starts by itself on the default console port. Pass `-port` for a
second device and it is skipped without a warning — the emulator log simply has
no `Started GRPC` line and no `Advertising in:` line.

**Confirm it:**

```bash
grep -E "Started GRPC|Advertising in:" /tmp/emu-<avd>.log
ls ~/Library/Caches/TemporaryItems/avd/running/
```

Both empty is the broken state. That directory is exactly what Studio reads: each
`pid_*.ini` carries `grpc.port`, `grpc.token` and `port.serial` for one device.

**Fix:** pass an explicit gRPC port. `tool/start_emulator.sh` now always does,
and prints `discoverable by Android Studio: yes` when the advertising line
appears, so a silent failure cannot repeat.

```bash
emulator -avd oneplus_pad_a16 -port 5556 -grpc 8556 -grpc-use-token \
  -gpu swiftshader_indirect -qt-hide-window
```

`-grpc-use-token` keeps the bridge authenticated; without it the emulator warns
that `-grpc` opens an unprotected port.

## Testing the WhatsApp hand-off

Real WhatsApp cannot run here: this AVD is a `google_apis` image, so there is no
Play Store, and WhatsApp ships ARM-only native libraries that will not run on
x86_64. Signing in would also need a real number and an SMS code.

None of that is what is being tested. The question is only whether Little Loaf
builds the right `wa.me` link and hands it over, so a stub app claims the same
links and prints what it receives — the URL, the number, and the decoded message.

```bash
cd /Users/mac/Downloads/GitHub/litte-loaf-bakery
./tool/install_whatsapp_stub.sh
```

Then open an order and tap any WhatsApp action. To check it without the app:

```bash
export PATH="/usr/local/share/android-commandlinetools/platform-tools:$PATH"
adb shell am start -a android.intent.action.VIEW \
  -d 'https://wa.me/919876543210?text=hello'
```

**If Chrome opens instead of the stub**, the link approval was lost — reinstalling
the stub or wiping the emulator clears it. Re-run the script; it re-approves
`wa.me` every time. The stub cannot verify a domain it does not own, which is why
the approval is a manual `pm set-app-links` step rather than something the
manifest can claim on its own.

Source is in `tool/whatsapp_stub/`. It is a plain Android app with no
dependencies, unrelated to the Flutter build.

## The app is installed but shows old code

`flutter run` replaces the app each time, so this normally cannot happen. If it
does, uninstall and run again:

```bash
export PATH="/usr/local/share/android-commandlinetools/platform-tools:$PATH"
adb uninstall com.littleloaf.little_loaf
```

**This wipes the database** — every order, customer and stock entry on the
emulator. The app reseeds a starter menu and material list on next launch.

## "34 packages have newer versions incompatible with dependency constraints"

Not a problem. It is information, not a warning. Most of those packages are
pinned by the Flutter SDK and must not be moved. Ignore it.

---

# Things that are normal and not bugs

- **"Skipped 231 frames! The application may be doing too much work"** — debug
  mode on a software-rendered emulator. Not present in `--release`.
- **`EGL_emulation` / `EGL_SWAP_BEHAVIOR_PRESERVED` lines** — emulator graphics
  chatter, harmless.
- **"Offline · N waiting to upload"** on the Today screen — correct. Google
  Drive sync is not built yet, so the outbox fills and never drains.
- **"10 materials below threshold"** on a fresh install — correct. The seeded
  materials start at zero stock.
- **WhatsApp buttons open "WhatsApp (stub)"** — that is correct, not a bug. See
  *Testing the WhatsApp hand-off* below.

---

# For an AI running this

- Prefer `--release` for click-through verification; it is faster and matches
  what a phone does.
- **Wait for boot before installing.** `adb devices` showing `device` is not enough;
  require `sys.boot_completed=1` and `init.svc.bootanim=stopped`, or the install dies
  with "Can't find service: package". Do not start a build while the emulator boots —
  they starve each other on this Intel Mac.
- **Verify by evidence, not by assumption.** After launching, check
  `adb logcat -d | grep -c "E/flutter"` and take a `screencap`. A screenshot that
  renders correctly plus zero `E/flutter` is the standard for "it works".
- **A blank emulator window is not evidence of an app bug.** `screencap` reads
  the composited framebuffer and has been correct while the window was blank.
  Check `topResumedActivity` and `gles_mode_selected` before touching code.
- Do not drive the UI with blind `adb shell input tap` coordinates on screens
  with destructive actions — a stray tap has opened a "Remove item?" dialog.
  Screenshot first, then tap what you can see.
- Long builds: run in the background and wait on a completion marker rather than
  polling. A release build takes roughly two minutes here.
- The user does not know Flutter. Give copy-pasteable commands, not descriptions
  of what to do.
