import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../storage/database.dart';
import '../sync/remote_store.dart';

/// A snapshot as offered to someone choosing one.
class SnapshotChoice {
  const SnapshotChoice({required this.name, required this.takenOn});

  final String name;

  /// From the file name, which is the date it was taken.
  final DateTime takenOn;
}

class RestoreRefused implements Exception {
  RestoreRefused(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Downloading a snapshot back onto a device.
///
/// **Restore is staged, not live.** The snapshot is downloaded, checked and
/// parked next to the database; the swap happens in [applyPendingRestore] at
/// the next open, before anything has the old database open. Swapping under a
/// running app would mean every screen, stream and background isolate holding
/// a handle to a file that no longer exists.
///
/// Restore is snapshot **plus** every journal replayed from seq 0 — which is
/// automatic, because the snapshot carries no `peer_cursors` and no
/// `applied_ops`, so the next sync reads every journal from the beginning.
/// Applying an op that is already inside the snapshot is free: the merge is
/// last-writer-wins on an HLC that has not moved.
/// docs/01-platform/backup/lld.md §4
class RestoreService {
  RestoreService({required this.store, Directory? dir}) : _dir = dir;

  final RemoteStore store;
  final Directory? _dir;

  Future<Directory> _docs() async =>
      _dir ?? await getApplicationDocumentsDirectory();

  /// Newest first, which is also the one to offer by default.
  Future<List<SnapshotChoice>> available() async {
    final names = await store.listSnapshots();
    final out = <SnapshotChoice>[];
    for (final n in names) {
      final date = DateTime.tryParse(n.replaceAll('.db', ''));
      if (date != null) out.add(SnapshotChoice(name: n, takenOn: date));
    }
    return out..sort((a, b) => b.takenOn.compareTo(a.takenOn));
  }

  /// Downloads and checks [name], then parks it for the next launch.
  ///
  /// Nothing is destroyed here. If this throws — a bad download, a snapshot
  /// from a newer app — the device carries on with what it had.
  Future<void> stage(String name) async {
    final dir = await _docs();
    final staged = File(p.join(dir.path, stagedFileName));
    if (staged.existsSync()) await staged.delete();

    final got = await store.downloadSnapshot(name, staged);
    if (!got) throw RestoreRefused('That snapshot is no longer in Drive.');

    try {
      _check(staged.path);
    } catch (_) {
      if (staged.existsSync()) await staged.delete();
      rethrow;
    }
  }

  Future<bool> hasStaged() async =>
      File(p.join((await _docs()).path, stagedFileName)).existsSync();

  Future<void> cancel() async {
    final staged = File(p.join((await _docs()).path, stagedFileName));
    if (staged.existsSync()) await staged.delete();
  }

  /// Reads the file before trusting it with the bakery's records.
  void _check(String path) {
    final db = sqlite3.open(path);
    try {
      final integrity = db.select('PRAGMA integrity_check');
      final verdict = '${integrity.first.values.first}';
      if (verdict != 'ok') {
        throw RestoreRefused('That snapshot is damaged and cannot be used.');
      }

      final version =
          db.select('PRAGMA user_version').first.values.first as int;
      if (version > kSchemaVersion) {
        // Reading a schema from the future is not safe, and migrations only
        // run forwards. Updating the app is the fix, and it is a real one.
        throw RestoreRefused(
          'That snapshot was written by a newer version of the app. '
          'Update Little Loaf first, then restore.',
        );
      }
    } finally {
      db.close();
    }
  }
}

/// The staged snapshot, waiting next to the database.
const String stagedFileName = 'restore.db';

/// Swaps a staged snapshot in, if there is one. Called before the database is
/// opened, and does nothing at all on every ordinary launch.
///
/// The old database is replaced only once the new one has been written whole,
/// so an interruption anywhere leaves the device with what it already had.
/// Returns true if a restore happened, which is the signal to mint a new
/// device id.
Future<bool> applyPendingRestore({
  required Directory dir,
  required File dbFile,
  required String hexKey,
}) async {
  final staged = File(p.join(dir.path, stagedFileName));
  if (!staged.existsSync()) return false;

  // The snapshot is plaintext, as it must be to travel between devices. It
  // gets this device's own key on the way in.
  final encrypted = File('${dbFile.path}.restored');
  if (encrypted.existsSync()) await encrypted.delete();

  final plain = sqlite3.open(staged.path);
  var encryptedOk = false;
  try {
    // A build without SQLCipher is a test build, and nothing else. Copying
    // keeps the same staged-then-swap shape rather than pretending to encrypt.
    if (_hasCipher(plain)) {
      plain.execute(
          "ATTACH DATABASE '${encrypted.path}' AS enc KEY \"x'$hexKey'\"");
      plain.select("SELECT sqlcipher_export('enc')");
      // The exported copy does not inherit user_version, and drift reads it to
      // decide whether to migrate. Without this every restore looks like a
      // first run, and onCreate would try to build tables that already exist.
      final version = plain.select('PRAGMA user_version').first.values.first;
      plain.execute('PRAGMA enc.user_version = $version');
      plain.execute('DETACH DATABASE enc');
      encryptedOk = true;
    }
  } finally {
    plain.close();
  }
  if (!encryptedOk) await staged.copy(encrypted.path);

  await _swap(dbFile, encrypted, staged);
  return true;
}

/// The last step, and the only destructive one: the old database goes when the
/// new one is already written whole.
Future<void> _swap(File dbFile, File replacement, File staged) async {
  for (final f in [
    dbFile,
    File('${dbFile.path}-wal'),
    File('${dbFile.path}-shm'),
  ]) {
    if (f.existsSync()) await f.delete();
  }
  await replacement.rename(dbFile.path);
  if (staged.existsSync()) await staged.delete();
}

bool _hasCipher(Database db) {
  final rows = db.select('PRAGMA cipher_version');
  return rows.isNotEmpty && '${rows.first.values.first}'.trim().isNotEmpty;
}
