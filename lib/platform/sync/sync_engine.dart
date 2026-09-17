import 'dart:convert';

import 'package:drift/drift.dart';

import '../../common/hlc.dart';
import '../storage/database.dart';
import 'apply.dart';
import 'mutations.dart';
import 'op.dart';
import 'remote_store.dart';

/// What one sync run did. Returned rather than logged, so the UI can say
/// something specific and the tests can assert on it.
class SyncReport {
  const SyncReport({
    this.uploaded = 0,
    this.applied = 0,
    this.peersRead = 0,
    this.peersNeedingUpgrade = const [],
    this.error,
  });

  final int uploaded;
  final int applied;
  final int peersRead;

  /// Peers writing a journal this build is too old to read. Listed rather than
  /// thrown: one peer ahead of us must not stop the others syncing.
  final List<String> peersNeedingUpgrade;

  final Object? error;

  bool get ok => error == null;

  @override
  String toString() => ok
      ? 'synced: $uploaded up, $applied applied, $peersRead peers'
      : 'sync failed: $error';
}

/// Upload this device's outbox, then pull every peer's.
///
/// Single-flight: a second call while one is running is dropped rather than
/// queued, because the work is idempotent and the queued run would only repeat
/// it. docs/01-platform/sync/lld.md §3
class SyncEngine {
  SyncEngine({
    required this.db,
    required this.mutations,
    required this.store,
    required this.deviceId,
    OpApplier? applier,
  }) : applier = applier ?? OpApplier(db, mutations);

  final AppDatabase db;
  final Mutations mutations;
  final RemoteStore store;
  final String deviceId;
  final OpApplier applier;

  bool _running = false;

  /// The reader version a peer must be at to read what we write. Bumped only
  /// when the journal format changes in a way an older build would misread —
  /// adding fields does not count, because unknown fields are ignored.
  static const int kMinReaderVersion = 1;

  Future<SyncReport> sync() async {
    if (_running) return const SyncReport();
    _running = true;
    try {
      final uploaded = await _upload();
      final pull = await _pullAll();
      return SyncReport(
        uploaded: uploaded,
        applied: pull.applied,
        peersRead: pull.peers,
        peersNeedingUpgrade: pull.needUpgrade,
      );
    } catch (e) {
      return SyncReport(error: e);
    } finally {
      _running = false;
    }
  }

  // ─────────────────────────────── upload ────────────────────────────────

  /// Writes the whole journal, not just the new ops, because Drive cannot
  /// append. Returns how many previously-unuploaded ops it carried.
  Future<int> _upload() async {
    final all = await (db.select(db.outbox)
          ..orderBy([(o) => OrderingTerm.asc(o.seq)]))
        .get();
    final pending = all.where((o) => o.uploadedAt == null).toList();

    // Nothing new, and the journal already exists — the file on Drive is
    // already correct, so re-uploading it would only burn quota.
    if (pending.isEmpty && await store.readJournal(deviceId) != null) return 0;

    final body = encodeJournal(
      JournalHeader(
        deviceId: deviceId,
        minReaderVersion: kMinReaderVersion,
        // Nothing is compacted yet: the journal is still the only copy of
        // every op, so dropping any of it would lose data.
        compactedThroughSeq: -1,
      ),
      all.map(_toOp),
    );

    await store.writeJournal(deviceId, body);

    // Only after the write lands. If it threw, these stay pending and the next
    // run retries them.
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final o in pending) {
      await (db.update(db.outbox)..where((t) => t.opId.equals(o.opId)))
          .write(OutboxCompanion(uploadedAt: Value(now)));
    }

    await _publishMeta();
    return pending.length;
  }

  Op _toOp(OutboxData row) => Op(
        opId: row.opId,
        seq: row.seq,
        hlc: Hlc.parse(row.hlc),
        entity: row.entity,
        entityId: row.entityId,
        kind: row.kind == 'delete' ? OpKind.delete : OpKind.upsert,
        fields: Map<String, Object?>.from(
            jsonDecode(row.payload) as Map? ?? const {}),
        schemaV: row.schemaV,
      );

  /// Our cursors, so peers know what we have read and can compact behind us.
  Future<void> _publishMeta() async {
    final cursors = await db.select(db.peerCursors).get();
    await store.writeDeviceMeta(
      deviceId,
      jsonEncode({
        'device_id': deviceId,
        'last_seen_at': DateTime.now().millisecondsSinceEpoch,
        'cursors': {for (final c in cursors) c.peerDeviceId: c.lastSeq},
      }),
    );
  }

  // ──────────────────────────────── pull ─────────────────────────────────

  Future<({int applied, int peers, List<String> needUpgrade})>
      _pullAll() async {
    final devices = await store.listDevices();
    final peers = devices.where((d) => d != deviceId);

    var applied = 0;
    var read = 0;
    final needUpgrade = <String>[];

    for (final peer in peers) {
      try {
        final result = await _pullOne(peer);
        applied += result.applied;
        if (result.tooNew) {
          needUpgrade.add(peer);
        } else {
          read++;
        }
      } catch (_) {
        // One unreadable peer must not stop the rest. The cursor is untouched,
        // so the next run retries this peer from where it left off.
        continue;
      }
    }
    return (applied: applied, peers: read, needUpgrade: needUpgrade);
  }

  Future<({int applied, bool tooNew})> _pullOne(String peer) async {
    final text = await store.readJournal(peer);
    if (text == null) return (applied: 0, tooNew: false);

    final journal = decodeJournal(text);
    final header = journal.header;
    if (header == null) return (applied: 0, tooNew: false);

    if (header.minReaderVersion > kMinReaderVersion) {
      await _markNeedsUpgrade(peer);
      return (applied: 0, tooNew: true);
    }

    final cursor = await _cursorFor(peer);
    final fresh = journal.ops.where((o) => o.seq > cursor).toList()
      ..sort((a, b) => a.seq.compareTo(b.seq));

    var applied = 0;
    var advanceTo = cursor;

    for (final op in fresh) {
      final ok = await applier.apply(op);
      if (ok) applied++;

      // An op that could not be applied yet — usually an edit whose creating
      // op has not arrived — stops the cursor here. Advancing past it would
      // mean never looking at it again, which loses the change silently.
      final alreadySeen = !ok && await _isApplied(op.opId);
      if (!ok && !alreadySeen) break;

      advanceTo = op.seq;
    }

    if (advanceTo != cursor) await _writeCursor(peer, advanceTo);
    return (applied: applied, tooNew: false);
  }

  Future<bool> _isApplied(String opId) async =>
      await (db.select(db.appliedOps)..where((t) => t.opId.equals(opId)))
          .getSingleOrNull() !=
      null;

  Future<int> _cursorFor(String peer) async {
    final row = await (db.select(db.peerCursors)
          ..where((t) => t.peerDeviceId.equals(peer)))
        .getSingleOrNull();
    return row?.lastSeq ?? 0;
  }

  Future<void> _writeCursor(String peer, int seq) =>
      db.into(db.peerCursors).insertOnConflictUpdate(PeerCursorsCompanion.insert(
            peerDeviceId: peer,
            lastSeq: Value(seq),
            lastPulledAt: Value(DateTime.now().millisecondsSinceEpoch),
          ));

  Future<void> _markNeedsUpgrade(String peer) =>
      db.into(db.peerCursors).insertOnConflictUpdate(PeerCursorsCompanion.insert(
            peerDeviceId: peer,
            needsUpgrade: const Value(true),
            lastPulledAt: Value(DateTime.now().millisecondsSinceEpoch),
          ));
}
