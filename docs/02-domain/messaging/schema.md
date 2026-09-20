# Messaging — schema

Common columns: [`01-platform/storage/schema.md`](../../01-platform/storage/schema.md)

## share_log — append-only

```sql
CREATE TABLE share_log (
  id          TEXT    NOT NULL PRIMARY KEY,
  order_id    TEXT    NOT NULL REFERENCES orders(id),
  kind        TEXT    NOT NULL,
  composed_at INTEGER NOT NULL,
  shared_at   INTEGER,              -- set when the intent LAUNCHED
  device_id   TEXT    NOT NULL,
  -- common columns
  CHECK (kind IN ('confirmation','out_for_delivery','delivery','payment_received','invoice'))
  -- 'invoice' is still ACCEPTED though nothing writes it: rows logged before
  -- invoicing was removed (D30) still carry it, and tightening the CHECK would
  -- mean rebuilding the table underneath them for no gain.
);
CREATE INDEX ix_share_order ON share_log(order_id, composed_at) WHERE deleted_at IS NULL;
CREATE INDEX ix_share_unsent ON share_log(order_id) WHERE shared_at IS NULL AND deleted_at IS NULL;
```

## What `shared_at` means, and what it does not

It means **"we handed this to WhatsApp"**. It does not mean sent, delivered or read.

**There is deliberately no `delivered_at` and no `read_at`.** Those cannot be known through a
share intent, and a column would invite someone to populate it with a guess. The UI says
*"Shared 7:12 pm"*, never "Delivered ✓✓".

## Rows per order

| kind | When |
|---|---|
| `confirmation` | At Confirmed. Always |
| `out_for_delivery` | At Out for delivery, **only if `orders.tracking_url` is set** |
| `delivery` | At Delivered. Always — two shapes, one kind |
| `payment_received` | At Completed, **only if there was a balance to receive** |

Sharing the same message twice produces **two rows**, and that is correct — it was handed over
twice.

`ix_share_unsent` backs the Today nag: any confirmed order with a composed-but-never-shared
row.
