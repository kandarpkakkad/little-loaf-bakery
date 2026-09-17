import 'dart:convert';

import 'package:drift/drift.dart';

import '../../common/hlc.dart';
import '../../common/ids.dart';
import '../storage/database.dart';
import 'op.dart';

/// The single door every write goes through.
///
/// A write is two things that must not come apart: the row in SQLite, and the
/// op in the outbox that will carry that row to the other devices. Both happen
/// in one transaction, so a crash can never leave a change that is visible
/// here and invisible everywhere else.
///
/// docs/01-platform/sync/lld.md
class Mutations {
  Mutations(this.db, {required this.deviceId, required Hlc lastHlc, required int lastSeq})
      : _last = lastHlc,
        _seq = lastSeq;

  final AppDatabase db;
  final String deviceId;
  Hlc _last;
  int _seq;

  /// Rebuilds the clock and the sequence from what is already on disk, so a
  /// restart never re-issues a timestamp or a sequence number it has used.
  static Future<Mutations> restore(AppDatabase db, {required String deviceId}) async {
    final rows = await (db.select(db.outbox)
          ..orderBy([(o) => OrderingTerm.desc(o.seq)])
          ..limit(1))
        .get();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    return Mutations(
      db,
      deviceId: deviceId,
      lastHlc: rows.isEmpty ? Hlc(nowMs, 0, deviceId) : Hlc.parse(rows.first.hlc),
      lastSeq: rows.isEmpty ? 0 : rows.first.seq,
    );
  }

  Hlc get lastHlc => _last;

  Hlc tick() {
    _last = Hlc.issue(
      nowMs: DateTime.now().millisecondsSinceEpoch,
      last: _last,
      deviceId: deviceId,
    );
    return _last;
  }

  /// Fold a peer's timestamp into our clock, so the next local write can never
  /// sort before an op we have already received. Called for every op applied.
  void observe(Hlc remote) {
    _last = Hlc.observe(
      nowMs: DateTime.now().millisecondsSinceEpoch,
      last: _last,
      remote: remote,
      deviceId: deviceId,
    );
  }

  /// The highest sequence number handed out so far. Sync needs it to know what
  /// it has uploaded.
  int get lastSeq => _seq;

  /// Record an op. Call inside the same transaction as the row write.
  Future<void> record(
    String entity,
    String entityId,
    OpKind kind,
    Map<String, Object?> fields,
  ) async {
    final hlc = tick();
    _seq += 1;
    await db.into(db.outbox).insert(OutboxCompanion.insert(
          opId: Uuid7.generate(),
          seq: _seq,
          hlc: hlc.toString(),
          entity: entity,
          entityId: entityId,
          kind: kind.name,
          payload: jsonEncode(fields),
          schemaV: kSchemaVersion,
        ));
  }

  /// How many local changes have not yet reached Drive — the number the sync
  /// strip shows.
  Stream<int> watchPending() {
    final q = db.selectOnly(db.outbox)
      ..addColumns([db.outbox.opId.count()])
      ..where(db.outbox.uploadedAt.isNull());
    return q.map((r) => r.read(db.outbox.opId.count()) ?? 0).watchSingle();
  }
}
