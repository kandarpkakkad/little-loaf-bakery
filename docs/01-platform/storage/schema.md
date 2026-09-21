# Storage — schema

**Source of truth for the common columns, the settings row, and the conventions every other
schema file follows.** Module schemas live beside their module; nothing is duplicated in an
HLD or LLD.

Current schema version: **16**

---

## Conventions

| Rule | |
|---|---|
| Primary key | `TEXT` holding a **UUID v7**. Time-ordered, so `ORDER BY id` is creation order |
| Money | `INTEGER` **paise**. Never a float, at any layer |
| Quantities | `REAL` (stock only — kilos and litres are fractional) |
| Timestamps | `INTEGER` epoch **milliseconds, UTC**. Rendered in Asia/Kolkata |
| Dates | `INTEGER` epoch ms at **local midnight** |
| Time of day | `INTEGER` minutes from midnight, `NULL` = unset |
| Booleans | `INTEGER` 0/1 |
| Deletes | **Soft only.** `deleted_at` non-null means gone. Every read filters it |
| Enums | `TEXT`, lower_snake. Never an ordinal — an int would break on reorder |

## Common columns

Every replicated table carries these. Not optional.

```sql
id             TEXT    NOT NULL PRIMARY KEY,   -- UUID v7
device_id      TEXT    NOT NULL,               -- which install created the row
created_at     INTEGER NOT NULL,               -- epoch ms
updated_at_hlc TEXT    NOT NULL,               -- serialised HLC, the merge key
deleted_at     INTEGER,                        -- tombstone
field_hlc_json TEXT                            -- per-field HLC; only on multi-writer tables
```

`field_hlc_json` is present on `orders`, `customers`, `menu_items`, `materials` — the tables
edited from more than one place. Append-only tables do not need it.

**Local-only tables carry none of these.** They never replicate: `outbox`, `applied_ops`,
`peer_cursors`.

## settings — singleton

```sql
CREATE TABLE settings (
  id                        TEXT    NOT NULL PRIMARY KEY DEFAULT 'singleton',
  business_name             TEXT    NOT NULL,
  address                   TEXT,
  phone                     TEXT,
  invoice_prefix            TEXT    NOT NULL DEFAULT 'LLB',  -- the ORDER number's prefix
  upi_id                    TEXT,
  payment_phone             TEXT,
  delivery_charge_local     INTEGER NOT NULL DEFAULT 0,   -- paise
  delivery_charge_outstation INTEGER NOT NULL DEFAULT 0,  -- paise
  app_lock_enabled          INTEGER NOT NULL DEFAULT 0,
  device_name               TEXT,
  order_seq                 INTEGER NOT NULL DEFAULT 0,   -- local; never replicated
  CHECK (id = 'singleton')
);
```

**`order_seq` is local state.** It does not survive in a snapshot, which is why a restored
install must take a **new device id** and start a fresh series (D6).

**`invoice_prefix` prefixes ORDER numbers**, despite its name. It is the only thing invoicing
left behind; renaming it would cost a synced column for no gain.

## GST — removed, not deferred

`gstin`, `gst_enabled` and the `invoices` table that carried `hsn_code`, `tax_rate`, `cgst`,
`sgst`, `igst` and `place_of_supply` were dropped in **schema v13** along with invoicing
itself (D30). They were carried "so switching GST on needs no migration" and then sat unread
for every release; a migration when GST actually arrives is cheaper than columns nobody can
explain.

## First run — creating the tables

**The database is created on the device, by the app, the first time it opens.** There is no
bundled `.db` file, no server hand-off and no seed download. `onCreate` runs once and does
three things, in one transaction:

1. **`CREATE TABLE` for every table in every `schema.md`** — 19 tables, from this file and the
   module files beside it.
2. **`CREATE INDEX` for all 20 indexes**, including the partial ones (`WHERE deleted_at IS NULL`)
   that carry the app's main sort.
3. **Insert the `settings` singleton** with its defaults, so no screen ever has to cope with a
   missing config row.

The app is then usable immediately, offline, with an empty database — no sign-in required to
take an order. Setup (S01) connects Drive afterwards, and the Drive folder is created on the
first sync, not at install.

| Path | What happens |
|---|---|
| **Fresh install** | `onCreate` — tables, indexes, settings row. Empty and ready |
| **Install, then restore** | `onCreate` runs first, then the restore replaces the file and reruns migrations against it (see [`../backup/lld.md`](../backup/lld.md)) |
| **Upgrade over an existing install** | `onCreate` does **not** run. `onUpgrade` steps from the stored version to the current one |
| **Reinstall after an uninstall** | A fresh install, and the data is gone with the app — which is why upgrades are installed *over*, never after an uninstall |

**Schema version is stored in the file itself**, so the app always knows which step to
migrate from.

## Migration ladder

| v | Change |
|---|---|
| 1–6 | Pre-launch iterations. Collapsed into `onCreate` before first release |
| 7 | Launch schema |
| 8–11 | Per-item scheduling and status; derived order status and due date (D25–D27) |
| 12 | **The journey becomes a row** — `sub_orders` (D28, D29). The order side was rebuilt rather than carried across |
| 13 | **Invoicing removed** (D30). `invoices` dropped, and `gstin` / `gst_enabled` / `logo_path` / `terms_line` / `invoice_seq` with it |
| 14 | **The discount moves to the item** (D31). `order_items.discount_type` / `discount_value` added; the order's stay as caches |
| **15** | Weight units are `g` / `kg` / `ml` / `l`. The CHECK is **widened**, not narrowed — rows carrying the old `pcs` / `dozen` stay saveable |
| **16** | **The bakery's details start replicating.** `settings` gains `device_id` / `created_at` / `updated_at_hlc` / `deleted_at` / `field_hlc_json`, seeded `0:0:seed`. Only `kSharedSettings` travels — `device_name`, `app_lock_enabled` and `order_seq` stay on their handset |

**A rebuild must declare its new columns.** `TableMigration(db.settings)` recreates the
table from its current definition and copies the rows across — including, unless told
otherwise, columns that do not exist yet. v16 died on `no such column: field_hlc_json`
until every added column was named in `newColumns`. They still need a default or a
`columnTransformer`; drift checks that in the constructor, but it cannot guess which
columns are new.

**A migration test needs a file, not a memory database.** Reopening a closed in-memory
executor throws `Can't re-open a database after closing it`, and an executor that was never
closed skips the migration and passes.

**A dropped name has to be grepped for.** Removing `invoice_seq` in v13 left
`UPDATE settings SET order_seq = 0, invoice_seq = 0` in `backup/snapshot.dart` — a raw SQL
string the analyser cannot see. Every snapshot failed silently, and because compaction waits
for a snapshot, the journals stopped compacting.

**Rules:** forward-only, one step per version, additive by default. A column that must go is
emptied in release *n* and dropped in *n+1*, so a rollback survives. Every step is tested
against a seeded 30,000-order database.
