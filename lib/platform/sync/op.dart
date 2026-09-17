import 'dart:convert';

import '../../common/hlc.dart';

/// One replicated change. Immutable, idempotent, identified by [opId].
///
/// **Additive forever** — unknown fields are ignored by older readers, which is
/// what makes version skew survivable. docs/01-platform/sync/schema.md
class Op {
  const Op({
    required this.opId,
    required this.seq,
    required this.hlc,
    required this.entity,
    required this.entityId,
    required this.kind,
    required this.fields,
    required this.schemaV,
  });

  final String opId;
  final int seq;
  final Hlc hlc;
  final String entity;
  final String entityId;
  final OpKind kind;
  final Map<String, Object?> fields;
  final int schemaV;

  Map<String, Object?> toJson() => {
        'op_id': opId,
        'seq': seq,
        'hlc': hlc.toString(),
        'entity': entity,
        'entity_id': entityId,
        'kind': kind.name,
        'fields': fields,
        'schema_v': schemaV,
      };

  static Op fromJson(Map<String, Object?> j) => Op(
        opId: j['op_id'] as String,
        seq: (j['seq'] as num).toInt(),
        hlc: Hlc.parse(j['hlc'] as String),
        entity: j['entity'] as String,
        entityId: j['entity_id'] as String,
        kind: j['kind'] == 'delete' ? OpKind.delete : OpKind.upsert,
        // unknown keys inside `fields` are carried through untouched
        fields: Map<String, Object?>.from(j['fields'] as Map? ?? const {}),
        schemaV: (j['schema_v'] as num?)?.toInt() ?? 0,
      );

  String toLine() => jsonEncode(toJson());
}

enum OpKind { upsert, delete }

/// The first line of every `ops.jsonl`.
class JournalHeader {
  const JournalHeader({
    required this.deviceId,
    required this.minReaderVersion,
    required this.compactedThroughSeq,
  });

  final String deviceId;
  final int minReaderVersion;
  final int compactedThroughSeq;

  Map<String, Object?> toJson() => {
        'device_id': deviceId,
        'min_reader_version': minReaderVersion,
        'compacted_through_seq': compactedThroughSeq,
      };

  static JournalHeader fromJson(Map<String, Object?> j) => JournalHeader(
        deviceId: j['device_id'] as String,
        minReaderVersion: (j['min_reader_version'] as num?)?.toInt() ?? 0,
        compactedThroughSeq: (j['compacted_through_seq'] as num?)?.toInt() ?? -1,
      );
}

/// Serialise a journal: header line, then one op per line.
String encodeJournal(JournalHeader header, Iterable<Op> ops) =>
    [jsonEncode(header.toJson()), ...ops.map((o) => o.toLine())].join('\n');

/// Parse a journal. Returns null for the header when the file is empty.
({JournalHeader? header, List<Op> ops}) decodeJournal(String text) {
  final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
  if (lines.isEmpty) return (header: null, ops: const []);
  final header = JournalHeader.fromJson(jsonDecode(lines.first) as Map<String, Object?>);
  final ops = <Op>[];
  for (final l in lines.skip(1)) {
    try {
      ops.add(Op.fromJson(jsonDecode(l) as Map<String, Object?>));
    } on FormatException {
      // A single malformed line must not lose the rest of the journal.
      continue;
    }
  }
  return (header: header, ops: ops);
}
