import 'dart:convert';

import '../../common/hlc.dart';
import 'op.dart';

/// The outcome of merging one op into an existing row.
class MergeResult {
  const MergeResult({required this.accepted, required this.rejected, required this.conflicts});

  /// Fields this op won, and should be written.
  final Map<String, Object?> accepted;

  /// Fields the local value won — the op arrived too late.
  final Set<String> rejected;

  final List<ConflictNote> conflicts;
}

class ConflictNote {
  const ConflictNote({
    required this.field,
    required this.localValue,
    required this.remoteValue,
    required this.winner,
    required this.reason,
  });

  final String field;
  final Object? localValue, remoteValue;
  final String winner; // local|remote
  final String reason;
}

const _statusOrder = [
  'created', 'confirmed', 'in_production', 'ready', 'out',
  'delivered', 'completed',
];

/// Field-level last-writer-wins, ordered by HLC.
///
/// Two people editing **different** fields of the same order both keep their
/// change — which is the common case, and the reason this is per field rather
/// than per row. docs/01-platform/sync/lld.md §5.
MergeResult mergeFields({
  required Op op,
  required Map<String, Object?> localRow,
  required Hlc rowHlc,
  String? fieldHlcJson,
}) {
  final perField = fieldHlcJson == null
      ? <String, String>{}
      : Map<String, String>.from(jsonDecode(fieldHlcJson) as Map);

  final accepted = <String, Object?>{};
  final rejected = <String>{};
  final conflicts = <ConflictNote>[];

  for (final entry in op.fields.entries) {
    final field = entry.key;
    final remote = entry.value;
    final localHlc = perField[field] != null ? Hlc.parse(perField[field]!) : rowHlc;

    if (op.hlc <= localHlc) {
      rejected.add(field);
      continue;
    }

    final local = localRow[field];
    accepted[field] = remote;

    // A backwards status move is legal but never silent — it lands in the
    // conflict log rather than being quietly accepted.
    if (field == 'status' && _isBackwards(local, remote)) {
      conflicts.add(ConflictNote(
        field: field, localValue: local, remoteValue: remote,
        winner: 'remote', reason: 'status_moved_backwards',
      ));
    } else if (local != null && local != remote) {
      conflicts.add(ConflictNote(
        field: field, localValue: local, remoteValue: remote,
        winner: 'remote', reason: 'overwrote_divergent_value',
      ));
    }
  }

  return MergeResult(accepted: accepted, rejected: rejected, conflicts: conflicts);
}

bool _isBackwards(Object? from, Object? to) {
  final a = _statusOrder.indexOf('$from');
  final b = _statusOrder.indexOf('$to');
  return a >= 0 && b >= 0 && b < a;
}

/// An op may leave a journal only when **both** hold: every live peer has read
/// past it, and it is already inside the latest snapshot. Either alone loses
/// data. docs/01-platform/sync/lld.md §6.
int compactThroughSeq({
  required Iterable<int> livePeerCursors,
  required int snapshotThroughSeq,
}) {
  // No snapshot yet → nothing compacts. The journal is the only copy.
  if (snapshotThroughSeq < 0) return -1;
  if (livePeerCursors.isEmpty) return snapshotThroughSeq;
  final minCursor = livePeerCursors.reduce((a, b) => a < b ? a : b);
  return minCursor < snapshotThroughSeq ? minCursor : snapshotThroughSeq;
}

/// A device is live when it has been seen within 30 days. Beyond that it stops
/// holding back compaction — otherwise one lost phone makes every journal grow
/// forever.
const Duration kPeerLiveness = Duration(days: 30);

bool isLivePeer({required int lastSeenAtMs, required int nowMs}) =>
    nowMs - lastSeenAtMs <= kPeerLiveness.inMilliseconds;
