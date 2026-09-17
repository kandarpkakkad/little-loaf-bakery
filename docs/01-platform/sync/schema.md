# Sync — schema

Local-only tables. **None of these replicate** — they describe this device's view of the world,
and another device's copy would be meaningless.

## outbox

Ops written but not yet uploaded. Written in the same transaction as the row they describe.

```sql
CREATE TABLE outbox (
  op_id       TEXT    NOT NULL PRIMARY KEY,   -- UUID v7, idempotency key
  seq         INTEGER NOT NULL,               -- this device's monotonic counter
  hlc         TEXT    NOT NULL,
  entity      TEXT    NOT NULL,               -- order|order_item|payment|…
  entity_id   TEXT    NOT NULL,
  kind        TEXT    NOT NULL,               -- upsert|delete
  payload     TEXT    NOT NULL,               -- JSON of changed fields only
  schema_v    INTEGER NOT NULL,
  uploaded_at INTEGER                         -- null until it lands in Drive
);
CREATE INDEX ix_outbox_pending ON outbox(seq) WHERE uploaded_at IS NULL;
```

`seq` is **never reset**. It only grows for a given device id — a restore takes a new id
rather than reusing one.

## applied_ops

Idempotency guard. An op seen twice is dropped by the primary key.

```sql
CREATE TABLE applied_ops (
  op_id      TEXT    NOT NULL PRIMARY KEY,
  applied_at INTEGER NOT NULL
);
```

Pruned alongside compaction — an op older than the latest snapshot cannot arrive again.

## peer_cursors

How far this device has read each peer.

```sql
CREATE TABLE peer_cursors (
  peer_device_id TEXT    NOT NULL PRIMARY KEY,
  last_seq       INTEGER NOT NULL DEFAULT 0,
  last_pulled_at INTEGER,
  needs_upgrade  INTEGER NOT NULL DEFAULT 0   -- peer's min_reader_version > our build
);
```

A peer never seen before simply starts at 0. Published into this device's `device.json` so
others know what may be compacted.

## devices — replicated

The one sync table that does replicate, so every device can name the others.

```sql
CREATE TABLE devices (
  id            TEXT    NOT NULL PRIMARY KEY,   -- UUID v7, never reused
  name          TEXT,                           -- "Kitchen", "Counter"
  first_seen_at INTEGER NOT NULL,
  last_seen_at  INTEGER NOT NULL,
  app_version   INTEGER
  -- common columns
);
```

A device is **live** when `last_seen_at > now − 30 days`. Beyond that it stops holding back
compaction.

## conflict_log — replicated

```sql
CREATE TABLE conflict_log (
  id          TEXT    NOT NULL PRIMARY KEY,
  entity      TEXT    NOT NULL,
  entity_id   TEXT    NOT NULL,
  field       TEXT    NOT NULL,
  local_value TEXT,
  remote_value TEXT,
  winner      TEXT    NOT NULL,               -- local|remote
  reason      TEXT    NOT NULL,               -- backwards_status|overwrote_divergent
  at          INTEGER NOT NULL
  -- common columns
);
```

Replicated deliberately: a conflict is worth seeing from either phone.

## Drive file: `journal/<device-id>/ops.jsonl`

Header line, then one op per line.

```jsonc
{ "min_reader_version": 12, "device_id": "0192f3…", "compacted_through_seq": 900 }
{ "op_id":"…", "seq":1043, "hlc":"1756300812345:0:0192f3…",
  "entity":"order", "entity_id":"0192f4…", "kind":"upsert",
  "fields":{ "status":"confirmed" }, "schema_v":7 }
```

**Additive forever.** Unknown fields are ignored by older readers, which is what makes version
skew survivable.

## Drive file: `journal/<device-id>/device.json`

```jsonc
{ "device_id": "0192f3…", "name": "Kitchen", "app_version": 14,
  "last_seen_at": 1756300812345,
  "cursors": { "0192f4…7b02": 812, "0192f5…2e19": 47 } }
```

`cursors` is what every other device reads to know what it may compact.
