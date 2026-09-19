import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/platform/security/app_lock.dart';
import 'package:little_loaf/platform/storage/connection.dart';
import 'package:little_loaf/platform/storage/database.dart';

/// Asking for the phone's own PIN, and only when it is worth asking.
/// docs/01-platform/security/lld.md §2
void main() {
  late AppDatabase db;
  late _FakeAuth auth;
  late DateTime now;

  setUp(() async {
    db = openTestDatabase();
    await db.select(db.settings).getSingle(); // force onCreate
    auth = _FakeAuth();
    now = DateTime(2026, 9, 20, 9);
  });

  tearDown(() => db.close());

  AppLock lock() => AppLock(db: db, auth: auth, clock: () => now);

  test('off by default, and a cold start opens straight into the app',
      () async {
    final l = lock();
    await l.start();
    expect(l.enabled, isFalse);
    expect(l.locked, isFalse);
  });

  test('a cold start with it on asks', () async {
    await db.update(db.settings).write(
        const SettingsCompanion(appLockEnabled: Value(true)));
    final l = lock();
    await l.start();
    expect(l.locked, isTrue);
  });

  test('turning it on does not lock the screen you are standing on', () async {
    final l = lock();
    await l.start();
    await l.setEnabled(true);

    expect(l.enabled, isTrue);
    expect(l.locked, isFalse, reason: 'it applies from the next time away');

    final saved = await db.select(db.settings).getSingle();
    expect(saved.appLockEnabled, isTrue);
  });

  test('a device with no screen lock is told why, and nothing is saved',
      () async {
    auth.supported = false;
    final l = lock();
    await l.start();

    await expectLater(l.setEnabled(true), throwsA(isA<StateError>()));
    expect(l.enabled, isFalse);
    expect((await db.select(db.settings).getSingle()).appLockEnabled, isFalse);
  });

  group('coming back', () {
    test('a minute away does not ask again', () async {
      final l = lock();
      await l.start();
      await l.setEnabled(true);

      l.onPaused();
      now = now.add(const Duration(minutes: 1));
      l.onResumed();

      expect(l.locked, isFalse,
          reason: 'a phone call mid-order must not cost an unlock');
    });

    test('five minutes away asks', () async {
      final l = lock();
      await l.start();
      await l.setEnabled(true);

      l.onPaused();
      now = now.add(const Duration(minutes: 5));
      l.onResumed();

      expect(l.locked, isTrue);
    });

    test('nothing happens at all while the lock is off', () async {
      final l = lock();
      await l.start();

      l.onPaused();
      now = now.add(const Duration(hours: 3));
      l.onResumed();

      expect(l.locked, isFalse);
    });

    test('the rule on its own', () {
      expect(AppLock.shouldLock(const Duration(minutes: 4, seconds: 59)),
          isFalse);
      expect(AppLock.shouldLock(kLockAfter), isTrue);
    });
  });

  group('unlocking', () {
    test('a successful answer opens the app', () async {
      await db.update(db.settings).write(
          const SettingsCompanion(appLockEnabled: Value(true)));
      final l = lock();
      await l.start();

      expect(await l.unlock(), isTrue);
      expect(l.locked, isFalse);
    });

    test('a refusal leaves the lock up', () async {
      auth.answer = false;
      await db.update(db.settings).write(
          const SettingsCompanion(appLockEnabled: Value(true)));
      final l = lock();
      await l.start();

      expect(await l.unlock(), isFalse);
      expect(l.locked, isTrue, reason: 'the Unlock button is still there');
    });

    test('a broken fingerprint reader does not make the app unopenable',
        () async {
      auth.throws = true;
      await db.update(db.settings).write(
          const SettingsCompanion(appLockEnabled: Value(true)));
      final l = lock();
      await l.start();

      expect(await l.unlock(), isTrue);
      expect(l.locked, isFalse,
          reason: 'no hardware, no enrolment, a vendor bug — none of these '
              'may lock someone out of their own orders');
    });

    test('a second tap does not stack a second prompt', () async {
      auth.hold = true;
      await db.update(db.settings).write(
          const SettingsCompanion(appLockEnabled: Value(true)));
      final l = lock();
      await l.start();

      final first = l.unlock();
      expect(await l.unlock(), isFalse, reason: 'one prompt is already up');
      auth.release();
      await first;
      expect(auth.calls, 1);
    });
  });
}

class _FakeAuth implements DeviceAuth {
  bool supported = true;
  bool answer = true;
  bool throws = false;
  bool hold = false;
  int calls = 0;

  final _gate = Completer<void>();
  void release() => _gate.complete();

  @override
  Future<bool> isSupported() async => supported;

  @override
  Future<bool> ask(String reason) async {
    calls++;
    if (hold) await _gate.future;
    if (throws) throw Exception('no biometric hardware');
    return answer;
  }
}
