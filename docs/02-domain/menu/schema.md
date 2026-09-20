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
  season_from INTEGER,             -- unused: seasonality was removed
  season_to   INTEGER,             -- unused; both go in a later release
  -- common columns
  CHECK (lead_days >= 0),
  CHECK ((season_from IS NULL) = (season_to IS NULL))
);
CREATE INDEX ix_menu_name ON menu_items(name) WHERE deleted_at IS NULL;
```

**No `price` column. No `flavours` table.** Both are decided per order (D17) — customization
changes what a thing costs, so there is no such thing as *the* price of a chocolate truffle
cake.

**`season_from` / `season_to` are dead.** Seasonality was removed — a bakery that makes a
thing makes it, and two month pickers stood between a person and saving a menu item. The
columns stay one release because a v9 peer still writes them.

**No `category` column.** The item *is* the category — "Cake", "Croissant", "Focaccia". A
separate category said the same thing twice, and the second copy was the one that drifted.

Names are **not** unique. Merging duplicates is a human decision in Config, not something the
schema forces.
