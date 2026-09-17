# Invoicing — schema

Common columns: [`01-platform/storage/schema.md`](../../01-platform/storage/schema.md)

## invoices

```sql
CREATE TABLE invoices (
  id                 TEXT    NOT NULL PRIMARY KEY,
  order_id           TEXT    NOT NULL REFERENCES orders(id),
  invoice_no         TEXT    NOT NULL,         -- LLB/26-27/0148-K7QP
  issued_at          INTEGER NOT NULL,         -- set at Delivered
  frozen_totals_json TEXT    NOT NULL,
  voided_at          INTEGER,
  void_reason        TEXT,
  -- GST, present and unused until settings.gst_enabled
  hsn_code           TEXT,
  tax_rate           INTEGER,
  cgst               INTEGER,
  sgst               INTEGER,
  igst               INTEGER,
  place_of_supply    TEXT
  -- common columns
);
CREATE UNIQUE INDEX ux_inv_order ON invoices(order_id)   WHERE deleted_at IS NULL;
CREATE UNIQUE INDEX ux_inv_no    ON invoices(invoice_no) WHERE deleted_at IS NULL;
```

`ux_inv_order` is doing real work: it makes **double-issue a no-op** when two devices both
reach Delivered.

## frozen_totals_json

Written once, at issue, and never touched again. The invoice says the same thing forever even
if the order is later corrected.

```jsonc
{
  "lines": [
    { "name": "Chocolate Truffle", "flavour": "Belgian dark", "weight": "1 kg",
      "qty": 1, "base_price": 145000, "line_total": 153000,
      "addons": [ {"name":"Message on cake","price":5000},
                  {"name":"Candles","price":3000} ] }
  ],
  "subtotal": 189000,
  "discount": { "type": "amount", "value": 10000, "resolved": 10000 },
  "delivery": 10000,
  "total":    189000
}
```

All money in **paise**. `discount.resolved` is the figure a percentage worked out to — stored
so the document never quietly changes when a line is added later.

## Numbering

`invoice_no` = `LLB` / financial year / this device's sequence / hash of the invoice UUID.
The sequence lives in `settings.invoice_seq`, **local and never replicated** — which is why a
restored install takes a new device id and starts a fresh series.

**Voided, never deleted.** Numbers are never reused; reports exclude voided invoices from
revenue and list them separately, so a gap in the series is explained rather than mysterious.

> **GST caps an invoice number at 16 characters.** `LLB/26-27/0148-K7QP` is 19, so the series
> shortens when `gst_enabled` is switched on.
