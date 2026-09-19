import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/platform/backup/snapshot.dart';
import 'package:little_loaf/platform/sync/op.dart';
import 'package:little_loaf/platform/sync/remote_store.dart';

import '../support/harness.dart';

/// Journals only shrink when the ops leaving them are safe somewhere else.
///
/// Both conditions have to hold: the op is inside the snapshot, *and* every
/// live peer has already read it. Either one alone loses data, and each test
/// here removes one of them.
/// docs/01-platform/sync/lld.md §6
void main() {
  late InMemoryRemoteStore store;
  late SyncDevice alice;
  late SyncDevice bob;
  late Directory work;

  setUp(() async {
    store = InMemoryRemoteStore();
    alice = await SyncDevice.make('alice', store);
    bob = await SyncDevice.make('bob', store);
    work = await Directory.systemTemp.createTemp('loaf-compact');
  });

  tearDown(() async {
    await alice.close();
    await bob.close();
    if (work.existsSync()) await work.delete(recursive: true);
  });

  Future<void> snapshot(SyncDevice by) => SnapshotService(
        db: by.services.db,
        store: store,
        deviceId: by.id,
        workDir: work,
      ).run();

  Future<int> journalLength(String deviceId) async {
    final text = store.journals[deviceId];
    if (text == null) return 0;
    return decodeJournal(text).ops.length;
  }

  Future<void> write(SyncDevice by, String name) => by.services.customers
      .findOrCreate(name: name, phoneE164: '+91987654${name.length}$name');

  test('nothing compacts before a snapshot exists', () async {
    await write(alice, 'Asha');
    await alice.engine.sync();
    await bob.engine.sync(); // bob reads it, so the peer half is satisfied
    await alice.engine.sync();

    final report = await alice.engine.sync();
    expect(report.compacted, 0);
    expect(await journalLength('alice'), greaterThan(0),
        reason: 'the journal is the only copy until a snapshot is taken');
  });

  test('nothing compacts while a live peer is behind', () async {
    await write(alice, 'Asha');
    await alice.engine.sync();
    await snapshot(alice);
    // bob exists and is live, but has never read alice's journal.
    await bob.engine.sync();
    store.meta['bob'] = jsonEncode({
      'device_id': 'bob',
      'last_seen_at': DateTime.now().millisecondsSinceEpoch,
      'cursors': <String, int>{}, // has read nothing of ours
    });

    final report = await alice.engine.sync();
    expect(report.compacted, 0);
    expect(await journalLength('alice'), greaterThan(0));
  });

  test('an op leaves the journal once it is in a snapshot and read by all',
      () async {
    await write(alice, 'Asha');
    await alice.engine.sync();
    await bob.engine.sync(); // reads it and publishes its cursor
    await snapshot(alice);

    final before = await journalLength('alice');
    expect(before, greaterThan(0));

    final report = await alice.engine.sync();
    expect(report.compacted, before);
    expect(await journalLength('alice'), 0);
  });

  test('the header says where the journal now starts', () async {
    await write(alice, 'Asha');
    await alice.engine.sync();
    await bob.engine.sync();
    await snapshot(alice);
    await alice.engine.sync();

    final header = decodeJournal(store.journals['alice']!).header!;
    expect(header.compactedThroughSeq, greaterThanOrEqualTo(1),
        reason: 'a reader must tell "already in the snapshot" from "missing"');
  });

  test('a peer nobody has seen for a month stops holding the journal back',
      () async {
    await write(alice, 'Asha');
    await alice.engine.sync();
    await snapshot(alice);

    // bob has a folder and a cursor of nothing, but was last seen in July.
    store.meta['bob'] = jsonEncode({
      'device_id': 'bob',
      'last_seen_at': DateTime.now()
          .subtract(const Duration(days: 45))
          .millisecondsSinceEpoch,
      'cursors': <String, int>{},
    });

    final report = await alice.engine.sync();
    expect(report.compacted, greaterThan(0),
        reason: 'one lost phone must not make every journal grow forever');
  });

  test('a peer folder with no device.json is treated as having read nothing',
      () async {
    await write(alice, 'Asha');
    await alice.engine.sync();
    await snapshot(alice);
    store.journals['carol'] = ''; // a folder, and nothing else

    final report = await alice.engine.sync();
    expect(report.compacted, 0,
        reason: 'unknown is not the same as caught up');
  });

  test('what compacted is still readable by a peer that had already read it',
      () async {
    await write(alice, 'Asha');
    await alice.engine.sync();
    await bob.engine.sync();
    await snapshot(alice);
    await alice.engine.sync(); // compacts

    // bob syncs again against the now-empty journal and keeps what it had.
    final after = await bob.engine.sync();
    expect(after.ok, isTrue);
    expect((await bob.fixture.rows('customers')), hasLength(1));

    // and a new write still gets through
    await write(alice, 'Ravi');
    await alice.engine.sync();
    await bob.engine.sync();
    expect((await bob.fixture.rows('customers')), hasLength(2));
  });
}
