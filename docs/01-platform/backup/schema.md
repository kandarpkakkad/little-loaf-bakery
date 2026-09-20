# Backup — schema

No tables. Two Drive artefacts.

## `snapshot/owner.json`

```jsonc
{
  "device_id":        "0192f3…a41c",
  "claimed_at":       1756300812345,
  "last_snapshot_at": 1756339320000,      // when it ACTUALLY happened, not when due
  "through_seq":      { "0192f3…a41c": 1043, "0192f4…7b02": 812 }
}
```

| Field | Meaning |
|---|---|
| `device_id` | Which device writes snapshots. Missing file → the next device to reach 00:02 claims it |
| `last_snapshot_at` | The real time. **Sync & backup warns when this is more than 3 days old** |
| `through_seq` | Highest seq **per device** included in the latest snapshot. Compaction reads this |

`through_seq` is the interlock: an op may only leave a journal once it appears here *and*
every live peer has read past it.

## `snapshot/<yyyy-mm-dd>.db`

A full SQLite file, produced by `VACUUM INTO`.

| | |
|---|---|
| Encryption | **None.** It must restore onto a different device with a different Keystore key. Protected by the Drive account |
| Contents | Every replicated table. **Not** `outbox`, `applied_ops`, `peer_cursors`, or `settings.order_seq` / `invoice_seq` — all local state |
| Retention | Last 14, older pruned |
| Naming | Date only. Two snapshots on one day overwrite; the second is the better one |

**What is deliberately absent tells you why a restored device needs a new id:** the sequence
counters are not in here.
