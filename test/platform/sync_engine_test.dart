import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/hlc.dart';
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
