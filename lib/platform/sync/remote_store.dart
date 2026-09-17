/// Where journals live, without saying Drive.
///
/// The engine talks to this and nothing else, so the whole upload/pull cycle
/// can be tested against an in-memory map. Drive is one implementation.
///
/// The layout it describes is the one in docs/01-platform/sync/hld.md:
///
///     <root>/journal/<device-id>/ops.jsonl
///     <root>/journal/<device-id>/device.json
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
}

/// A [RemoteStore] in a map. Used by the tests, and by nothing else.
class InMemoryRemoteStore implements RemoteStore {
  final Map<String, String> journals = {};
  final Map<String, String> meta = {};

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

  void _maybeFail() {
    final e = failNextWrite;
    if (e == null) return;
    failNextWrite = null;
    throw e;
  }
}
