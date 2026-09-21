import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../backup/restore.dart';
import '../device/device_id.dart';
import '../security/db_key.dart';
import 'database.dart';

/// Opens the app-private, encrypted database.
///
/// **First run creates it**: the file does not exist, drift's `onCreate` runs,
/// and every table, index and the settings singleton are written in one
/// transaction. Nothing is bundled and nothing is fetched — the app is usable
/// offline before Google Sign-In has been touched.
/// See docs/01-platform/storage/schema.md § First run.
/// Throws away the local database so the app can open again.
///
/// The one recovery from a file the key no longer opens. That happens when the
/// two are separated: Android's automatic backup used to restore the database
/// onto a fresh install while leaving the Keystore key behind, and a device
/// whose Keystore is cleared reaches the same place. Backup is off now
/// (`allowBackup="false"`), but a dead end on the launch screen is not
/// something to leave to one mitigation.
///
/// **Only ever on an explicit choice.** The orders are recoverable from the
/// Drive snapshot; nothing here can tell whether they are, so nothing here may
/// decide for somebody.
Future<void> discardLocalDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  for (final suffix in ['', '-wal', '-shm']) {
    final f = File(p.join(dir.path, 'little_loaf.db$suffix'));
    if (f.existsSync()) await f.delete();
  }
  // The key goes too. Keeping one that opens nothing only makes the next
  // failure harder to read.
  await const DbKeyStore().clear();
}

Future<AppDatabase> openAppDatabase({DbKeyStore? keys, DeviceIdStore? devices}) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'little_loaf.db'));
  final key = await (keys ?? const DbKeyStore()).readOrCreate();

  // A snapshot parked by the restore screen is swapped in here, before
  // anything holds the old file open. Ordinary launches find nothing staged
  // and this costs one `existsSync`.
  final restored =
      await applyPendingRestore(dir: dir, dbFile: file, hexKey: key);
  if (restored) await (devices ?? const DeviceIdStore()).rotate();

  return AppDatabase(
    NativeDatabase.createInBackground(
      file,
      setup: (db) => _setup(db, key),
    ),
  );
}

void _setup(Database db, String hexKey) {
  // SQLCipher must be keyed before anything else touches the file.
  db.execute("PRAGMA key = \"x'$hexKey'\"");

  // The real check. A plain SQLite build accepts `PRAGMA key` in silence and
  // returns nothing for `cipher_version`, so this is the only thing standing
  // between an encrypted database and a cleartext one that looks identical.
  final version = db.select('PRAGMA cipher_version');
  if (version.isEmpty || '${version.first.values.first}'.trim().isEmpty) {
    throw StateError(
      'SQLCipher is not loaded, so the database would be written in cleartext. '
      'Check the `hooks: user_defines: sqlite3: source: sqlcipher` block in '
      'pubspec.yaml, and that no package has pulled sqlite3_flutter_libs back '
      'in alongside it.',
    );
  }

  // Reads the header, so it fails here rather than with a confusing error later
  // if the key is wrong.
  db.execute('SELECT count(*) FROM sqlite_master');
  db.execute('PRAGMA journal_mode = WAL');
  db.execute('PRAGMA foreign_keys = ON');
  db.execute('PRAGMA busy_timeout = 5000');
}

/// An unencrypted in-memory database, for tests.
AppDatabase openTestDatabase() => AppDatabase(NativeDatabase.memory());
