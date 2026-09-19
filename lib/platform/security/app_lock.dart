import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import '../storage/database.dart';

/// How long the app may sit in the background before it asks again.
///
/// Five minutes, because the common interruption is a phone call or a customer
/// at the counter, and making someone authenticate to get back to the order
/// they were mid-way through is how a lock gets switched off for good.
const Duration kLockAfter = Duration(minutes: 5);

/// The device's own authentication, behind one method.
///
/// `local_auth` does not export the types on its own call signature, so a fake
/// cannot implement it. This is also the honest shape of what the app needs:
/// ask, and get a yes or a no.
abstract class DeviceAuth {
  /// Whether a PIN, pattern, password or biometric exists to ask for.
  Future<bool> isSupported();

  /// Prompts, returning whether the person answered correctly. Throws if the
  /// device could not ask at all.
  Future<bool> ask(String reason);
}

class PluginDeviceAuth implements DeviceAuth {
  PluginDeviceAuth([LocalAuthentication? auth])
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isSupported() => _auth.isDeviceSupported();

  @override
  Future<bool> ask(String reason) => _auth.authenticate(
        localizedReason: reason,
        // The PIN is the fallback, not a separate mode: a wet or floury
        // finger in a kitchen is the normal case, not the exception.
        biometricOnly: false,
        // A prompt interrupted by a call comes back rather than failing.
        persistAcrossBackgrounding: true,
      );
}

/// Whether the app is asking for the device PIN or a fingerprint before it
/// shows anything.
///
/// Off by default. The real protection is the device lock and the encryption
/// at rest; this is for the phone handed across a counter. There is no lockout
/// counter and no app-specific passcode — a shopkeeping app that invents its
/// own credential is one more thing to lose.
/// docs/01-platform/security/lld.md §2
class AppLock extends ChangeNotifier {
  AppLock({
    required this.db,
    DeviceAuth? auth,
    DateTime Function()? clock,
  })  : _auth = auth ?? PluginDeviceAuth(),
        _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final DeviceAuth _auth;
  final DateTime Function() _clock;

  bool _enabled = false;
  bool _locked = false;
  bool _asking = false;
  DateTime? _leftAt;

  bool get enabled => _enabled;

  /// True while the lock screen should be covering the app.
  bool get locked => _locked;

  /// True while a system prompt is on screen. The gate uses it to avoid
  /// stacking a second prompt on top of the first.
  bool get asking => _asking;

  /// Reads the setting and locks if it is on. Called once, at startup — a
  /// cold start always asks.
  Future<void> start() async {
    final settings = await db.select(db.settings).getSingle();
    _enabled = settings.appLockEnabled;
    _locked = _enabled;
    notifyListeners();
  }

  /// Whether this device can lock at all: a PIN, pattern, password or
  /// biometric is set up. Offering the switch on a device with no device lock
  /// would be offering a door with no frame.
  Future<bool> isSupported() async {
    try {
      return await _auth.isSupported();
    } on Exception {
      return false;
    }
  }

  Future<void> setEnabled(bool on) async {
    if (on && !await isSupported()) {
      throw StateError(
        'Set a screen lock on this device first — Little Loaf uses the same '
        'PIN or fingerprint rather than one of its own.',
      );
    }
    await db.update(db.settings).write(SettingsCompanion(
          appLockEnabled: Value(on),
        ));
    _enabled = on;
    // Turning it on does not lock you out of the screen you are standing on;
    // it applies from the next time the app leaves the foreground.
    if (!on) _locked = false;
    notifyListeners();
  }

  /// Asks the device. Unlocks on success; on a refusal or a cancel the lock
  /// stays up and the caller can offer the button again.
  Future<bool> unlock() async {
    if (_asking) return false;
    _asking = true;
    notifyListeners();
    try {
      final ok = await _auth.ask('Unlock Little Loaf');
      if (ok) _locked = false;
      return ok;
    } on Exception {
      // No biometric hardware, no enrolled credential, a vendor plugin that
      // threw: none of these should make the app unopenable.
      _locked = false;
      return true;
    } finally {
      _asking = false;
      notifyListeners();
    }
  }

  /// The app went to the background. Only the time is recorded — locking
  /// happens on the way back, so nothing redraws behind a lock screen in the
  /// task switcher preview.
  void onPaused() {
    if (!_enabled) return;
    _leftAt = _clock();
  }

  /// The app came back. Locks only if it was away long enough.
  void onResumed() {
    if (!_enabled || _locked) return;
    final left = _leftAt;
    if (left == null) return;
    if (_clock().difference(left) >= kLockAfter) {
      _locked = true;
      notifyListeners();
    }
  }

  /// Whether a gap of this length locks the app. Exposed so the rule can be
  /// tested without a lifecycle or a fingerprint.
  static bool shouldLock(Duration away) => away >= kLockAfter;
}
