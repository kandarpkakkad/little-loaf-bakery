# Stock — schema

Common columns: [`01-platform/storage/schema.md`](../../01-platform/storage/schema.md)

## materials

```sql
CREATE TABLE materials (
  id            TEXT NOT NULL PRIMARY KEY,
  name          TEXT NOT NULL,
  category      TEXT NOT NULL,      -- raw|packaging
  unit          TEXT NOT NULL,      -- kg|g|L|ml|pcs|box
  threshold_qty REAL NOT NULL,
  active        INTEGER NOT NULL DEFAULT 1,
  -- common columns
  CHECK (category IN ('raw','packaging')),
  CHECK (unit IN ('kg','g','L','ml','pcs','box')),
  CHECK (threshold_qty >= 0)
);
CREATE INDEX ix_mat_cat ON materials(category, name) WHERE deleted_at IS NULL;
```

**Four fields** (D19). No price, no supplier, no shelf life, no batch tracking, no storage
location — each was either already known or would go stale, and a stale field is worse than an
absent one.

**`unit` is locked once movements exist.** Changing kg to g would silently rewrite every
historical quantity. Enforced in the domain, not by a constraint — SQLite cannot express it.

### Not stored

`current_level`, `reference`, `last_rate`. **All derived** from `stock_transactions`, so two
devices can never disagree about a number neither one holds.

## stock_transactions — append-only

```sql
CREATE TABLE stock_transactions (
  id          TEXT    NOT NULL PRIMARY KEY,
  material_id TEXT    NOT NULL REFERENCES materials(id),
  kind        TEXT    NOT NULL,     -- in|consume|waste|count
  qty         REAL    NOT NULL,     -- see below
  amount      INTEGER,              -- paise paid; only on `in`, and OPTIONAL
  reason      TEXT,                 -- waste only
  at          INTEGER NOT NULL,
  -- common columns
  CHECK (kind IN ('in','consume','waste','count')),
  CHECK (qty >= 0),
  CHECK (amount IS NULL OR kind = 'in'),
  CHECK (reason IS NULL OR kind = 'waste'),
  CHECK (reason IS NULL OR reason IN ('expired','spoiled','spilled','failed_bake'))
);
CREATE INDEX ix_stock_mat ON stock_transactions(material_id, at) WHERE deleted_at IS NULL;
```

### `qty` means two different things

| kind | `qty` is |
|---|---|
| `in` · `consume` · `waste` | A **delta**. Always positive; the sign comes from the kind |
| `count` | The **absolute counted level**. Everything after it is relative to it |

A count is a **reset point**, which is what makes it a correction rather than another guess.

### `amount` is optional

Skipping it still adds the stock — it only means that entry contributes nothing to *last paid*
or to valuation. Better an honest gap than a guessed number. The per-unit rate is derived
(`amount / qty`), never typed.
