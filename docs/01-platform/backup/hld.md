# Backup & restore — HLD


Built — `lib/platform/backup/snapshot.dart` and `restore.dart`, the nightly
WorkManager task in `sync/background.dart`, the **Backup** section of
Sync & backup, 20 tests. Journal compaction is unblocked and running:
`lib/platform/sync/sync_engine.dart` `_compact()`, 7 tests.

Two deviations from what follows, both because the code had to be specific
where the design could be brief:

- **The copy is made with `sqlcipher_export`, not `VACUUM INTO`.** On a keyed
  database `VACUUM INTO` writes a copy keyed the same way, which is the one
  thing this file must not be. Attaching with an empty key and exporting is
  how SQLCipher says "plaintext". A build without SQLCipher — tests only —
  still uses `VACUUM INTO`.
- **Restore is staged, not live.** The snapshot is downloaded and checked
  immediately, then swapped in at the next launch, before anything has the old
  database open. Swapping under a running app would leave every screen, stream
  and background isolate holding a handle to a file that no longer exists. The
  restore drill is therefore two steps: restore, then reopen.

## Purpose
Guarantee that the bakery's records survive a lost phone, a failed migration, or a corrupt
database — with a restore path that has actually been run.

## The two halves
| | Covers | Written by |
|---|---|---|
| **Journals** | The recent tail — everything since the last snapshot | Every device, continuously |
| **Snapshot** | Everything before that | One device, at 00:02 IST |

**Every snapshot pulls first.** A copy is only worth what the database held when it was taken,
and a device that has not synced holds its own share of the bakery rather than the bakery. The
pull is best effort: if a peer cannot be read the snapshot is still taken — one missing hour
beats no backup — and the app says which of the two it was.

**Restore is snapshot + replay of every journal.** Together they are always complete; that is
why compaction requires an op to be in the snapshot before dropping it (D4).

## Snapshot ownership
`snapshot/owner.json` holds `{ device_id, claimed_at, last_snapshot_at, through_seq }`.

| At 00:02, a device reads it | Then |
|---|---|
| Missing | Claims it — writes its own id — and uploads |
| Matches this device | Uploads |
| Names another device | Skips |

**No locking, no heartbeat.** The check runs on every upload, not only at claim time, so a
simultaneous double-claim resolves itself: last write wins, and the loser skips from the next
night onward.

**Hand-over is a button, not a file edit** (D5 amended). **Take over backups** on Sync &
backup writes `owner.json` naming this device and takes a snapshot straight away, so the
move is proved rather than promised. The device that held the job is told nothing and needs
nothing: its next run reads the file, finds another name and stands down. Two devices taking
over at once settle like any other claim — last write wins.

`through_seq` is carried across the write, so a hand-over whose first snapshot fails does not
also stall compaction on every journal.

Still **no automatic hand-off**: that needs timeouts and heartbeats to decide a question a
person answers in a second.

## Key decisions
- **The whole database, not a delta.** A delta chain is another thing that can break.
- **Written decrypted.** It must be restorable onto a *different* device with a *different*
  Keystore key. Protected by the Drive account, not by SQLCipher.
- **14 kept, older pruned.**
- **Tested before launch and every quarter**, and re-tested after **every** schema change,
  because a restore runs the same migrations as an upgrade.

## Failure modes
| Failure | Behaviour |
|---|---|
| Owner uninstalled without releasing | Snapshots stop → compaction stalls → journals grow. **Warned after 3 days**, naming the device |
| 00:02 missed (Doze, phone off) | Taken at the first opportunity after. `last_snapshot_at` records **when it happened**, not when it was due |
| Upload interrupted | Drive replaces atomically; the previous snapshot stays valid |
| Restore onto a newer app version | Migrations run as part of restore |
| Drive quota full | Snapshot fails, warned, journals keep working |

## Non-goals
No incremental backup. No off-Drive copy. No encryption of the snapshot beyond the account.
