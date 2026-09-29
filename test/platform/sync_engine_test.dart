import 'dart:convert';

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
