# Sync — LLD

## 1. Schema

**Source of truth: [`schema.md`](schema.md)** — `outbox`, `applied_ops`, `peer_cursors`, `devices`, `conflict_log`, and the shape of `ops.jsonl` and `device.json` in Drive.

## 3. Upload

```
onChange → debounce 5s → uploadWorker:
   lock (single-flight; a second trigger is dropped, not queued)
   ops   = outbox where uploaded_at is null, order by seq
   if ops.isEmpty and cursorsUnchanged: return
   body  = header + retainedOps + ops        // retainedOps = not yet compactable
   PUT journal/<me>/ops.jsonl                // whole file, atomic in Drive
   mark ops uploaded
   PUT journal/<me>/device.json              // cursors + last_seen_at
   unlock
```

**Why the whole file is safe:** Drive replaces a file atomically. A reader sees either the
previous revision or the new one — never a half-written splice.

## 4. Pull

```
pullWorker (on the :00/:05 grid, on resume, on refresh):
   peers = list(journal/*) minus me
   for peer in peers:
     head = read first line of peer/ops.jsonl
     if head.min_reader_version > APP_VERSION:
        markPeerNeedsUpgrade(peer); continue          // skip THIS peer only
     newOps = lines where seq > cursor[peer]
     applyAll(newOps)
     cursor[peer] = max seq applied
   publishCursors()
```

## 5. Apply

```dart
Future<void> apply(Op op) => db.transaction(() async {
  if (await appliedOps.exists(op.opId)) return;        // idempotent
  Hlc.observe(op.hlc);                                 // never lag a peer's clock
  switch (op.kind) {
    case upsert: await mergeFields(op);
    case delete: await tombstone(op.entity, op.entityId, op.hlc);
  }
  await appliedOps.insert(op.opId);
});

Future<void> mergeFields(Op op) async {
  final row = await load(op.entity, op.entityId);
  if (row == null) { await insertFrom(op); return; }
  for (final (field, value) in op.fields) {
    final local = row.fieldHlc(field) ?? row.updatedAtHlc;
    if (op.hlc.compareTo(local) > 0) {                 // last-writer-wins, per field
      if (field == 'status' && isBackwards(row.status, value)) {
        await conflictLog.record(op, row, reason: 'status moved backwards');
      }
      if (row.hasLocalDivergence(field, op)) {
        await conflictLog.record(op, row, reason: 'overwrote a different local value');
      }
      await setField(op.entity, op.entityId, field, value, op.hlc);
    }
  }
}
```

**Per-field HLC** is stored in a sidecar map (`field_hlc_json`) on rows that are edited from
more than one place — orders, customers, materials, menu items. Rows that are only ever
inserted do not need it.

**Never merged:** `payments`, `stock_transactions`, `order_status_events`, `share_log`. Inserts
only, so an op either introduces a row or is a duplicate to ignore.

## 6. Compaction

Built — `SyncEngine._compact()`, over the rules in `merge.dart`
(`compactThroughSeq`, `isLivePeer`). 7 tests, each removing one guard.

Runs at the **start** of a run rather than after the pull, so the shorter
journal goes out in the same upload. The inputs are all from the previous run
— a snapshot taken in the night, cursors peers published since — so there is
nothing to gain from compacting after a pull and one upload to be saved.

A peer with a journal folder but no `device.json` counts as having read
**nothing**. Unknown is not the same as caught up, and the cost of being wrong
in that direction is an op nobody ever sees.

```
liveePeers  = devices where last_seen_at > now - 30d
minCursor   = min(cursor published by each live peer for ME)
snapshotSeq = seq of my last op included in the latest snapshot   // from snapshot/owner.json
safeThrough = min(minCursor, snapshotSeq)
retain ops where seq > safeThrough
```

| Guard | Why |
|---|---|
| `minCursor` | A peer that has not read an op still needs it |
| `snapshotSeq` | A restore replays snapshot + journals; an op in neither is gone |
| 30-day liveness | One lost phone must not make every journal grow forever |

**If no snapshot exists yet, `snapshotSeq = -1`, so nothing compacts.** Correct: with no
snapshot, the journal *is* the only copy.

## 7. Sort and tie-breaks

`Hlc.compareTo` is `(wallMs, counter, deviceId)` lexicographically. Device id as the final
tie-break makes the outcome **identical on every device** — convergence does not depend on
arrival order.

## 8. Edge cases

| Case | Handling |
|---|---|
| Op arrives for an unknown entity id | Insert it. Ops are self-contained; order of arrival is irrelevant |
| Op arrives for a tombstoned row | Applies to the row; stays deleted unless the op un-deletes |
| Same op seen twice | `applied_ops` PK rejects the second |
| Peer folder appears with no `device.json` | Treat as a live peer at cursor 0; it will publish on its next upload |
| Peer's `seq` goes backwards | **Cannot happen** — a restore always takes a new device id, so a given id's sequence only ever grows. Kept as a defensive assertion that logs and re-reads from 0; idempotency makes the recovery free |
| Two devices upload simultaneously | Different files. No interaction |
| Journal exceeds 5 MB | Something is wrong with compaction — surface a warning, keep working |

## 9. What to test

- **Convergence:** three devices, random interleaved edits, offline windows; assert byte-identical
  domain state at the end.
- **Idempotency:** apply the same journal twice, assert no change.
- **Compaction safety:** compact, then restore from snapshot + journals, assert nothing lost.
- **Peer restored from an old snapshot** (seq regression) recovers without duplicates.
- **Field-level LWW:** two devices edit different fields of one order; both survive.
- **Backwards status** lands in the conflict log, not silently.
- **The 30-day rule:** a peer goes silent, compaction proceeds, the peer returns and restores.
