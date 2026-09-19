import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../common/ids.dart';

/// This install's identity. A UUID v7 minted on first run and kept in secure
/// storage for the life of the install.
///
/// A reinstall — or a replacement phone restored from backup — gets a **new**
/// id, because the id names an install, not a person or a handset.
/// docs/00-overview/decisions.md D6.
class DeviceIdStore {
  const DeviceIdStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;
  static const _key = 'little_loaf_device_id';

  Future<String> readOrCreate() async {
    final existing = await _storage.read(key: _key);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = Uuid7.generate();
    await _storage.write(key: _key, value: id);
    return id;
  }

  /// Mints a fresh id, discarding the old one. Called after a restore.
  ///
  /// It has to be new. The old install's sequence counter was local state and
  /// is not in the snapshot, so a restored device that kept the id would
  /// restart its series at 1 and reissue numbers the old one already used.
  Future<String> rotate() async {
    final id = Uuid7.generate();
    await _storage.write(key: _key, value: id);
    return id;
  }
}
