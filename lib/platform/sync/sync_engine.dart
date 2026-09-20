import 'dart:convert';

import 'package:drift/drift.dart';

import '../../common/hlc.dart';
import '../versioning/version.dart';
import '../storage/database.dart';
import '../backup/snapshot.dart';
import 'apply.dart';
import 'merge.dart';
import 'mutations.dart';
import 'op.dart';
import 'remote_store.dart';

/// What one sync run did. Returned rather than logged, so the UI can say
/// something specific and the tests can assert on it.
class SyncReport {
  const SyncReport({
    this.uploaded = 0,
    this.compacted = 0,
    this.applied = 0,
    this.peersRead = 0,
    this.peersSeen = 0,
    this.peersNeedingUpgrade = const [],
    this.peerErrors = const {},
    this.peerVersions = const {},
    this.error,
  });

  final int uploaded;

  /// Ops dropped from this device's journal because they are safely inside a
  /// snapshot and every live peer has read past them.
  final int compacted;

  final int applied;
  final int peersRead;

  /// Other devices with a journal folder in the shared Drive folder.
  ///
  /// Zero while another device is definitely syncing is the single most useful
  /// number here: it means this install cannot *see* the other one's folder, so
  /// the problem is which account or which app is asking, not the merge.
  final int peersSeen;

  /// Why a peer could not be read. Previously these were swallowed and the run
  /// still reported success, so a device that had synced nothing for weeks
  /// looked identical to one that was up to date.
  final Map<String, Object> peerErrors;

  /// Peers writing a journal this build is too old to read. Listed rather than
  /// thrown: one peer ahead of us must not stop the others syncing.
  final List<String> peersNeedingUpgrade;

  /// What each peer is running, by device id. A tablet three versions behind
  /// looks exactly like a tablet that is not syncing, until you can see this.
  final Map<String, String> peerVersions;

  final Object? error;

  bool get ok => error == null;

  /// True when the run finished but nothing could be read from anyone.
  bool get isolated => ok && peersSeen == 0;

  bool get hadPeerTrouble => peerErrors.isNotEmpty;

  @override
  String toString() => ok
      ? 'synced: $uploaded up, $applied applied, $peersRead/$peersSeen peers'
          '${compacted == 0 ? '' : ', $compacted compacted'}'
          '${peerErrors.isEmpty ? '' : ', ${peerErrors.length} unreadable'}'
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

  /// The last watermark this device compacted to. -1 until a snapshot exists.
  int _compactedThrough = -1;
  bool _compactedThisRun = false;

  /// What each peer said it was running, from the last time we read its
  /// `device.json`. Reported rather than stored: it is a fact about right now.
  final Map<String, String> _peerVersions = {};

  /// The reader version a peer must be at to read what we write. Bumped only
  /// when the journal format changes in a way an older build would misread —
  /// adding fields does not count, because unknown fields are ignored.
  static const int kMinReaderVersion = 1;

  Future<SyncReport> sync() async {
    if (_running) return const SyncReport();
    _running = true;
    try {
      _compactedThisRun = false;
      final compacted = await _compact();
      final uploaded = await _upload();
      final pull = await _pullAll();

      // After the pull, not before: this file is how peers learn how far we
      // have read, and publishing it first would always be one run stale. It
      // is also how they learn we are alive, so it goes out on every run —
      // including the runs where we wrote nothing at all.
      await _publishMeta();

      return SyncReport(
        uploaded: uploaded,
        compacted: compacted,
        applied: pull.applied,
        peersRead: pull.peers,
        peersSeen: pull.seen,
        peersNeedingUpgrade: pull.needUpgrade,
        peerErrors: pull.errors,
        peerVersions: Map.of(_peerVersions),
      );
    } catch (e) {
      return SyncReport(error: e);
    } finally {
      _running = false;
    }
  }

  // ────────────────────────────── compaction ─────────────────────────────

  /// Drops ops from the front of our own journal.
  ///
  /// Two conditions, and either one alone loses data: the op must already be
  /// inside the latest snapshot, **and** every live peer must have read past
  /// it. Without the first, a peer restoring from snapshot would never see it;
  /// without the second, a peer that has not synced yet would never see it.
  /// docs/01-platform/sync/lld.md §6
  Future<int> _compact() async {
    final owner = SnapshotOwner.parse(await store.readSnapshotMeta());
    if (owner == null) return 0; // no snapshot: the journal is the only copy

    final through = compactThroughSeq(
      livePeerCursors: await _peerCursorsOnUs(),
      snapshotThroughSeq: owner.throughSeq[deviceId] ?? -1,
    );
    if (through < 0) return 0;
    _compactedThrough = through;

    // Gone from the outbox, so the next upload rebuilds a shorter journal.
    // They are not lost: the snapshot holds them, and every live peer already
    // read them.
    final dropped = await (db.delete(db.outbox)
          ..where((t) => t.seq.isSmallerOrEqualValue(through)))
        .go();
    _compactedThisRun = dropped > 0;
    return dropped;
  }

  /// How far each **live** peer has read *our* journal, from the `device.json`
  /// they publish. A peer not seen for 30 days stops counting — otherwise one
  /// lost phone makes every journal grow forever.
  Future<List<int>> _peerCursorsOnUs() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final out = <int>[];
    _peerVersions.clear();

    for (final peer in await store.listDevices()) {
      if (peer == deviceId) continue;
      final text = await store.readDeviceMeta(peer);
      if (text == null) {
        // A folder with no device.json is a peer we know nothing about.
        // Treating it as caught up would compact away ops it has not read.
        out.add(0);
        continue;
      }
      final meta = jsonDecode(text) as Map<String, Object?>;

      // Recorded whatever its liveness: a phone nobody has touched for two
      // months is still worth naming on the sync screen, and the version it
      // was last on is the useful half of that.
      final version = meta['app_version'];
      if (version is String && version.isNotEmpty) {
        _peerVersions[peer] = version;
      }

      final seen = (meta['last_seen_at'] as num?)?.toInt() ?? 0;
      if (!isLivePeer(lastSeenAtMs: seen, nowMs: now)) continue;
      final cursors = meta['cursors'] as Map? ?? const {};
      out.add((cursors[deviceId] as num?)?.toInt() ?? 0);
    }
    return out;
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
    // already correct, so re-uploading it would only burn quota. Unless we
    // just compacted: then the file is correct but longer than it needs to
    // be, and shrinking it is the entire point of having compacted.
    if (pending.isEmpty &&
        !_compactedThisRun &&
        await store.readJournal(deviceId) != null) {
      return 0;
    }

    // Everything before this has left the outbox. Readers need to know, so a
    // peer arriving at a compacted journal can tell "not there any more,
    // it is in the snapshot" from "never written".
    final floor = all.isEmpty ? _compactedThrough : all.first.seq - 1;

    final body = encodeJournal(
      JournalHeader(
        deviceId: deviceId,
        minReaderVersion: kMinReaderVersion,
        compactedThroughSeq: floor,
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

  /// Our cursors, a heartbeat, and what we are running.
  ///
  /// Peers use the cursors to compact behind us and the heartbeat to know we
  /// are still here, so they do not. The version is here rather than in a file
  /// of its own because this one is already written on every sync and already
  /// read from every peer on every sync — so it costs nothing, and a version
  /// mismatch is exactly the kind of thing that makes orders look like they
  /// are not arriving.
  Future<void> _publishMeta() async {
    final cursors = await db.select(db.peerCursors).get();
    await store.writeDeviceMeta(
      deviceId,
      jsonEncode({
        'device_id': deviceId,
        'last_seen_at': DateTime.now().millisecondsSinceEpoch,
        'cursors': {for (final c in cursors) c.peerDeviceId: c.lastSeq},
        'app_version': kAppVersion,
        'min_supported': kMinSupported,
      }),
    );
  }

  // ──────────────────────────────── pull ─────────────────────────────────

  Future<
      ({
        int applied,
        int peers,
        int seen,
        List<String> needUpgrade,
        Map<String, Object> errors,
      })> _pullAll() async {
    final devices = await store.listDevices();
    final peers = devices.where((d) => d != deviceId).toList();

    var applied = 0;
    var read = 0;
    final needUpgrade = <String>[];
    final errors = <String, Object>{};

    for (final peer in peers) {
      try {
        final result = await _pullOne(peer);
        applied += result.applied;
        if (result.tooNew) {
          needUpgrade.add(peer);
        } else {
          read++;
        }
      } catch (e) {
        // One unreadable peer must not stop the rest, and the cursor is
        // untouched so the next run retries it. But it is *recorded* now:
        // silently continuing is how a device syncs nothing for a month while
        // reporting success after every run.
        errors[peer] = e;
      }
    }
    return (
      applied: applied,
      peers: read,
      seen: peers.length,
      needUpgrade: needUpgrade,
      errors: errors,
    );
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
