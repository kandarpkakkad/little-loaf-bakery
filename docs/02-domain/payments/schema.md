# Payments — schema

Common columns: [`01-platform/storage/schema.md`](../../01-platform/storage/schema.md)

## payments — append-only

```sql
CREATE TABLE payments (
  id        TEXT    NOT NULL PRIMARY KEY,
  order_id  TEXT    NOT NULL REFERENCES orders(id),
  amount    INTEGER NOT NULL,        -- paise; NEGATIVE for a refund
  kind      TEXT    NOT NULL,        -- advance|balance|refund
  mode      TEXT    NOT NULL,        -- upi|cash|transfer
  reference TEXT,
  paid_at   INTEGER NOT NULL,
  -- common columns
  CHECK (amount <> 0),
  CHECK (kind IN ('advance','balance','refund')),
  CHECK (mode IN ('upi','cash','transfer')),
  CHECK ((kind = 'refund') = (amount < 0))
);
CREATE INDEX ix_pay_order ON payments(order_id, paid_at) WHERE deleted_at IS NULL;
```

**No UPDATE statement exists for this table.** A mistake is corrected by tombstoning the row
and inserting the right one, which leaves the correction visible. That is also what makes two
devices recording money at the same moment safe — the amounts simply add.

The last `CHECK` ties sign to kind, so a refund can never be stored as a positive.

### Not stored

Payment status — Unpaid / Advance paid / Paid / Refunded — is **derived** from the sum of
payments against the order total. Never a column, so it can never drift.

**Unpaid is a legitimate confirmed state** (D9). Nothing in the UI treats it as a warning.
