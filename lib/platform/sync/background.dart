import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import 'package:path_provider/path_provider.dart';

import '../backup/snapshot.dart';
import '../device/device_id.dart';
import '../storage/connection.dart';
import 'drive_auth.dart';
import 'drive_store.dart';
import 'mutations.dart';
import 'sync_engine.dart';

/// Sync while the app is closed.
///
/// Android's WorkManager runs this in a **separate isolate** with no access to
/// anything the UI built, so everything it needs — the device id, the database,
/// the Drive token — is opened again from scratch here. That is also why it
/// cannot reuse `AppServices`.
///
/// Fifteen minutes is Android's floor for periodic work, and it is a floor
/// rather than a promise: the system batches these with other apps' work and
/// defers them under Doze. Sync on open and on resume remains the path that
/// actually keeps a device current; this is the safety net for the tablet
/// nobody has picked up since yesterday.
const _taskName = 'little-loaf-sync';
const _uniqueName = 'little-loaf-periodic-sync';
const _snapshotTask = 'little-loaf-snapshot';
const _snapshotUnique = 'little-loaf-nightly-snapshot';

/// 00:02 Asia/Kolkata. Two minutes past, not midnight, so a date-stamped file
/// cannot land on the wrong side of the day boundary on a slow clock.
const _snapshotHourIst = 0;
const _snapshotMinuteIst = 2;
const _ist = Duration(hours: 5, minutes: 30);

/// Entry point for the background isolate. Must be top level and must carry the
/// pragma, or tree-shaking removes it from the release build and the task
/// silently never runs.
@pragma('vm:entry-point')
void syncCallbackDispatcher() {
  Workmanager().executeTask((task, _) async {
    if (task == _snapshotTask) return runNightlySnapshot();
    if (task != _taskName) return true;
    return runBackgroundSync();
  });
}

/// One sync run with nothing borrowed from the UI isolate.
///
/// Returns false only for failures worth retrying. "Not connected" is true:
/// retrying does not help, and telling WorkManager it failed would earn this
/// task an exponential backoff it never recovers from.
Future<bool> runBackgroundSync() async {
  try {
    final token = await DriveAuth().silentToken();
    if (token == null) return true;

    final deviceId = await const DeviceIdStore().readOrCreate();
    final db = await openAppDatabase();
    try {
      final mutations = await Mutations.restore(db, deviceId: deviceId);
      final engine = SyncEngine(
        db: db,
        mutations: mutations,
        store: DriveStore.withToken(token),
        deviceId: deviceId,
      );
      final report = await engine.sync();
      return report.ok;
    } finally {
      // The foreground isolate may hold the same file open. WAL plus the
      // busy_timeout set in connection.dart lets both proceed, but this handle
      // must still be closed or the isolate keeps a lock after the work ends.
      await db.close();
    }
  } catch (e) {
    debugPrint('background sync failed: $e');
    return false;
  }
}

/// The nightly backup, in the same borrowed-nothing style as the sync task.
///
/// Returns true even when this device is not the snapshot owner: that is the
/// normal answer for every device but one, and telling WorkManager it failed
/// would earn the task a backoff it never recovers from.
@pragma('vm:entry-point')
Future<bool> runNightlySnapshot() async {
  try {
    final token = await DriveAuth().silentToken();
    if (token == null) return true;

    final deviceId = await const DeviceIdStore().readOrCreate();
    final db = await openAppDatabase();
    try {
      final result = await SnapshotService(
        db: db,
        store: DriveStore.withToken(token),
        deviceId: deviceId,
        workDir: await getTemporaryDirectory(),
      ).run();
      if (!result.ok) debugPrint('snapshot failed: ${result.error}');
      return result.ok;
    } finally {
      await db.close();
    }
  } catch (e) {
    debugPrint('nightly snapshot failed: $e');
    return false;
  }
}

/// Called once at startup. Registering the same unique name again replaces the
/// existing schedule rather than stacking a second one.
Future<void> registerBackgroundSync() async {
  if (!defaultTargetPlatform.isAndroid) return;
  await Workmanager().initialize(syncCallbackDispatcher);
  await Workmanager().registerPeriodicTask(
    _uniqueName,
    _taskName,
    frequency: const Duration(minutes: 15),
    initialDelay: const Duration(minutes: 15),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    constraints: Constraints(
      // No point waking up to talk to Drive with no network, and no point
      // doing it on a nearly flat battery either.
      networkType: NetworkType.connected,
      requiresBatteryNotLow: true,
    ),
    backoffPolicy: BackoffPolicy.exponential,
    backoffPolicyDelay: const Duration(minutes: 5),
  );

  await Workmanager().registerPeriodicTask(
    _snapshotUnique,
    _snapshotTask,
    frequency: const Duration(hours: 24),
    initialDelay: untilNextSnapshot(DateTime.now()),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    constraints: Constraints(
      networkType: NetworkType.unmetered,
      requiresBatteryNotLow: true,
    ),
    backoffPolicy: BackoffPolicy.exponential,
    backoffPolicyDelay: const Duration(minutes: 30),
  );
}

/// How long until the next 00:02 IST.
///
/// Computed in IST rather than in whatever the phone is set to, because the
/// snapshot file is named for the Indian date and a tablet that travelled
/// would otherwise start writing tomorrow's name tonight.
///
/// The phone being asleep at 00:02 is expected, not an error: Android runs
/// deferred work when it next surfaces, and `last_snapshot_at` records when
/// that actually was.
Duration untilNextSnapshot(DateTime now) {
  final ist = now.toUtc().add(_ist);
  var due = DateTime.utc(ist.year, ist.month, ist.day, _snapshotHourIst,
      _snapshotMinuteIst);
  if (!due.isAfter(ist)) due = due.add(const Duration(days: 1));
  return due.difference(ist);
}

extension on TargetPlatform {
  bool get isAndroid => this == TargetPlatform.android;
}
