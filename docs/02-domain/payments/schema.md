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

**No refund can be created, as of 30 Sep 2026.** The columns and the CHECK stay — they
describe a shape the schema still allows and an older peer may still send — but the app
refuses to write one. `addPayment` takes an amount coming in and nothing else, and
`editPayment` no longer turns a payment into a refund by making it negative, which was the
only route to one.

Refunding is its own feature, not a payment with a minus sign. It changes what the balance
means, what the outstanding total counts and what the payment message says, and none of that
has been designed. A payment typed by mistake is **removed**, not reversed.

Credit — `paid > total` — is unaffected and still reachable honestly: by overpaying, or by
cancelling an item after it was paid for.

### Not stored

Payment status — Unpaid / Advance paid / Paid — is **derived** from the sum of
payments against the order total. Never a column, so it can never drift.

**Unpaid is a legitimate confirmed state** (D9). Nothing in the UI treats it as a warning.
