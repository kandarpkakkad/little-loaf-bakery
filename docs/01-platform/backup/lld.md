# Backup & restore — LLD

## 1. Artefacts

**Source of truth: [`schema.md`](schema.md)** — `snapshot/owner.json` and what a snapshot file does and does not contain.

## 2. The nightly job

```dart
// WorkManager: daily at 00:02 Asia/Kolkata, plus catch-up on next launch if missed.
Future<void> snapshotJob() async {
  final owner = await drive.readJson('snapshot/owner.json');

  if (owner == null) {
    await drive.writeJson('snapshot/owner.json',
      {deviceId: me, claimedAt: now, lastSnapshotAt: null, throughSeq: {}});
    // fall through and upload — if another device also claimed, it wins the file
    // and we simply skip from tomorrow.
  } else if (owner.deviceId != me) {
    return;                                   // not ours; nothing else changes
  }

  final path = await db.vacuumInto(tmpFile);  // consistent point-in-time copy, decrypted
  await drive.upload('snapshot/${today}.db', path);
  await drive.writeJson('snapshot/owner.json', {
    deviceId: me, claimedAt: owner?.claimedAt ?? now,
    lastSnapshotAt: nowActual,                // when it HAPPENED
    throughSeq: await highestSeqPerDevice(),
  });
  await prune(keep: 14);
}
```

`VACUUM INTO` is used rather than copying the file: it produces a consistent snapshot without
stopping writes, and drops free pages so the upload is smaller.

## 3. Staleness warning

```dart
final stale = now.difference(owner.lastSnapshotAt) > Duration(days: 3);
// Sync & backup shows: "No snapshot since 24 Aug. <name> is the snapshot device.
//                       If that phone is gone, delete snapshot/owner.json in Drive."
```

This is the only signal that snapshots have stalled, and it matters because compaction is
blocked behind snapshot inclusion — journals grow silently otherwise.

## 4. Restore

```
1. Sign in to the bakery Google account
2. List snapshot/*.db, newest first; user picks one (default: newest)
3. Download → integrity_check → open
4. Run migrations from the snapshot's schema_version to the app's
5. Replay EVERY journal, including this device's own if one exists, from seq 0
     — idempotent, so replaying ops already inside the snapshot is free
6. Rebuild peer_cursors from what was applied
7. Generate a NEW device id if this is a fresh install on a new phone,
   or keep the existing one if restoring the same install
```

**Step 7 has one answer: a new id, always.**

**A device id identifies an installation, not a person or a handset, and it is never reused.**
Every restore is a new install, so every restore generates a fresh UUID v7 — there is no case
where an id is carried across.

| Situation | Device id |
|---|---|
| Replacement phone | **New** |
| Same phone, reinstalled after a wipe | **New** |
| Restored alongside a live device, to inspect | **New** |

Why it must be new: the old install's **sequence counter is local state** and does not survive
in the snapshot. A restored device that reused the id would restart its sequence at 0001 and
reissue numbers the old device already used. A new id starts a clean series instead, and the
hash in the order number (D8) keeps everything unique regardless.

The orphaned folder stays in Drive and is still read by everyone — its ops are history and
remain valid. It ages out of the live-peer set after 30 days, at which point it stops holding
back compaction.

## 5. Ordering guarantees

Replay applies ops in HLC order across *all* journals, not per-journal. A naive
journal-at-a-time replay would still converge (LWW is commutative on the final state) but
would write the conflict log with spurious entries, so the merge sorts first.

## 6. Edge cases

| Case | Handling |
|---|---|
| No snapshot exists yet | Restore is journals-only. Works, just slower |
| Snapshot newer than the app | Refuse and prompt to update — reading a future schema is not safe |
| Two devices both claimed ownership | Both may upload once. Same-day files collide by name; last write wins; from the next night one of them skips |
| Snapshot taken mid-sync | `VACUUM INTO` is transactional. Ops still in the outbox are not in the snapshot, and `through_seq` reflects that |
| Restore interrupted | Restore writes to a temp DB and swaps at the end. An interrupted restore leaves the old state |

## 7. What to test

- **The drill:** wipe a device, restore, diff every table against a peer. Under 5 minutes.
- Restore with **no snapshot present** (journals only).
- Restore **across a schema change** — snapshot at v6 into an app at v8.
- **Ownership:** delete `owner.json`, confirm exactly one device claims it and the others skip.
- **Missed 00:02:** force Doze, confirm catch-up and that `last_snapshot_at` is the real time.
- **Compaction interlock:** with no snapshot, assert nothing compacts.

## Who owns it, and from when

**The first device to connect claims it**, on that first sync — not at the
first midnight it happens to be awake for.

It used to wait for 00:02. That left a new install owning nothing for up to a
day, which meant the only copy of a bakery's first day sat on one phone; and
compaction waits for a snapshot, so the journal could not shrink either. On a
single-phone bakery the first device is the only candidate; on two it is
whoever got there first, which is as good a rule as any.

The claim is the same one the nightly run makes, so nothing new can go wrong
with two devices connecting at once: last write wins the file, and the loser
skips from the following night.

Failure is quiet. An unclaimed folder is the state it was already in, and a
bakery that cannot snapshot this minute still has an app that works — the
nightly run tries again.
