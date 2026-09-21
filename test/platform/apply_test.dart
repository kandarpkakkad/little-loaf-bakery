import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/hlc.dart';
import 'package:little_loaf/platform/sync/op.dart';

import '../support/harness.dart';

/// Applying a peer's ops — the half of sync that feeds merge.dart.
/// docs/01-platform/sync/lld.md §5
void main() {
  late AppServicesFixture f;

  setUp(() async => f = await AppServicesFixture.make());
  tearDown(() => f.close());

  Op upsert(
    String entity,
    String id,
    Map<String, Object?> fields, {
    required int wallMs,
    String device = 'peer-device',
    int seq = 1,
  }) =>
      Op(
        opId: '$device-$seq-$id-$wallMs',
        seq: seq,
        hlc: Hlc(wallMs, 0, device),
        entity: entity,
        entityId: id,
        kind: OpKind.upsert,
        fields: fields,
        schemaV: 8,
      );

  test('an applied op wakes the streams the screens watch', () async {
    // Every screen is fed by watch(), never by get(), so this is the assertion
    // that decides whether sync is visible. Raw SQL that does not name its
    // table writes the row and tells drift nothing: the row is there, the
    // stream never re-emits, and a peer's changes stay invisible until the app
    // is restarted. The whole suite asserted on get() and saw nothing wrong.
    final db = f.services.db;
    final counts = <int>[];
    final sub = db.select(db.menuItems).watch().listen((r) => counts.add(r.length));
    await pumpEventQueue();

    await f.applier.apply(upsert('menu_items', 'm1', {
      'name': 'Focaccia',
      'lead_days': 0,
      'active': true,
    }, wallMs: 1000));
    await pumpEventQueue();
    await sub.cancel();

    expect(counts, [0, 1], reason: 'the stream must re-emit with the new row');
  });

  test('an unseen row arrives as an insert', () async {
    await f.applier.apply(upsert('customers', 'c1', {
      'name': 'Asha Rao',
      'phone_e164': '+919876543210',
    }, wallMs: 1000));

    final row = await f.row('customers', 'c1');
    expect(row!['name'], 'Asha Rao');
    expect(row['phone_e164'], '+919876543210');
    // common columns come from the op, not from now()
    expect(row['created_at'], 1000);
    expect(row['device_id'], 'peer-device');
  });

  /// A real create op carries every NOT NULL column, because the repositories
  /// record the whole row when they insert it.
  Op create(String id, {required int wallMs, String name = 'Asha'}) =>
      upsert('customers', id,
          {'name': name, 'phone_e164': '+919876543210'}, wallMs: wallMs);

  test('applying the same op twice changes nothing', () async {
    final op = create('c1', wallMs: 1000);
    expect(await f.applier.apply(op), isTrue);
    expect(await f.applier.apply(op), isFalse, reason: 'second apply is a no-op');
    expect((await f.rows('customers')).length, 1);
  });

  test('a later op wins the field, an earlier one does not', () async {
    await f.applier.apply(create('c1', wallMs: 1000));
    await f.applier
        .apply(upsert('customers', 'c1', {'name': 'Asha Rao'}, wallMs: 2000, seq: 2));
    expect((await f.row('customers', 'c1'))!['name'], 'Asha Rao');

    // arrives late, carrying an older timestamp
    await f.applier
        .apply(upsert('customers', 'c1', {'name': 'STALE'}, wallMs: 1500, seq: 3));
    expect((await f.row('customers', 'c1'))!['name'], 'Asha Rao',
        reason: 'an older HLC must not overwrite a newer field');
  });

  test('two devices editing different fields both keep their change', () async {
    await f.applier.apply(upsert('customers', 'c1', {
      'name': 'Asha',
      'phone_e164': '+911111111111',
    }, wallMs: 1000));

    await f.applier.apply(upsert('customers', 'c1', {'name': 'Asha Rao'},
        wallMs: 2000, device: 'device-a', seq: 2));
    await f.applier.apply(upsert('customers', 'c1', {'notes': 'prefers evening'},
        wallMs: 2000, device: 'device-b', seq: 3));

    final row = await f.row('customers', 'c1');
    expect(row!['name'], 'Asha Rao');
    expect(row['notes'], 'prefers evening');
    expect(row['phone_e164'], '+911111111111', reason: 'untouched field survives');
  });

  test('a field this build has never heard of is dropped, not fatal', () async {
    await f.applier.apply(upsert('customers', 'c1', {
      'name': 'Asha',
      'phone_e164': '+919876543210',
      'loyalty_tier': 'gold', // a column from some future schema
    }, wallMs: 1000));

    final row = await f.row('customers', 'c1');
    expect(row!['name'], 'Asha', reason: 'the known fields still applied');
    expect(row.containsKey('loyalty_tier'), isFalse);
  });

  test('an entity this build does not have is skipped without throwing', () async {
    final ok = await f.applier.apply(
        upsert('loyalty_cards', 'x1', {'points': 10}, wallMs: 1000));
    expect(ok, isFalse);
  });

  test('a delete tombstones the row', () async {
    await f.applier.apply(create('c1', wallMs: 1000));
    await f.applier.apply(Op(
      opId: 'del-1',
      seq: 2,
      hlc: Hlc(2000, 0, 'peer-device'),
      entity: 'customers',
      entityId: 'c1',
      kind: OpKind.delete,
      fields: const {},
      schemaV: 8,
    ));
    expect((await f.row('customers', 'c1'))!['deleted_at'], isNotNull);
  });

  test('a stale delete cannot erase a row edited after it', () async {
    await f.applier.apply(create('c1', wallMs: 1000));
    await f.applier
        .apply(upsert('customers', 'c1', {'name': 'Asha Rao'}, wallMs: 3000, seq: 2));

    // the delete was issued before that edit and arrives afterwards
    await f.applier.apply(Op(
      opId: 'del-late',
      seq: 3,
      hlc: Hlc(2000, 0, 'peer-device'),
      entity: 'customers',
      entityId: 'c1',
      kind: OpKind.delete,
      fields: const {},
      schemaV: 8,
    ));

    final row = await f.row('customers', 'c1');
    expect(row!['deleted_at'], isNull, reason: 'the newer edit revived the row');
    expect(row['name'], 'Asha Rao');
  });

  test('overwriting a divergent value is recorded in the conflict log', () async {
    await f.applier.apply(create('c1', wallMs: 1000));
    await f.applier.apply(upsert('customers', 'c1', {'name': 'Aasha'},
        wallMs: 2000, device: 'device-b', seq: 2));

    final conflicts = await f.rows('conflict_log');
    expect(conflicts, hasLength(1));
    expect(conflicts.first['field'], 'name');
    expect(conflicts.first['winner'], 'remote');
  });

  test('an edit for a row we have never seen is kept for retry, not lost',
      () async {
    // no create op first: phone_e164 is NOT NULL, so this cannot be inserted
    final edit = upsert('customers', 'c9', {'name': 'Later'}, wallMs: 1000);
    expect(await f.applier.apply(edit), isFalse);
    expect(await f.rows('applied_ops'), isEmpty,
        reason: 'unapplied, so a later pull can retry it in order');

    // once the creating op arrives, the retry succeeds
    await f.applier.apply(create('c9', wallMs: 900, name: 'Original'));
    expect(await f.applier.apply(edit), isTrue);
    expect((await f.row('customers', 'c9'))!['name'], 'Later');
  });

  test('a peer timestamp from the future drags our clock forward', () async {
    final future = DateTime.now().millisecondsSinceEpoch + 60000;
    await f.applier.apply(create('c1', wallMs: future));
    expect(f.services.mutations.lastHlc.wallMs, greaterThanOrEqualTo(future),
        reason: 'our next local write must sort after the op we just applied');
  });
}
