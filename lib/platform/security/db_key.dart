import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The SQLCipher key, generated once and held in the Android Keystore.
///
/// `userAuthenticationRequired` is deliberately **off**: tying the database key
/// to biometrics would make the app unopenable after a fingerprint reset, and
/// the sync worker could not run at 00:02 with the screen locked. The app lock
/// is a separate, optional UI gate.
/// See docs/01-platform/security/lld.md §1.
class DbKeyStore {
  const DbKeyStore({this.storage = const FlutterSecureStorage()});

  final FlutterSecureStorage storage;

  static const _alias = 'llb_db_key';

  Future<String> readOrCreate() async {
    final existing = await storage.read(key: _alias);
    if (existing != null && existing.length == 64) return existing;

    final rng = Random.secure();
    final hex = List.generate(
      32,
      (_) => rng.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();

    await storage.write(key: _alias, value: hex);
    return hex;
  }
}
