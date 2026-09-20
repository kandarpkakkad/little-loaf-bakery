import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart';

import '../storage/database.dart';
import '../sync/remote_store.dart';

/// Who takes the snapshots, and what the last one covered.
///
/// `snapshot/owner.json`. docs/01-platform/backup/schema.md
class SnapshotOwner {
  const SnapshotOwner({
    required this.deviceId,
    required this.claimedAt,
    this.lastSnapshotAt,
    this.throughSeq = const {},
  });

  final String deviceId;
  final int claimedAt;

  /// When a snapshot last actually happened — not when one was due. A phone
  /// that was off at 00:02 takes it at breakfast, and this says breakfast.
  final int? lastSnapshotAt;

  /// Highest seq per device that made it into the latest snapshot. Compaction
  /// reads this, and it is the reason nothing compacts before a first
  /// snapshot exists.
  final Map<String, int> throughSeq;

  Map<String, Object?> toJson() => {
        'device_id': deviceId,
        'claimed_at': claimedAt,
        'last_snapshot_at': lastSnapshotAt,
        'through_seq': throughSeq,
      };

  static SnapshotOwner fromJson(Map<String, Object?> j) => SnapshotOwner(
        deviceId: j['device_id'] as String,
        claimedAt: (j['claimed_at'] as num?)?.toInt() ?? 0,
        lastSnapshotAt: (j['last_snapshot_at'] as num?)?.toInt(),
        throughSeq: {
          for (final e in (j['through_seq'] as Map? ?? const {}).entries)
            '${e.key}': (e.value as num).toInt(),
        },
      );

  static SnapshotOwner? parse(String? json) => json == null
      ? null
      : SnapshotOwner.fromJson(jsonDecode(json) as Map<String, Object?>);

  /// Nothing for three days is long enough to mean the snapshot device is
  /// gone rather than merely asleep. Worth saying out loud, because journals
  /// cannot compact while snapshots have stalled.
  static const Duration staleAfter = Duration(days: 3);

  bool isStaleAt(int nowMs) =>
      lastSnapshotAt == null ||
      nowMs - lastSnapshotAt! > staleAfter.inMilliseconds;
}

enum SnapshotOutcome {
  /// Taken and uploaded.
  uploaded,

  /// Another device owns the job. Nothing to do, and not a problem.
  notOwner,

  failed,
}

class SnapshotResult {
  const SnapshotResult(this.outcome, {this.name, this.error, this.pruned = 0});

  final SnapshotOutcome outcome;
  final String? name;
  final Object? error;
  final int pruned;

  bool get ok => outcome != SnapshotOutcome.failed;
}

/// The nightly backup.
///
/// One device writes snapshots; the rest skip. There is no lock and no
/// heartbeat — the ownership check runs on every attempt, so two devices that
/// claim at the same moment resolve themselves: last write wins the file, and
/// the loser skips from the next night onward. Release is manual, by deleting
/// `snapshot/owner.json`, because an automatic hand-off needs timeouts to
/// solve something that happens once every few years.
/// docs/01-platform/backup/hld.md
class SnapshotService {
  SnapshotService({
    required this.db,
    required this.store,
    required this.deviceId,
    required this.workDir,
    this.keep = 14,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final RemoteStore store;
  final String deviceId;

  /// Somewhere to build the copy before it is uploaded. Deleted afterwards.
  final Directory workDir;

  final int keep;
  final DateTime Function() _clock;

  Future<SnapshotOwner?> owner() async =>
      SnapshotOwner.parse(await store.readSnapshotMeta());

  /// Takes a snapshot if this device is the one that should.
  Future<SnapshotResult> run() async {
    try {
      final existing = await owner();

      if (existing != null && existing.deviceId != deviceId) {
        return const SnapshotResult(SnapshotOutcome.notOwner);
      }
      if (existing == null) {
        // Claim it and carry on to upload. If another device claimed at the
        // same moment, one of us wins the file and the other simply skips
        // from tomorrow — both having uploaded once is harmless.
        await store.writeSnapshotMeta(jsonEncode(SnapshotOwner(
          deviceId: deviceId,
          claimedAt: _nowMs,
        ).toJson()));
      }

      final name = '${_today()}.db';
      if (!workDir.existsSync()) await workDir.create(recursive: true);
      final file = File('${workDir.path}/snapshot-$name');

      try {
        await exportTo(db, file.path);
        await store.uploadSnapshot(name, file);
      } finally {
        if (file.existsSync()) await file.delete();
      }

      await store.writeSnapshotMeta(jsonEncode(SnapshotOwner(
        deviceId: deviceId,
        claimedAt: existing?.claimedAt ?? _nowMs,
        lastSnapshotAt: _nowMs,
        throughSeq: await _throughSeq(),
      ).toJson()));

      final pruned = await _prune();
      return SnapshotResult(SnapshotOutcome.uploaded, name: name, pruned: pruned);
    } catch (e) {
      return SnapshotResult(SnapshotOutcome.failed, error: e);
    }
  }

  /// Highest seq per device that this snapshot contains.
  ///
  /// Our own entry counts only ops that have been **uploaded**. Everything in
  /// the outbox is in fact inside the snapshot — it was applied locally the
  /// moment it was written — but claiming coverage of an op no peer has ever
  /// been able to read would let compaction drop it from the journal before
  /// anyone saw it.
  Future<Map<String, int>> _throughSeq() async {
    final mine = await (db.select(db.outbox)
          ..where((t) => t.uploadedAt.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.seq)])
          ..limit(1))
        .getSingleOrNull();

    final cursors = await db.select(db.peerCursors).get();
    return {
      if (mine != null) deviceId: mine.seq,
      for (final c in cursors)
        if (c.lastSeq > 0) c.peerDeviceId: c.lastSeq,
    };
  }

  /// Keeps the newest [keep]. Names are dates, so they sort by themselves.
  Future<int> _prune() async {
    final all = [...await store.listSnapshots()]..sort();
    if (all.length <= keep) return 0;
    final old = all.take(all.length - keep).toList();
    for (final name in old) {
      await store.deleteSnapshot(name);
    }
    return old.length;
  }

  int get _nowMs => _clock().millisecondsSinceEpoch;

  String _today() {
    final d = _clock();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }
}

/// Writes a **decrypted** point-in-time copy of [db] to [path].
///
/// Decrypted on purpose: the copy has to open on a different phone with a
/// different Keystore key, so it is protected by the Drive account rather than
/// by SQLCipher. docs/01-platform/backup/schema.md
///
/// Local state is stripped afterwards — the outbox, what this device has
/// applied, where its peers' cursors are, and the two sequence counters. That
/// absence is exactly why a restored install has to take a new device id: the
/// counters are not in here to carry over.
Future<void> exportTo(AppDatabase db, String path) async {
  if (File(path).existsSync()) await File(path).delete();

  if (await _hasCipher(db)) {
    // `VACUUM INTO` on a keyed database writes a copy keyed the same way,
    // which is the one thing this file must not be. Attaching with an empty
    // key and exporting is SQLCipher's way of saying "plaintext" — and it is
    // the right call whether or not *this* database is keyed, because the
    // question is what the copy must be, not what the source is.
    await db.customStatement("ATTACH DATABASE '$path' AS plain KEY ''");
    await db.customSelect("SELECT sqlcipher_export('plain')").get();
    await db.customStatement('DETACH DATABASE plain');
  } else {
    await db.customStatement("VACUUM INTO '$path'");
  }

  final copy = sqlite3.open(path);
  try {
    copy.execute('DELETE FROM outbox');
    copy.execute('DELETE FROM applied_ops');
    copy.execute('DELETE FROM peer_cursors');
    copy.execute('UPDATE settings SET order_seq = 0');
    copy.execute('VACUUM');
  } finally {
    copy.close();
  }
}

/// Whether SQLCipher is the library underneath — not whether this database is
/// keyed. A plain build has no `sqlcipher_export` to call.
Future<bool> _hasCipher(AppDatabase db) async {
  final rows = await db.customSelect('PRAGMA cipher_version').get();
  if (rows.isEmpty) return false;
  final v = rows.first.data.values.first;
  return v != null && '$v'.trim().isNotEmpty;
}
