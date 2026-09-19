import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/platform/backup/restore.dart';
import 'package:little_loaf/platform/backup/snapshot.dart';
import 'package:little_loaf/platform/storage/connection.dart';
import 'package:little_loaf/platform/storage/database.dart';
import 'package:little_loaf/platform/sync/background.dart';
import 'package:little_loaf/platform/sync/remote_store.dart';
import 'package:sqlite3/sqlite3.dart';

/// The nightly backup and the way back from it.
/// docs/01-platform/backup/lld.md §7
/// Whether the sqlite3 under the tests is SQLCipher. It is, in this repo —
/// the pubspec build hook says so — but a check beats an assumption, and the
/// two branches of [exportTo] both need to be honest.
final bool _cipherAvailable = () {
  final db = sqlite3.openInMemory();
  try {
    final rows = db.select('PRAGMA cipher_version');
    return rows.isNotEmpty && '${rows.first.values.first}'.trim().isNotEmpty;
  } finally {
    db.close();
  }
}();

void main() {
  late AppDatabase db;
  late InMemoryRemoteStore store;
  late Directory work;

  setUp(() async {
    db = openTestDatabase();
    await db.select(db.settings).getSingle(); // force onCreate
    store = InMemoryRemoteStore();
    work = await Directory.systemTemp.createTemp('loaf-snap');
  });

  tearDown(() async {
    await db.close();
    if (work.existsSync()) await work.delete(recursive: true);
  });

  SnapshotService service({
    String deviceId = 'me',
    int keep = 14,
    DateTime? on,
  }) =>
      SnapshotService(
        db: db,
        store: store,
        deviceId: deviceId,
        workDir: work,
        keep: keep,
        clock: () => on ?? DateTime(2026, 9, 20, 0, 2),
      );

  Future<void> addCustomer(String name) => db.into(db.customers).insert(
        CustomersCompanion.insert(
          id: name,
          deviceId: 'me',
          createdAt: 1,
          updatedAtHlc: '1:0:me',
          name: name,
          phoneE164: '+9198765$name',
        ),
      );

  group('taking one', () {
    test('the first device to arrive claims the job and uploads', () async {
      final result = await service().run();

      expect(result.outcome, SnapshotOutcome.uploaded);
      expect(result.name, '2026-09-20.db');
      expect(store.snapshots.keys, contains('2026-09-20.db'));

      final owner = SnapshotOwner.parse(store.snapshotMeta)!;
      expect(owner.deviceId, 'me');
      expect(owner.lastSnapshotAt, isNotNull);
    });

    test('another device skips, and touches nothing', () async {
      await service(deviceId: 'phone').run();
      final before = store.snapshotMeta;

      final result = await service(deviceId: 'tablet').run();
      expect(result.outcome, SnapshotOutcome.notOwner);
      expect(store.snapshots, hasLength(1));
      expect(store.snapshotMeta, before, reason: 'the owner file is untouched');
    });

    test('the snapshot holds the records and not the local state', () async {
      await addCustomer('asha');
      await db.into(db.outbox).insert(OutboxCompanion.insert(
            opId: 'op1',
            seq: 1,
            hlc: '1:0:me',
            entity: 'customers',
            entityId: 'asha',
            kind: 'upsert',
            payload: '{}',
            schemaV: kSchemaVersion,
          ));
      await db.into(db.peerCursors).insert(
          PeerCursorsCompanion.insert(peerDeviceId: 'phone', lastSeq: const Value(7)));
      await (db.update(db.settings)).write(
          const SettingsCompanion(orderSeq: Value(31), invoiceSeq: Value(12)));

      final file = File('${work.path}/out.db');
      await exportTo(db, file.path);

      final copy = sqlite3.open(file.path);
      addTearDown(copy.close);
      expect(copy.select('SELECT name FROM customers').single['name'], 'asha');
      expect(copy.select('SELECT * FROM outbox'), isEmpty,
          reason: 'the outbox is this device\'s, not the bakery\'s');
      expect(copy.select('SELECT * FROM peer_cursors'), isEmpty);
      expect(copy.select('SELECT * FROM applied_ops'), isEmpty);

      final settings = copy.select('SELECT * FROM settings').single;
      expect(settings['order_seq'], 0);
      expect(settings['invoice_seq'], 0,
          reason: 'the counters are local — a restore has to start its own');
    });

    test('through_seq claims only what a peer could have read', () async {
      for (final (seq, uploaded) in [(1, true), (2, true), (3, false)]) {
        await db.into(db.outbox).insert(OutboxCompanion.insert(
              opId: 'op$seq',
              seq: seq,
              hlc: '$seq:0:me',
              entity: 'customers',
              entityId: 'c',
              kind: 'upsert',
              payload: '{}',
              schemaV: kSchemaVersion,
              uploadedAt: Value(uploaded ? 100 : null),
            ));
      }

      await service().run();
      final owner = SnapshotOwner.parse(store.snapshotMeta)!;
      expect(owner.throughSeq['me'], 2,
          reason: 'op 3 has never been on Drive, so nothing may drop it');
    });

    test('keeps the newest fourteen', () async {
      for (var d = 1; d <= 16; d++) {
        store.snapshots['2026-08-${d.toString().padLeft(2, '0')}.db'] = [1];
      }
      final result = await service(keep: 14).run();

      expect(result.pruned, 3, reason: '16 old + 1 new, keeping 14');
      expect(store.snapshots.keys, isNot(contains('2026-08-01.db')));
      expect(store.snapshots.keys, contains('2026-08-16.db'));
      expect(store.snapshots.keys, contains('2026-09-20.db'));
    });

    test('a failed upload is reported, not swallowed', () async {
      store.failNextWrite = StateError('drive is full');
      final result = await service().run();
      expect(result.outcome, SnapshotOutcome.failed);
      expect(result.error, isStateError);
    });

    test('nothing is left behind in the work directory', () async {
      await service().run();
      expect(work.listSync(), isEmpty);
    });
  });

  group('staleness', () {
    final now = DateTime(2026, 9, 20).millisecondsSinceEpoch;

    test('a snapshot from this morning is fine', () {
      final owner = SnapshotOwner(
        deviceId: 'phone',
        claimedAt: 0,
        lastSnapshotAt: now - const Duration(hours: 9).inMilliseconds,
      );
      expect(owner.isStaleAt(now), isFalse);
    });

    test('four days of silence is worth saying out loud', () {
      final owner = SnapshotOwner(
        deviceId: 'phone',
        claimedAt: 0,
        lastSnapshotAt: now - const Duration(days: 4).inMilliseconds,
      );
      expect(owner.isStaleAt(now), isTrue);
    });

    test('claimed but never taken is stale from the start', () {
      expect(
          const SnapshotOwner(deviceId: 'phone', claimedAt: 0).isStaleAt(now),
          isTrue);
    });
  });

  group('restore', () {
    test('offers what is there, newest first', () async {
      store.snapshots['2026-09-18.db'] = [1];
      store.snapshots['2026-09-20.db'] = [1];
      store.snapshots['2026-09-19.db'] = [1];

      final choices = await RestoreService(store: store, dir: work).available();
      expect([for (final c in choices) c.name],
          ['2026-09-20.db', '2026-09-19.db', '2026-09-18.db']);
    });

    test('a snapshot from a newer app is refused, and nothing is staged',
        () async {
      final source = File('${work.path}/future.db');
      final raw = sqlite3.open(source.path);
      raw.execute('PRAGMA user_version = ${kSchemaVersion + 1}');
      raw.execute('CREATE TABLE t (a)');
      raw.close();
      store.snapshots['2027-01-01.db'] = await source.readAsBytes();

      final restore = RestoreService(store: store, dir: work);
      await expectLater(
        restore.stage('2027-01-01.db'),
        throwsA(isA<RestoreRefused>()),
      );
      expect(await restore.hasStaged(), isFalse,
          reason: 'a refusal must leave the device with what it had');
    });

    test('a damaged snapshot is refused', () async {
      store.snapshots['2026-09-20.db'] = utf8.encode('not a database at all');
      final restore = RestoreService(store: store, dir: work);
      await expectLater(
          restore.stage('2026-09-20.db'), throwsA(isA<Exception>()));
      expect(await restore.hasStaged(), isFalse);
    });

    test('staging parks the file and leaves the database alone', () async {
      await addCustomer('asha');
      await service().run();

      final restore = RestoreService(store: store, dir: work);
      await restore.stage('2026-09-20.db');

      expect(await restore.hasStaged(), isTrue);
      expect(File('${work.path}/$stagedFileName').existsSync(), isTrue);
    });

    test('the swap happens at the next open, and carries the records',
        () async {
      await addCustomer('asha');
      await service().run();
      await RestoreService(store: store, dir: work).stage('2026-09-20.db');

      final key = 'aa' * 32;
      final live = File('${work.path}/little_loaf.db');
      final old = sqlite3.open(live.path);
      old.execute('CREATE TABLE stale (a)');
      old.close();

      final happened =
          await applyPendingRestore(dir: work, dbFile: live, hexKey: key);
      expect(happened, isTrue);

      // Opened the way the app opens it. Reading it without the key is the
      // next test's job.
      final after = sqlite3.open(live.path);
      addTearDown(after.close);
      if (_cipherAvailable) after.execute('PRAGMA key = "x\'$key\'"');
      expect(after.select('SELECT name FROM customers').single['name'], 'asha');
      expect(
          after.select(
              "SELECT name FROM sqlite_master WHERE name = 'stale'"),
          isEmpty,
          reason: 'the old database is gone, not merged with');
      expect(File('${work.path}/$stagedFileName').existsSync(), isFalse);
    });

    test('the restored database is encrypted with this device\'s own key',
        () async {
      if (!_cipherAvailable) return; // a plain build cannot encrypt anything
      await addCustomer('asha');
      await service().run();
      await RestoreService(store: store, dir: work).stage('2026-09-20.db');

      final live = File('${work.path}/little_loaf.db');
      await applyPendingRestore(dir: work, dbFile: live, hexKey: 'bb' * 32);

      final unkeyed = sqlite3.open(live.path);
      addTearDown(unkeyed.close);
      expect(() => unkeyed.select('SELECT name FROM customers'),
          throwsA(isA<SqliteException>()),
          reason: 'the snapshot travels in the clear; what lands does not');
    });

    test('an ordinary launch does nothing', () async {
      final live = File('${work.path}/little_loaf.db');
      expect(
          await applyPendingRestore(
              dir: work, dbFile: live, hexKey: 'aa' * 32),
          isFalse);
      expect(live.existsSync(), isFalse);
    });
  });

  group('when the nightly job runs', () {
    test('00:02 IST tonight, from an afternoon in India', () {
      // 14:00 IST = 08:30 UTC
      final afternoon = DateTime.utc(2026, 9, 20, 8, 30);
      expect(untilNextSnapshot(afternoon), const Duration(hours: 10, minutes: 2));
    });

    test('tomorrow, when it has only just passed', () {
      // 00:05 IST = 18:35 UTC the previous day
      final justAfter = DateTime.utc(2026, 9, 19, 18, 35);
      expect(untilNextSnapshot(justAfter),
          const Duration(hours: 23, minutes: 57));
    });

    test('a tablet on another clock still keeps Indian dates', () {
      // The same instant, read on a device set to UTC. The answer must not
      // change: the file is named for the Indian day.
      final instant = DateTime.utc(2026, 9, 20, 8, 30);
      expect(untilNextSnapshot(instant.toLocal()),
          untilNextSnapshot(instant));
    });
  });
}
