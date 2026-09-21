import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../platform/device/device_id.dart';
import '../platform/notifications/reminders.dart';
import '../platform/storage/connection.dart';
import '../platform/storage/database.dart';
import '../platform/sync/background.dart';
import '../platform/sync/mutations.dart';
import '../domain/reminders/model.dart';
import '../ui/shell/lock_gate.dart';
import '../ui/shell/tabs.dart';
import '../ui/shell/update_gate.dart';
import '../ui/shell/shell.dart';
import '../ui/theme/theme.dart';
import 'scope.dart';

/// First frame to first usable screen.
///
/// The database file is created here if it is absent — drift's `onCreate` runs
/// every table, index and the settings singleton in one transaction. Nothing is
/// downloaded and no account is needed: the app is fully usable offline before
/// Google Sign-In has been touched.
/// docs/01-platform/storage/schema.md § First run.
class Boot extends StatefulWidget {
  const Boot({super.key});

  @override
  State<Boot> createState() => _BootState();
}

class _BootState extends State<Boot> {
  late final Future<AppServices> _future = _open();
  // Tapping the morning digest opens the Kitchen, which is the screen the
  // day is worked from. The service never touches the UI itself; it hands the
  // payload back and this decides where it means.
  final _reminders = ReminderService(onOpen: (payload) {
    if (payload == kDigestPayload) requestedTab.value = kKitchenTab;
  });

  Future<AppServices> _open() async {
    final deviceId = await const DeviceIdStore().readOrCreate();
    final db = await openAppDatabase();
    final mutations = await Mutations.restore(db, deviceId: deviceId);
    final services =
        AppServices(db: db, deviceId: deviceId, mutations: mutations);
    await _registerDevice(db, deviceId);
    // Scheduling is cheap and idempotent, so it happens on every start rather
    // than being tracked as "done once". Failing to schedule must not stop the
    // app opening — sync on resume still works without it.
    unawaited(registerBackgroundSync().catchError(
        (Object e) => debugPrint('could not schedule background sync: $e')));

    // Journey reminders. Following the order stream covers every way a
    // journey can change — an edit here, or a peer's edit arriving over sync
    // and landing in the same database — so there is no path that forgets to
    // reschedule. Quiet on failure, like the sync registration above.
    unawaited(_reminders.init().then((_) => _reminders.follow(services.orders, services.stock, services.menu))
        .catchError((Object e) => debugPrint('no reminders: $e')));
    return services;
  }

  /// This install announces itself once, so the sync screen can list the
  /// devices sharing the Drive folder.
  Future<void> _registerDevice(AppDatabase db, String deviceId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing =
        await (db.select(db.devices)..where((t) => t.id.equals(deviceId)))
            .getSingleOrNull();
    if (existing == null) {
      await db.into(db.devices).insert(DevicesCompanion.insert(
            id: deviceId,
            deviceId: deviceId,
            createdAt: now,
            updatedAtHlc: '$now:0:$deviceId',
            firstSeenAt: now,
            lastSeenAt: now,
          ));
    } else {
      await (db.update(db.devices)..where((t) => t.id.equals(deviceId)))
          .write(DevicesCompanion(lastSeenAt: Value(now)));
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AppServices>(
        future: _future,
        builder: (context, snap) {
          final app = MaterialApp(
            title: 'Little Loaf Bakery',
            debugShowCheckedModeBanner: false,
            theme: loafTheme(Brightness.light),
            darkTheme: loafTheme(Brightness.dark),
            // Through the builder, so the lock covers pushed routes too — it
            // sits above the Navigator but inside the theme.
            builder: snap.hasData
                ? (context, child) =>
                    LockGate(child: UpdateGate(child: child!))
                : null,
            home: snap.hasError
                ? _BootError(error: snap.error!)
                : !snap.hasData
                    ? const _BootSplash()
                    : const AppShell(),
          );

          // AppScope goes **above** MaterialApp, not below it.
          //
          // A pushed route is inserted as a child of the Navigator, not of the
          // widget that pushed it. Providing the scope under MaterialApp puts
          // it under the Navigator too, so the tabs inside AppShell can see it
          // but every pushed screen — new order, order detail, all of Config —
          // cannot, and throws "No AppScope above this widget".
          if (!snap.hasData) return app;
          return AppScope(services: snap.data!, child: app);
        },
      );
}

class _BootSplash extends StatelessWidget {
  const _BootSplash();

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colors.paper,
        body: const Center(child: CircularProgressIndicator()),
      );
}

/// A database that will not open is not something to retry silently — it is
/// shown, in full, because the next step is a human decision.
class _BootError extends StatelessWidget {
  const _BootError({required this.error});

  final Object error;

  /// "file is not a database" means the file is encrypted with a key this
  /// install does not have — not that it is damaged. Worth saying, because the
  /// two want opposite things done about them.
  bool get _isWrongKey => '$error'.contains('file is not a database');

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colors.paper,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, size: 40, color: context.colors.bad),
              const SizedBox(height: 12),
              Text('The database could not be opened',
                  style: context.text.titleMedium),
              const SizedBox(height: 8),
              if (_isWrongKey) ...[
                Text(
                  'This phone has a database it cannot decrypt — the file was '
                  'restored without the key that opens it, which the Android '
                  'Keystore never hands over.\n\n'
                  'Starting fresh discards what is on this phone. If the '
                  'bakery has been syncing, the orders are in Drive and come '
                  'back when you reconnect.',
                  style: context.text.bodyMedium!
                      .copyWith(color: context.colors.ink2),
                ),
                const SizedBox(height: 20),
                _StartFresh(),
                const SizedBox(height: 20),
              ],
              Text('$error',
                  style: context.text.bodySmall!
                      .copyWith(color: context.colors.ink3)),
            ],
          ),
        ),
      );
}

/// Discards the unopenable database, on a deliberate choice and a confirmation.
class _StartFresh extends StatefulWidget {
  @override
  State<_StartFresh> createState() => _StartFreshState();
}

class _StartFreshState extends State<_StartFresh> {
  bool _busy = false;

  Future<void> _go() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Start fresh?'),
        content: const Text(
          'Everything stored on this phone is deleted. Anything already synced '
          'to Drive is not touched and comes back when you reconnect.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(d, true),
              child: const Text('Delete and start fresh')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    await discardLocalDatabase();
    if (!mounted) return;
    // A restart is the honest way back: everything downstream of the database
    // was built against a failure, and re-running boot from here would be
    // rebuilding the app around a half-torn-down scope.
    setState(() => _busy = false);
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        title: Text('Done'),
        content: Text('Close the app completely and open it again.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => FilledButton.icon(
        onPressed: _busy ? null : _go,
        icon: const Icon(Icons.refresh, size: 18),
        label: const Text('Start fresh on this phone'),
      );
}
