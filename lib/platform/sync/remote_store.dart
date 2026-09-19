import 'dart:io';

/// Where journals live, without saying Drive.
///
/// The engine talks to this and nothing else, so the whole upload/pull cycle
/// can be tested against an in-memory map. Drive is one implementation.
///
/// The layout it describes is the one in docs/01-platform/sync/hld.md and
/// docs/01-platform/backup/schema.md:
///
///     <root>/journal/<device-id>/ops.jsonl
///     <root>/journal/<device-id>/device.json
///     <root>/snapshot/owner.json
///     <root>/snapshot/<yyyy-mm-dd>.db
abstract class RemoteStore {
  /// Device ids with a journal folder, including this device.
  Future<List<String>> listDevices();

  /// The whole `ops.jsonl` for one device, or null if it has none yet.
  Future<String?> readJournal(String deviceId);

  /// Replaces `ops.jsonl` wholesale. Drive has no append, and a whole-file
  /// replace is atomic there: a reader sees the old revision or the new one,
  /// never a splice. docs/01-platform/sync/hld.md D3
  Future<void> writeJournal(String deviceId, String body);

  Future<String?> readDeviceMeta(String deviceId);

  Future<void> writeDeviceMeta(String deviceId, String json);

  // ── snapshots ──────────────────────────────────────────────────────────
  //
  // The other half of the backup: journals hold the recent tail, a snapshot
  // holds everything before it. docs/01-platform/backup/hld.md

  /// `snapshot/owner.json`, or null if nobody has claimed the job yet.
  Future<String?> readSnapshotMeta();

  Future<void> writeSnapshotMeta(String json);

  /// Snapshot file names, e.g. `2026-09-20.db`. Unsorted.
  Future<List<String>> listSnapshots();

  /// Uploads [file] as `snapshot/<name>`, replacing any file of that name.
  ///
  /// Takes a [File] rather than bytes because a snapshot is the whole
  /// database, and the point of streaming it is not holding it in memory.
  Future<void> uploadSnapshot(String name, File file);

  /// Downloads `snapshot/<name>` into [into]. False if there is no such file.
  Future<bool> downloadSnapshot(String name, File into);

  Future<void> deleteSnapshot(String name);

  // ── the fleet's idea of the newest build ───────────────────────────────

  /// `<root>/app.json`, or null if nothing has written it yet.
  ///
  /// At the root beside `journal/` and `snapshot/` rather than inside either:
  /// it is a fact about the app, not about one device's ops or one night's
  /// backup. docs/01-platform/versioning/schema.md
  Future<String?> readAppConfig();

  Future<void> writeAppConfig(String json);
}

/// A [RemoteStore] in a map. Used by the tests, and by nothing else.
class InMemoryRemoteStore implements RemoteStore {
  final Map<String, String> journals = {};
  final Map<String, String> meta = {};
  final Map<String, List<int>> snapshots = {};
  String? snapshotMeta;

  /// Set to make the next write throw, so tests can check a failed upload
  /// leaves the outbox intact.
  Object? failNextWrite;

  @override
  Future<List<String>> listDevices() async =>
      {...journals.keys, ...meta.keys}.toList()..sort();

  @override
  Future<String?> readJournal(String deviceId) async => journals[deviceId];

  @override
  Future<void> writeJournal(String deviceId, String body) async {
    _maybeFail();
    journals[deviceId] = body;
  }

  @override
  Future<String?> readDeviceMeta(String deviceId) async => meta[deviceId];

  @override
  Future<void> writeDeviceMeta(String deviceId, String json) async {
    _maybeFail();
    meta[deviceId] = json;
  }

  String? appConfig;

  @override
  Future<String?> readAppConfig() async => appConfig;

  @override
  Future<void> writeAppConfig(String json) async {
    _maybeFail();
    appConfig = json;
  }

  @override
  Future<String?> readSnapshotMeta() async => snapshotMeta;

  @override
  Future<void> writeSnapshotMeta(String json) async {
    _maybeFail();
    snapshotMeta = json;
  }

  @override
  Future<List<String>> listSnapshots() async => snapshots.keys.toList()..sort();

  @override
  Future<void> uploadSnapshot(String name, File file) async {
    _maybeFail();
    snapshots[name] = await file.readAsBytes();
  }

  @override
  Future<bool> downloadSnapshot(String name, File into) async {
    final bytes = snapshots[name];
    if (bytes == null) return false;
    await into.writeAsBytes(bytes, flush: true);
    return true;
  }

  @override
  Future<void> deleteSnapshot(String name) async {
    snapshots.remove(name);
  }

  void _maybeFail() {
    final e = failNextWrite;
    if (e == null) return;
    failNextWrite = null;
    throw e;
  }
}
