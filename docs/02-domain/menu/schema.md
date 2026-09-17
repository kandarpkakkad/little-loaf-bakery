# Menu — schema

Common columns: [`01-platform/storage/schema.md`](../../01-platform/storage/schema.md)

## menu_items

```sql
CREATE TABLE menu_items (
  id          TEXT    NOT NULL PRIMARY KEY,
  name        TEXT    NOT NULL,
  photo_path  TEXT,
  lead_days   INTEGER NOT NULL DEFAULT 0,
  active      INTEGER NOT NULL DEFAULT 1,
  season_from INTEGER,             -- MMDD, NULL = available always
  season_to   INTEGER,             -- MMDD; season_to < season_from means it wraps the year
  -- common columns
  CHECK (lead_days >= 0),
  CHECK ((season_from IS NULL) = (season_to IS NULL))
);
CREATE INDEX ix_menu_name ON menu_items(name) WHERE deleted_at IS NULL;
```

**No `price` column. No `flavours` table.** Both are decided per order (D17) — customization
changes what a thing costs, so there is no such thing as *the* price of a chocolate truffle
cake.

`season_to < season_from` is the wrap case, and the one that matters: plum cake runs November
to January.

**No `category` column.** The item *is* the category — "Cake", "Croissant", "Focaccia". A
separate category said the same thing twice, and the second copy was the one that drifted.

Names are **not** unique. Merging duplicates is a human decision in Config, not something the
schema forces.
