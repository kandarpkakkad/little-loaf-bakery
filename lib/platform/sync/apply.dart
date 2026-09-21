import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:sqlite3/common.dart' show SqliteException;

import '../../common/hlc.dart';
import '../storage/database.dart';
import 'merge.dart';
import 'mutations.dart';
import 'op.dart';

/// Writes a peer's ops into this device's database.
///
/// This is the half of sync that `merge.dart` was always waiting for: the
/// merge rules decide *which* fields win, and this decides how the winners
/// reach SQLite.
///
/// Everything here is generic over the entity name rather than typed per
/// table. A typed switch over eighteen tables would have to be edited every
/// time the schema grows, and the version it was edited in is exactly the
/// version a peer will not be running. Instead the column list is read from
/// the database itself, and any field the local build does not recognise is
/// dropped — which is what makes an older reader survive a newer writer.
/// docs/01-platform/sync/lld.md §5
class OpApplier {
  OpApplier(this.db, this.mutations);

  final AppDatabase db;
  final Mutations mutations;

  /// entity name → its columns, read once per entity and cached. Entities are
  /// named exactly as their tables.
  final Map<String, Set<String>> _columns = {};

  Future<Set<String>> _columnsOf(String entity) async {
    final cached = _columns[entity];
    if (cached != null) return cached;
    final rows =
        await db.customSelect('PRAGMA table_info($entity)').get();
    final names = rows.map((r) => r.read<String>('name')).toSet();
    _columns[entity] = names;
    return names;
  }

  /// entity name → the drift table object, so a raw write can say what it
  /// touched. Cached alongside the columns, and for the same reason.
  final Map<String, Set<ResultSetImplementation<dynamic, dynamic>>> _tables = {};

  /// Raw SQL is invisible to drift's stream queries. A `customUpdate` that does
  /// not name its tables writes the row and tells nothing, so every open
  /// `.watch()` on that table goes on serving the rows it already had. Every
  /// screen in the app is fed by those streams, so without this an op lands in
  /// SQLite and stays invisible until the app is restarted — sync working
  /// perfectly and looking completely broken.
  Set<ResultSetImplementation<dynamic, dynamic>> _updates(String entity) =>
      _tables.putIfAbsent(entity, () {
        for (final t in db.allTables) {
          if (t.actualTableName == entity) return {t};
        }
        // An entity this build does not have. The write will not happen
        // either, so there is nothing to announce.
        return const {};
      });

  /// True for tables carrying `field_hlc_json` — the ones edited from more
  /// than one place, where per-field timestamps are worth the space.
  Future<bool> _hasFieldHlc(String entity) async =>
      (await _columnsOf(entity)).contains('field_hlc_json');

  /// Applies one op. Idempotent: an op already in `applied_ops` is a no-op, so
  /// re-reading a peer's journal after a partial sync cannot double-apply.
  ///
  /// Returns false when the op was skipped, so the caller can still advance its
  /// cursor past ops it has already seen.
  Future<bool> apply(Op op) async {
    final known = await (db.select(db.appliedOps)
          ..where((t) => t.opId.equals(op.opId)))
        .getSingleOrNull();
    if (known != null) return false;

    // An unknown entity means the peer is running a newer schema. Skipping is
    // right: the op is recorded as applied so it is not retried forever, and
    // the row it describes simply does not exist here yet.
    final columns = await _columnsOf(op.entity);
    if (columns.isEmpty) {
      await _markApplied(op);
      return false;
    }

    var applied = false;
    await db.transaction(() async {
      // Never lag a peer's clock, or our next local write could sort before
      // the op we just received.
      mutations.observe(op.hlc);

      applied = switch (op.kind) {
        OpKind.upsert => await _upsert(op, columns),
        OpKind.delete => await _tombstone(op, columns),
      };
      // Deliberately not marked when the op could not be applied: it stays
      // unapplied so a later pull, once the op that creates the row has
      // arrived, can retry it.
      if (applied) await _markApplied(op);
    });
    return applied;
  }

  Future<void> _markApplied(Op op) => db.into(db.appliedOps).insert(
        AppliedOpsCompanion.insert(
          opId: op.opId,
          appliedAt: DateTime.now().millisecondsSinceEpoch,
        ),
        mode: InsertMode.insertOrIgnore,
      );

  Future<Map<String, Object?>?> _load(String entity, String id) async {
    final rows = await db.customSelect(
      'SELECT * FROM $entity WHERE id = ? LIMIT 1',
      variables: [Variable.withString(id)],
    ).get();
    return rows.isEmpty ? null : rows.first.data;
  }

  /// Returns false when the op cannot be applied yet.
  Future<bool> _upsert(Op op, Set<String> columns) async {
    // Fields the local schema does not have are dropped rather than failing the
    // whole op — a newer peer may be sending columns this build never heard of.
    final incoming = <String, Object?>{
      for (final e in op.fields.entries)
        if (columns.contains(e.key)) e.key: e.value,
    };

    final existing = await _load(op.entity, op.entityId);

    if (existing == null) return _insert(op, incoming, columns);

    final rowHlc = Hlc.parse(existing['updated_at_hlc'] as String);
    final result = mergeFields(
      op: Op(
        opId: op.opId,
        seq: op.seq,
        hlc: op.hlc,
        entity: op.entity,
        entityId: op.entityId,
        kind: op.kind,
        fields: incoming,
        schemaV: op.schemaV,
      ),
      localRow: existing,
      rowHlc: rowHlc,
      fieldHlcJson: (await _hasFieldHlc(op.entity))
          ? existing['field_hlc_json'] as String?
          : null,
    );

    for (final note in result.conflicts) {
      await _logConflict(op, note);
    }
    // Every field lost to a newer local value. The op is still applied — it has
    // been seen and should not be reconsidered.
    if (result.accepted.isEmpty) return true;

    await _write(op, result.accepted, existing);
    return true;
  }

  /// A row this device has never seen. Common columns come from the op's own
  /// metadata, not from now(), so two devices inserting the same row from the
  /// same op agree on every column.
  Future<bool> _insert(
      Op op, Map<String, Object?> incoming, Set<String> columns) async {
    final row = <String, Object?>{
      'id': op.entityId,
      if (columns.contains('device_id')) 'device_id': op.hlc.deviceId,
      if (columns.contains('created_at')) 'created_at': op.hlc.wallMs,
      if (columns.contains('updated_at_hlc')) 'updated_at_hlc': op.hlc.toString(),
      ...incoming,
    };
    final cols = row.keys.toList();
    final placeholders = List.filled(cols.length, '?').join(', ');
    try {
      await db.customInsert(
        'INSERT INTO ${op.entity} (${cols.join(', ')}) VALUES ($placeholders)',
        variables: [for (final c in cols) _bind(row[c])],
        updates: _updates(op.entity),
      );
      return true;
    } on SqliteException {
      // Almost always a NOT NULL or FOREIGN KEY column this op does not carry,
      // which means it is an *edit* to a row whose creating op has not arrived
      // yet. Deliberately not INSERT OR IGNORE: that swallows the same failure
      // in silence and loses the change for good. Returning false leaves the op
      // unapplied so the next pull can retry it in order.
      return false;
    }
  }

  Future<void> _write(
      Op op, Map<String, Object?> accepted, Map<String, Object?> existing) async {
    final sets = <String>[];
    final vars = <Variable>[];

    for (final e in accepted.entries) {
      sets.add('${e.key} = ?');
      vars.add(_bind(e.value));
    }

    sets.add('updated_at_hlc = ?');
    vars.add(Variable.withString(op.hlc.toString()));

    if (await _hasFieldHlc(op.entity)) {
      final perField = <String, String>{
        ...?_decodeFieldHlc(existing['field_hlc_json'] as String?),
        for (final f in accepted.keys) f: op.hlc.toString(),
      };
      sets.add('field_hlc_json = ?');
      vars.add(Variable.withString(jsonEncode(perField)));
    }

    vars.add(Variable.withString(op.entityId));
    await db.customUpdate(
      'UPDATE ${op.entity} SET ${sets.join(', ')} WHERE id = ?',
      variables: vars,
      updates: _updates(op.entity),
    );
  }

  Map<String, String>? _decodeFieldHlc(String? json) {
    if (json == null) return null;
    try {
      return Map<String, String>.from(jsonDecode(json) as Map);
    } on FormatException {
      return null;
    }
  }

  /// Deletes are soft everywhere, so an old row can still be resolved by an
  /// order that points at it, and so the delete itself can replicate.
  Future<bool> _tombstone(Op op, Set<String> columns) async {
    // Nothing to tombstone, and nothing to wait for either.
    if (!columns.contains('deleted_at')) return true;
    final existing = await _load(op.entity, op.entityId);
    if (existing == null) return true;

    // A delete that lost the race to a later edit must not win. Without this a
    // stale tombstone could erase a row somebody has since revived.
    final rowHlc = Hlc.parse(existing['updated_at_hlc'] as String);
    if (op.hlc <= rowHlc) return true;

    await db.customUpdate(
      'UPDATE ${op.entity} SET deleted_at = ?, updated_at_hlc = ? WHERE id = ?',
      variables: [
        Variable.withInt(op.hlc.wallMs),
        Variable.withString(op.hlc.toString()),
        Variable.withString(op.entityId),
      ],
      updates: _updates(op.entity),
    );
    return true;
  }

  Future<void> _logConflict(Op op, ConflictNote note) =>
      db.into(db.conflictLog).insert(ConflictLogCompanion.insert(
            id: '${op.opId}:${note.field}',
            deviceId: mutations.deviceId,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            updatedAtHlc: op.hlc.toString(),
            entity: op.entity,
            entityId: op.entityId,
            field: note.field,
            localValue: Value('${note.localValue}'),
            remoteValue: Value('${note.remoteValue}'),
            winner: note.winner,
            reason: note.reason,
            at: DateTime.now().millisecondsSinceEpoch,
          ));

  /// drift's Variable needs the concrete type; JSON gives us dynamic.
  Variable _bind(Object? v) => switch (v) {
        null => const Variable<String>(null),
        final bool b => Variable.withInt(b ? 1 : 0),
        final int i => Variable.withInt(i),
        final double d => Variable.withReal(d),
        final String s => Variable.withString(s),
        // lists and maps survive as JSON rather than throwing
        _ => Variable.withString(jsonEncode(v)),
      };
}
