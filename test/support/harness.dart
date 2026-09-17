import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/app/scope.dart';
import 'package:little_loaf/common/hlc.dart';
import 'package:little_loaf/platform/storage/connection.dart';
import 'package:little_loaf/platform/sync/mutations.dart';
import 'package:little_loaf/platform/sync/apply.dart';
import 'package:little_loaf/platform/sync/remote_store.dart';
import 'package:little_loaf/platform/sync/sync_engine.dart';
import 'package:little_loaf/ui/theme/theme.dart';

/// A real database — schema, constraints, indexes and all — held in memory.
///
/// Widget tests run against the same tables the phone does, so a CHECK
/// constraint that the UI can violate fails here rather than in someone's
/// kitchen.
///
/// Pass [tester] for a widget test. The tree is unmounted before the database
/// closes: drift keeps a timer per live stream query, and closing underneath a
/// mounted `StreamBuilder` leaves that timer pending, which the test binding
/// then reports as a failure in whichever test happens to run next.
Future<AppServices> testServices({
  WidgetTester? tester,
  String deviceId = 'test-device',
}) async {
  final db = openTestDatabase();
  await db.select(db.settings).getSingle(); // force onCreate

  addTearDown(() async {
    if (tester == null) {
      await db.close();
      return;
    }
    // Unmount first: closing under a mounted StreamBuilder leaves drift's
    // per-stream timer pending, which the binding reports as a failure in
    // whichever test runs next.
    await tester.pumpWidget(const SizedBox.shrink());
    // Each StreamBuilder that unsubscribes makes drift schedule a
    // zero-duration timer (StreamQueryStore.markAsClosed), and those are
    // created as the earlier ones fire — so one pump is never enough. Pump
    // until the fake clock has nothing left before the database goes away.
    for (var i = 0; i < 10; i++) {
      await tester.pump(Duration.zero);
    }
    // Outside fake_async, so anything drift schedules while closing actually
    // runs rather than sitting in the fake clock forever.
    await tester.runAsync(() => db.close());
    await tester.pump(Duration.zero);
  });

  return AppServices(
    db: db,
    deviceId: deviceId,
    mutations: Mutations(db,
        deviceId: deviceId, lastHlc: Hlc(1, 0, deviceId), lastSeq: 0),
  );
}

/// Wraps a screen in the same scope and theme the app gives it.
Widget wrapped(AppServices services, Widget child) => AppScope(
      services: services,
      child: MaterialApp(theme: loafTheme(Brightness.light), home: child),
    );

/// Services plus the bits sync tests reach for, so each test reads as the
/// behaviour it asserts rather than as setup.
class AppServicesFixture {
  AppServicesFixture(this.services) : applier = OpApplier(services.db, services.mutations);

  final AppServices services;
  final OpApplier applier;

  static Future<AppServicesFixture> make() async =>
      AppServicesFixture(await testServices());

  /// Raw row access: sync writes generically, so tests read generically too.
  Future<List<Map<String, Object?>>> rows(String table) async {
    final r = await services.db.customSelect('SELECT * FROM $table').get();
    return [for (final row in r) row.data];
  }

  Future<Map<String, Object?>?> row(String table, String id) async {
    final r = await services.db.customSelect(
      'SELECT * FROM $table WHERE id = ?',
      variables: [Variable.withString(id)],
    ).get();
    return r.isEmpty ? null : r.first.data;
  }

  Future<void> close() => services.db.close();
}

/// One device in a sync test: its own database, its own device id, sharing a
/// store with the others.
class SyncDevice {
  SyncDevice(this.id, this.services, this.engine)
      : fixture = AppServicesFixture(services);

  final String id;
  final AppServices services;
  final SyncEngine engine;
  final AppServicesFixture fixture;

  static Future<SyncDevice> make(String id, RemoteStore store) async {
    final services = await testServices(deviceId: id);
    return SyncDevice(
      id,
      services,
      SyncEngine(
        db: services.db,
        mutations: services.mutations,
        store: store,
        deviceId: id,
      ),
    );
  }

  Future<void> close() => services.db.close();
}

/// Unmounts the tree and lets drift's per-stream close timers fire, inside the
/// test's own fake clock. Without this the binding reports them as pending and
/// fails the test that happens to run next.
Future<void> drain(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  for (var i = 0; i < 10; i++) {
    await tester.pump(Duration.zero);
  }
}
