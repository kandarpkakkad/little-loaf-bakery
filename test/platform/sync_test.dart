import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/hlc.dart';
import 'package:little_loaf/platform/sync/merge.dart';
import 'package:little_loaf/platform/sync/op.dart';

Op _op({
  required Hlc hlc,
  Map<String, Object?> fields = const {'status': 'confirmed'},
  int seq = 1,
}) =>
    Op(
      opId: 'op-$seq',
      seq: seq,
      hlc: hlc,
      entity: 'order',
      entityId: 'o1',
      kind: OpKind.upsert,
      fields: fields,
      schemaV: 7,
    );

void main() {
  group('journal encoding', () {
    test('round-trips header and ops', () {
      const header = JournalHeader(
          deviceId: 'd1', minReaderVersion: 12, compactedThroughSeq: 900);
      final ops = [
        _op(hlc: const Hlc(1000, 0, 'd1'), seq: 901),
        _op(hlc: const Hlc(1001, 0, 'd1'), seq: 902, fields: {'delivery_time': 960}),
      ];
      final decoded = decodeJournal(encodeJournal(header, ops));
      expect(decoded.header!.deviceId, 'd1');
      expect(decoded.header!.minReaderVersion, 12);
      expect(decoded.ops, hasLength(2));
      expect(decoded.ops[1].fields['delivery_time'], 960);
    });

    test('one malformed line does not lose the rest of the journal', () {
      const header = JournalHeader(
          deviceId: 'd1', minReaderVersion: 12, compactedThroughSeq: -1);
      final good = encodeJournal(header, [_op(hlc: const Hlc(1, 0, 'd1'), seq: 1)]);
      final corrupted = '$good\n{ not json at all\n${_op(hlc: const Hlc(2, 0, "d1"), seq: 2).toLine()}';
      expect(decodeJournal(corrupted).ops, hasLength(2));
    });

    test('unknown fields survive, so an older reader can skip them', () {
      final op = Op.fromJson({
        'op_id': 'x', 'seq': 1, 'hlc': '1:0:d1', 'entity': 'order',
        'entity_id': 'o1', 'kind': 'upsert', 'schema_v': 9,
        'fields': {'status': 'ready', 'a_field_from_the_future': 42},
      });
      expect(op.fields['a_field_from_the_future'], 42);
      expect(op.schemaV, 9);
    });
  });

  group('merge', () {
    test('two devices editing different fields both keep their change', () {
      // local set delivery_time at t=200; remote sets status at t=100
      final r = mergeFields(
        op: _op(hlc: const Hlc(100, 0, 'd2'), fields: {'status': 'ready'}),
        localRow: {'status': 'confirmed', 'delivery_time': 960},
        rowHlc: const Hlc(50, 0, 'd1'),
        fieldHlcJson: '{"delivery_time":"200:0:d1"}',
      );
      expect(r.accepted, {'status': 'ready'});
      expect(r.rejected, isEmpty);
    });

    test('an op older than the field it touches is rejected', () {
      final r = mergeFields(
        op: _op(hlc: const Hlc(100, 0, 'd2'), fields: {'status': 'ready'}),
        localRow: {'status': 'out'},
        rowHlc: const Hlc(50, 0, 'd1'),
        fieldHlcJson: '{"status":"500:0:d1"}',
      );
      expect(r.accepted, isEmpty);
      expect(r.rejected, {'status'});
    });

    test('a backwards status move is applied but never silent', () {
      final r = mergeFields(
        op: _op(hlc: const Hlc(900, 0, 'd2'), fields: {'status': 'in_production'}),
        localRow: {'status': 'ready'},
        rowHlc: const Hlc(100, 0, 'd1'),
      );
      expect(r.accepted, {'status': 'in_production'});
      expect(r.conflicts.single.reason, 'status_moved_backwards');
    });

    test('overwriting a different local value is recorded', () {
      final r = mergeFields(
        op: _op(hlc: const Hlc(900, 0, 'd2'), fields: {'requirements': 'gold letters'}),
        localRow: {'requirements': 'silver letters'},
        rowHlc: const Hlc(100, 0, 'd1'),
      );
      expect(r.conflicts.single.reason, 'overwrote_divergent_value');
      expect(r.conflicts.single.localValue, 'silver letters');
    });

    test('an identical value is not a conflict', () {
      final r = mergeFields(
        op: _op(hlc: const Hlc(900, 0, 'd2'), fields: {'status': 'ready'}),
        localRow: {'status': 'ready'},
        rowHlc: const Hlc(100, 0, 'd1'),
      );
      expect(r.conflicts, isEmpty);
    });

    test('converges regardless of arrival order', () {
      // Same two ops, applied in both orders, must reach the same value.
      final a = _op(hlc: const Hlc(100, 0, 'aaa'), fields: {'status': 'ready'});
      final b = _op(hlc: const Hlc(100, 0, 'bbb'), fields: {'status': 'out'});
      String settle(List<Op> order) {
        var row = <String, Object?>{'status': 'confirmed'};
        var hlc = const Hlc(1, 0, 'local');
        for (final op in order) {
          final r = mergeFields(op: op, localRow: row, rowHlc: hlc);
          if (r.accepted.isNotEmpty) {
            row = {...row, ...r.accepted};
            hlc = op.hlc;
          }
        }
        return row['status'] as String;
      }
      expect(settle([a, b]), settle([b, a])); // device id breaks the tie, same both ways
      expect(settle([a, b]), 'out'); // 'bbb' > 'aaa'
    });
  });

  group('compaction', () {
    test('nothing compacts before the first snapshot', () {
      expect(compactThroughSeq(livePeerCursors: [900], snapshotThroughSeq: -1), -1);
    });

    test('is held back by the slowest live peer', () {
      expect(compactThroughSeq(livePeerCursors: [900, 500], snapshotThroughSeq: 1000), 500);
    });

    test('is held back by the snapshot', () {
      expect(compactThroughSeq(livePeerCursors: [900, 950], snapshotThroughSeq: 400), 400);
    });

    test('with no live peers, only the snapshot holds it back', () {
      expect(compactThroughSeq(livePeerCursors: [], snapshotThroughSeq: 400), 400);
    });

    test('a peer silent 30 days stops being waited for', () {
      const now = 1000 * 60 * 60 * 24 * 100;
      expect(isLivePeer(lastSeenAtMs: now - Duration(days: 29).inMilliseconds, nowMs: now), isTrue);
      expect(isLivePeer(lastSeenAtMs: now - Duration(days: 31).inMilliseconds, nowMs: now), isFalse);
    });
  });
}
