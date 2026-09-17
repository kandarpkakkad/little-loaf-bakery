import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

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

/// Entry point for the background isolate. Must be top level and must carry the
/// pragma, or tree-shaking removes it from the release build and the task
/// silently never runs.
@pragma('vm:entry-point')
void syncCallbackDispatcher() {
  Workmanager().executeTask((task, _) async {
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
}

extension on TargetPlatform {
  bool get isAndroid => this == TargetPlatform.android;
}
