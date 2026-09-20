# Orders — schema

Common columns and conventions: [`01-platform/storage/schema.md`](../../01-platform/storage/schema.md)

## orders

```sql
CREATE TABLE orders (
  id                      TEXT    NOT NULL PRIMARY KEY,   -- UUID v7
  order_no                TEXT    NOT NULL,               -- LLB-0148-K7QP
  customer_id             TEXT    NOT NULL REFERENCES customers(id),
  status                  TEXT    NOT NULL,
  fulfilment              TEXT    NOT NULL,               -- delivery|pickup
  delivery_date           INTEGER NOT NULL,               -- local midnight
  delivery_time           INTEGER,                        -- minutes from midnight; NULL = "any time"
  delivery_type           TEXT,                           -- local|outstation; NULL when pickup
  address_text            TEXT,
  pin_lat                 REAL,
  pin_lng                 REAL,
  pin_url                 TEXT,                           -- the link as shared; often resolves better than coords
  -- D25: delivery_date and delivery_time are **derived and never edited**.
  -- They hold the last date among the order's outstanding items, rewritten by
  -- the repository whenever an item is added, edited, delivered or cancelled.
  -- The columns exist because delivery_date is NOT NULL and a v9 peer still
  -- reads it -- not because anybody types into them. There is no date picker
  -- at order level in either the create or the edit form.
  -- The remaining fulfilment columns are the defaults a new item copies.
  tracking_url            TEXT,
  discount_type           TEXT,                           -- percent|amount|NULL
  discount_value          INTEGER,                        -- basis points if percent, paise if amount
  discount_amount         INTEGER NOT NULL DEFAULT 0,     -- resolved paise; frozen at invoice
  delivery_charge         INTEGER NOT NULL DEFAULT 0,     -- paise
  requirements            TEXT,
  item_message            TEXT,                           -- piped on the item, not only on cakes
  dietary_flags           INTEGER NOT NULL DEFAULT 0,     -- bitmask
  requirements_changed_at INTEGER,
  requirements_ack_at     INTEGER,
  source                  TEXT,                           -- instagram|whatsapp|phone|referral|repeat
  notes                   TEXT,                           -- internal, never shown to the customer
  cancel_reason           TEXT,
  delivered_at            INTEGER,
  -- common columns
  CHECK (status IN ('created','confirmed','in_production','delivered','completed','cancelled'))
  -- D26: 'ready' and 'out' live on the line now. The column is still written
  -- because a v9 peer reads it; nothing in this build treats it as truth,
  CHECK (fulfilment IN ('delivery','pickup')),
  CHECK (delivery_type IS NULL OR delivery_type IN ('local','outstation')),
  CHECK (discount_type IS NULL OR discount_type IN ('percent','amount')),
  CHECK (fulfilment = 'delivery' OR (delivery_type IS NULL AND tracking_url IS NULL))
);

CREATE UNIQUE INDEX ux_orders_no      ON orders(order_no) WHERE deleted_at IS NULL;
CREATE INDEX ix_orders_delivery       ON orders(delivery_date, delivery_time, created_at)
                                      WHERE deleted_at IS NULL;
CREATE INDEX ix_orders_status         ON orders(status) WHERE deleted_at IS NULL;
CREATE INDEX ix_orders_customer       ON orders(customer_id) WHERE deleted_at IS NULL;
```

`ix_orders_delivery` is the app's main sort — date, then time, then creation. Untimed rows sort
last within a day because `NULL` sorts last in SQLite's `ASC`.

The last `CHECK` is the one that matters: **a pickup order can carry neither a delivery type
nor a tracking link.**

### dietary_flags

| Bit | |
|---|---|
| 1 | eggless |
| 2 | nut-free |
| 4 | gluten-free |
| 8 | sugar-free |

### Not stored

`subtotal`, `total`, `balance_due`, payment status. **All derived** — see
[`reporting/schema.md`](../reporting/schema.md) for the shape of an order's totals — computed
by `OrderTotals` in Dart, not by a view. Two devices cannot
disagree about a number neither one holds.

## order_items

```sql
CREATE TABLE order_items (
  id                 TEXT    NOT NULL PRIMARY KEY,
  order_id           TEXT    NOT NULL REFERENCES orders(id),
  menu_item_id       TEXT    NOT NULL REFERENCES menu_items(id),   -- NOT NULL (D16)
  item_name_snapshot TEXT    NOT NULL,   -- renaming the menu never rewrites history
  flavour            TEXT,               -- free text
  weight_value       REAL,               -- number and unit, so a bake sheet can total it
  weight_unit        TEXT,               -- g|kg|pcs|dozen

  -- ── the line's own schedule (D25) ──
  -- Migration: 01-platform/storage/lld.md §5b (v9 → v10).
  -- A line is what gets made and handed over, so it carries the when, the
  -- where and the how. Nullable only so an existing row can be backfilled;
  -- once built, delivery_date is required.
  status             TEXT NOT NULL DEFAULT 'in_production',
  delivery_date      INTEGER,            -- local midnight, epoch ms
  delivery_time      INTEGER,            -- minutes from midnight; NULL = any time
  fulfilment         TEXT,               -- delivery|pickup
  delivery_type      TEXT,               -- local|outstation; NULL for pickup
  address_text       TEXT,
  pin_lat            REAL,
  pin_lng            REAL,
  pin_url            TEXT,
  tracking_url       TEXT,
  delivered_at       INTEGER,
  cancel_reason      TEXT,               -- required when status = 'cancelled'
  qty                INTEGER NOT NULL DEFAULT 1,
  base_price         INTEGER NOT NULL,   -- paise, per unit
  note               TEXT,
  position           INTEGER NOT NULL,
  -- common columns
  CHECK (qty > 0),
  CHECK ((weight_value IS NULL) = (weight_unit IS NULL)),
  CHECK (weight_unit IS NULL OR weight_unit IN ('g','kg','pcs','dozen')),
  CHECK (weight_value IS NULL OR weight_value > 0),
  -- D25:
  CHECK (status IN ('in_production','ready','out','delivered','cancelled')),
  CHECK (fulfilment IS NULL OR fulfilment IN ('delivery','pickup')),
  CHECK (delivery_type IS NULL OR delivery_type IN ('local','outstation')),
  -- a pickup goes nowhere, so it carries no delivery type and no tracking link
  CHECK (fulfilment IS NULL OR fulfilment = 'delivery'
         OR (delivery_type IS NULL AND tracking_url IS NULL)),
  CHECK ((pin_lat IS NULL) = (pin_lng IS NULL)),
  CHECK ((status = 'cancelled') = (cancel_reason IS NOT NULL)),
  CHECK ((status = 'delivered') = (delivered_at IS NOT NULL))
);
CREATE INDEX ix_items_order ON order_items(order_id, position);
-- D25: the app's main sort key lives here now, because "what is due next" is
-- a question about lines. The list sorts on the EARLIEST outstanding line;
-- the order's own delivery_date holds the LAST one. Two questions.
CREATE INDEX ix_items_due ON order_items(delivery_date, delivery_time)
  WHERE deleted_at IS NULL AND status NOT IN ('delivered','cancelled');
CREATE INDEX ix_items_menu  ON order_items(menu_item_id);   -- price history + sales by product
```

## order_item_addons

```sql
CREATE TABLE order_item_addons (
  id            TEXT    NOT NULL PRIMARY KEY,
  order_item_id TEXT    NOT NULL REFERENCES order_items(id),
  name          TEXT    NOT NULL,
  price         INTEGER NOT NULL,   -- paise, for the LINE, not per unit
  position      INTEGER NOT NULL
  -- common columns
);
CREATE INDEX ix_addons_item ON order_item_addons(order_item_id, position);
```

## order_status_events — append-only

```sql
CREATE TABLE order_status_events (
  id          TEXT    NOT NULL PRIMARY KEY,
  order_id    TEXT    NOT NULL REFERENCES orders(id),
  from_status TEXT,
  to_status   TEXT    NOT NULL,
  reason      TEXT,
  at          INTEGER NOT NULL,
  device_id   TEXT    NOT NULL
  -- common columns
);
CREATE INDEX ix_status_order ON order_status_events(order_id, at);
```

## order_item_status_events

Built (D25).

```sql
-- Same shape as order_status_events, one level down. The order's own history
-- keeps only what a person did to the order -- confirmed, completed, cancelled
-- -- because everything between those is now derived from lines and recording
-- it twice would make the two disagree.
CREATE TABLE order_item_status_events (
  id            TEXT NOT NULL PRIMARY KEY,
  order_item_id TEXT NOT NULL REFERENCES order_items(id),
  from_status   TEXT,
  to_status     TEXT NOT NULL,
  reason        TEXT,
  at            INTEGER NOT NULL
  -- common columns
);
CREATE INDEX ix_item_status ON order_item_status_events(order_item_id, at);
```

**No UPDATE path exists.** Every transition is an insert, so two devices moving the same order
produce two events and both survive as history.

## attachments

```sql
CREATE TABLE attachments (
  id       TEXT NOT NULL PRIMARY KEY,
  order_id TEXT NOT NULL REFERENCES orders(id),
  path     TEXT NOT NULL,          -- media/ref-<uuid>.jpg in Drive
  kind     TEXT NOT NULL           -- reference|proof
  -- common columns
);
```
