import 'dart:convert';

import 'dart:io';
import 'package:little_loaf/platform/backup/snapshot.dart';
import 'package:little_loaf/platform/sync/drive_auth.dart';
import 'package:little_loaf/platform/sync/sync_service.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/hlc.dart';
import 'package:little_loaf/common/money.dart';
import 'package:little_loaf/domain/orders/repository.dart';
import 'package:little_loaf/platform/sync/op.dart';
import 'package:little_loaf/platform/sync/remote_store.dart';

import '../support/harness.dart';

/// Two devices reaching the same state through a shared folder.
/// docs/01-platform/sync/lld.md §3–4
void main() {
  late InMemoryRemoteStore store;
  late SyncDevice alice;
  late SyncDevice bob;

  setUp(() async {
    store = InMemoryRemoteStore();
    alice = await SyncDevice.make('alice', store);
    bob = await SyncDevice.make('bob', store);
  });

  tearDown(() async {
    await alice.close();
    await bob.close();
  });

  test('a customer created on one device appears on the other', () async {
    await alice.services.customers
        .findOrCreate(name: 'Asha Rao', phoneE164: '+919876543210');

    final up = await alice.engine.sync();
    expect(up.uploaded, greaterThan(0));

    final down = await bob.engine.sync();
    expect(down.applied, greaterThan(0));

    final onBob = await bob.fixture.rows('customers');
    expect(onBob, hasLength(1));
    expect(onBob.first['name'], 'Asha Rao');
  });

  test('an order created on one device appears on the other', () async {
    // The customer test below passed for months while this one would have
    // failed: the orders op left out `fulfilment`, which is NOT NULL, so the
    // insert died on every peer and took the rest of that journal with it.
    // A creating op has to be able to create the row somewhere it has never
    // been seen, and only a two-device test says whether it can.
    final menuId = await alice.services.menu.create(name: 'Cake');
    final customerId = await alice.services.customers
        .findOrCreate(name: 'Asha Rao', phoneE164: '+919876543210');
    await alice.services.orders.create(
      customerId: customerId,
      lines: [
        DraftLine(
          menuItemId: menuId,
          itemName: 'Cake',
          basePrice: Money.rupees(800),
        )
      ],
      deliveryDate: dayAfter(2),
      deliveryTime: 600,
    );

    await alice.engine.sync();
    final down = await bob.engine.sync();

    expect(down.peerErrors, isEmpty, reason: 'the journal must stay readable');

    final onBob = await bob.fixture.rows('orders');
    expect(onBob, hasLength(1), reason: 'the order reached the other device');
    expect(onBob.first['fulfilment'], isNotNull);
    expect(onBob.first['delivery_date'], isNotNull);
    expect(await bob.fixture.rows('order_items'), hasLength(1));
  });

  test('a journal compacted past our cursor is reported, not passed over',
      () async {
    // A device joining an established bakery finds a journal that starts
    // mid-story: compaction may drop what a snapshot holds and every *live*
    // peer has read, and a device that did not exist yet was not one. Syncing
    // can never fill in the beginning — only a restore can — so the one thing
    // this must not do is look like a clean run.
    store.journals['carol'] = encodeJournal(
      const JournalHeader(
          deviceId: 'carol', minReaderVersion: 1, compactedThroughSeq: 40),
      [
        Op(
          opId: 'carol-41',
          seq: 41,
          hlc: const Hlc(1000, 0, 'carol'),
          entity: 'customers',
          entityId: 'c1',
          kind: OpKind.upsert,
          fields: const {'name': 'Asha', 'phone_e164': '+911'},
          schemaV: 16,
        )
      ],
    );

    final report = await bob.engine.sync();

    expect(report.peersMissingHistory, ['carol']);
    expect(report.peerErrors, isEmpty, reason: 'not an error, just a gap');
    expect(await bob.fixture.rows('customers'), hasLength(1),
        reason: 'what is still in the journal arrives as normal');
  });

  test('one op that cannot apply does not stop the rest of the journal',
      () async {
    // Reading used to stop dead at the first op that would not apply, which
    // is right for an edit whose creating op is still in flight and wrong
    // for one that can never apply: that peer's sync ended permanently, and
    // the op that would have repaired the row was the next line along.
    Op op(int seq, String entity, String id, Map<String, Object?> fields) => Op(
          opId: 'carol-$seq',
          seq: seq,
          hlc: Hlc(1000 + seq, 0, 'carol'),
          entity: entity,
          entityId: id,
          kind: OpKind.upsert,
          fields: fields,
          schemaV: 16,
        );

    store.journals['carol'] = encodeJournal(
      const JournalHeader(
          deviceId: 'carol', minReaderVersion: 1, compactedThroughSeq: -1),
      [
        // NOT NULL fulfilment missing: refused, now and for ever.
        op(1, 'orders', 'o1', {
          'order_no': 'LLB-0001',
          'customer_id': 'c1',
          'status': 'created',
        }),
        // Behind it, something perfectly applicable.
        op(2, 'customers', 'c1',
            {'name': 'Asha Rao', 'phone_e164': '+919876543210'}),
      ],
    );

    final report = await bob.engine.sync();
    expect(report.peerErrors, isEmpty);

    expect(await bob.fixture.rows('customers'), hasLength(1),
        reason: 'the reachable op behind the stuck one still applied');
    expect(await bob.fixture.rows('orders'), isEmpty);

    // And the stuck op is not abandoned: the cursor stays behind it, so a
    // later sync reads it again.
    final cursors = await bob.fixture.rows('peer_cursors');
    final carol = cursors.where((c) => c['peer_device_id'] == 'carol');
    expect(carol.isEmpty ? 0 : carol.first['last_seq'], 0,
        reason: 'the cursor must not advance past an unapplied op');
  });

  test('a sync re-queries the screens even when it applied nothing itself',
      () async {
    // The WorkManager worker opens its own connection to the same file, so
    // anything it pulls is invisible to this one — and since it also records
    // the ops as applied, the next foreground sync has nothing left to apply
    // and nothing to notify. The data then sits there until the app is killed.
    // So a sync assumes an outside write happened and makes the screens look
    // again. Here nothing is applied at all, and the stream must still fire.
    final db = bob.services.db;
    final seen = <int>[];
    final sub = db.select(db.customers).watch().listen((r) => seen.add(r.length));
    await pumpEventQueue();
    expect(seen, [0]);

    final dir = await Directory.systemTemp.createTemp('loaf-requery');
    final service = SyncService(
      db: db,
      mutations: bob.services.mutations,
      deviceId: bob.id,
      auth: _ConnectedAuth(),
      storeFactory: (_) => store,
      workDir: () async => dir,
    );
    await service.restore();
    final report = await service.syncNow();
    await pumpEventQueue();
    await sub.cancel();

    expect(report.applied, 0, reason: 'nothing came in through this connection');
    expect(seen, hasLength(2), reason: 'the screens looked again anyway');
  });

  test('a backup pulls first, so it holds the other device too', () async {
    // The point of ask: a snapshot is only worth what the database held when
    // it was taken. Bob backing up without pulling first writes a copy of
    // Bob's share of the bakery and calls it the bakery.
    await alice.services.customers
        .findOrCreate(name: 'Asha Rao', phoneE164: '+919876543210');
    await alice.engine.sync();

    // Bob has never pulled: Alice's customer is on Drive, not in his database.
    expect(await bob.fixture.rows('customers'), isEmpty);

    final dir = await Directory.systemTemp.createTemp('loaf-backup-check');
    final service = SyncService(
      db: bob.services.db,
      mutations: bob.services.mutations,
      deviceId: bob.id,
      auth: _ConnectedAuth(),
      storeFactory: (_) => store,
      workDir: () async => dir,
    );
    await service.restore();
    final run = await service.backUpNow();

    expect(run.snapshot.outcome, SnapshotOutcome.uploaded);
    expect(run.freshData, isTrue, reason: 'it pulled before it copied');
    expect(await bob.fixture.rows('customers'), hasLength(1),
        reason: "Alice's customer arrived on the way to the backup");

    // And the copy that went to Drive has her in it.
    final copy = File('${dir.path}/check.db')
      ..writeAsBytesSync(store.snapshots.values.last);
    final reopened = sqlite3.open(copy.path);
    try {
      expect(reopened.select('SELECT * FROM customers'), hasLength(1));
    } finally {
      reopened.close();
    }
  });

  test('uploading twice with no new writes does not rewrite the journal',
      () async {
    await alice.services.customers
        .findOrCreate(name: 'Asha', phoneE164: '+911111111111');
    await alice.engine.sync();
    final first = store.journals['alice'];

    final again = await alice.engine.sync();
    expect(again.uploaded, 0);
    expect(store.journals['alice'], first);
  });

  test('a failed upload leaves the ops pending for the next run', () async {
    await alice.services.customers
        .findOrCreate(name: 'Asha', phoneE164: '+911111111111');

    store.failNextWrite = Exception('network down');
    final failed = await alice.engine.sync();
    expect(failed.ok, isFalse);
    expect(store.journals.containsKey('alice'), isFalse);

    // nothing was marked uploaded, so the retry carries them
    final retry = await alice.engine.sync();
    expect(retry.ok, isTrue);
    expect(retry.uploaded, greaterThan(0));
    expect(store.journals.containsKey('alice'), isTrue);
  });

  test('edits on both devices converge on the same row', () async {
    final id = await alice.services.customers
        .findOrCreate(name: 'Asha', phoneE164: '+919876543210');
    await alice.engine.sync();
    await bob.engine.sync();

    // each device changes a different field
    await alice.services.customers.update(id, name: 'Asha Rao');
    await bob.services.customers.update(id, notes: 'prefers evening pickup');

    await alice.engine.sync();
    await bob.engine.sync();
    await alice.engine.sync();

    for (final d in [alice, bob]) {
      final row = await d.fixture.row('customers', id);
      expect(row!['name'], 'Asha Rao', reason: '${d.id} lost a name edit');
      expect(row['notes'], 'prefers evening pickup',
          reason: '${d.id} lost a notes edit');
    }
  });

  test('pulling the same journal twice applies nothing the second time',
      () async {
    await alice.services.customers
        .findOrCreate(name: 'Asha', phoneE164: '+919876543210');
    await alice.engine.sync();

    final first = await bob.engine.sync();
    final second = await bob.engine.sync();
    expect(first.applied, greaterThan(0));
    expect(second.applied, 0, reason: 'the cursor already passed those ops');
  });

  test('a peer needing a newer reader is skipped, not fatal', () async {
    // a journal from the future
    store.journals['carol'] = encodeJournal(
      const JournalHeader(
        deviceId: 'carol',
        minReaderVersion: 99,
        compactedThroughSeq: -1,
      ),
      [
        Op(
          opId: 'future-1',
          seq: 1,
          hlc: Hlc(1000, 0, 'carol'),
          entity: 'customers',
          entityId: 'c-future',
          kind: OpKind.upsert,
          fields: const {'name': 'Nope', 'phone_e164': '+910000000000'},
          schemaV: 999,
        ),
      ],
    );
    // and a normal peer alongside it
    await alice.services.customers
        .findOrCreate(name: 'Asha', phoneE164: '+919876543210');
    await alice.engine.sync();

    final report = await bob.engine.sync();
    expect(report.peersNeedingUpgrade, contains('carol'));
    expect(report.applied, greaterThan(0),
        reason: 'the readable peer still synced');
    expect(await bob.fixture.row('customers', 'c-future'), isNull);
  });

  test('a corrupt line does not lose the rest of the journal', () async {
    await alice.services.customers
        .findOrCreate(name: 'Asha', phoneE164: '+919876543210');
    await alice.engine.sync();

    final lines = store.journals['alice']!.split('\n');
    store.journals['alice'] = [...lines, '{ this is not json'].join('\n');

    final report = await bob.engine.sync();
    expect(report.ok, isTrue);
    expect(await bob.fixture.rows('customers'), hasLength(1));
  });

  test('device meta records what we have read, for compaction later', () async {
    await alice.services.customers
        .findOrCreate(name: 'Asha', phoneE164: '+919876543210');
    await alice.engine.sync();
    await bob.engine.sync();
    await bob.services.customers
        .findOrCreate(name: 'Bina', phoneE164: '+912222222222');
    await bob.engine.sync();

    final meta = jsonDecode(store.meta['bob']!) as Map<String, Object?>;
    expect(meta['device_id'], 'bob');
    expect((meta['cursors'] as Map)['alice'], greaterThan(0));
  });
}

/// A connected account, without Google. Only the two calls SyncService makes
/// on the way to a backup are answered.
class _ConnectedAuth extends DriveAuth {
  @override
  Future<String?> rememberedEmail() async => 'baker@example.com';

  @override
  Future<String?> silentToken() async => 'token';
}
