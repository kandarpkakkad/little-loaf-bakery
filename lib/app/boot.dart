import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../platform/device/device_id.dart';
import '../platform/storage/connection.dart';
import '../platform/storage/database.dart';
import '../platform/sync/background.dart';
import '../platform/sync/mutations.dart';
import '../ui/shell/lock_gate.dart';
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
                ? (context, child) => LockGate(child: child!)
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
              Text('$error',
                  style: context.text.bodySmall!
                      .copyWith(color: context.colors.ink2)),
            ],
          ),
        ),
      );
}
