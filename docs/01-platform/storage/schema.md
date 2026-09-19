# Storage — schema

**Source of truth for the common columns, the settings row, and the conventions every other
schema file follows.** Module schemas live beside their module; nothing is duplicated in an
HLD or LLD.

Current schema version: **9**

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
  logo_path                 TEXT,
  address                   TEXT,
  phone                     TEXT,
  invoice_prefix            TEXT    NOT NULL DEFAULT 'LLB',
  terms_line                TEXT,
  upi_id                    TEXT,
  payment_phone             TEXT,
  delivery_charge_local     INTEGER NOT NULL DEFAULT 0,   -- paise
  delivery_charge_outstation INTEGER NOT NULL DEFAULT 0,  -- paise
  gst_enabled               INTEGER NOT NULL DEFAULT 0,
  app_lock_enabled          INTEGER NOT NULL DEFAULT 0,
  device_name               TEXT,
  order_seq                 INTEGER NOT NULL DEFAULT 0,   -- local; never replicated
  invoice_seq               INTEGER NOT NULL DEFAULT 0,   -- local; never replicated
  CHECK (id = 'singleton')
);
```

**`order_seq` and `invoice_seq` are local state.** They do not survive in a snapshot, which is
why a restored install must take a **new device id** and start a fresh series (D6).

## GST columns — present, unused

Carried from day one so switching GST on needs no migration. All null while
`settings.gst_enabled = 0`.

```sql
-- on settings
gstin TEXT,
-- on invoices
hsn_code TEXT, tax_rate INTEGER, cgst INTEGER, sgst INTEGER, igst INTEGER,
place_of_supply TEXT
```

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
| **7** | Launch schema — everything in these files |

**Rules:** forward-only, one step per version, additive by default. A column that must go is
emptied in release *n* and dropped in *n+1*, so a rollback survives. Every step is tested
against a seeded 30,000-order database.
