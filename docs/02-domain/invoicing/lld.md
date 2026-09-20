# Invoicing — LLD

## 1. Schema

**Source of truth: [`schema.md`](schema.md).** Not repeated here — a schema in two places is a schema that disagrees with itself.

Tables: `invoices`, including the shape of `frozen_totals_json`

## 2. Number

```dart
String invoiceNo(String invoiceId, int seq, Date on) =>
    'LLB/${fy(on)}/${seq.pad(4)}-${crockford4(sha256(invoiceId))}';
// fy(2026-08-29) => '26-27'   (Indian FY: April–March)
```
`seq` is this device's invoice counter — separate from the order counter, and consecutive on
this device. Gap-free is a per-device intent; the DB does not enforce it, because a crash
between allocation and commit is survivable and a gap is not a correctness problem.

## 3. Issue

```dart
Future<Invoice> issue(Order o) => mutate('invoice', id, (b) async {
  if (await invoices.existsForOrder(o.id)) return existing;   // idempotent
  final frozen = FrozenTotals(
    lines: o.items.map(snapshotLine).toList(),
    subtotal: subtotal(o), discount: discountOf(o),
    delivery: Money(o.deliveryCharge), total: total(o),
  );
  b.update(orders, discountAmount: frozen.discount.paise);    // resolve the % once, forever
  b.insert(invoices, orderId: o.id, invoiceNo: next(), issuedAt: now,
           frozenTotalsJson: frozen.toJson());
});
```

**Freezing resolves the percentage.** After issue, adding a line does not move the discount.

## 4. Rendering

```dart
String render(Invoice inv, Order o, Config c) => [
  '*${c.businessName}*', c.phone, '',
  '*Bill of Supply*', inv.invoiceNo, fmtDate(inv.issuedAt), '',
  'To: ${o.customer.name}', '',
  '```', ...monoBlock(inv.frozen, o), '```', '',
  ...payLines(o, c),
  c.termsLine,
].where((l) => l != null).join('\n');
```

**Rendered from `inv.frozen`, never from live rows.** This is the whole point of
freezing, and the code did not do it: the WhatsApp invoice rebuilt itself from
the current lines and totals, so cancelling an item after issue silently
rewrote a document the customer was already holding — under its original
number. `frozen_totals_json` was written on issue and read by nothing but
tests. Correcting an issued invoice means **voiding and reissuing**, which is
why `voided_at` exists.

**Payments are deliberately NOT frozen.** Money that arrives after the bill was
issued is real, so `Advance paid` and `BALANCE DUE` are computed live against
the frozen total. A balance quoted from the snapshot would ask the customer to
pay what they have already paid.

**`FrozenTotals` and `FrozenLine` live in `domain/invoicing/model.dart`**, not
the repository, so the pure composition layer can render an invoice without
importing the database.

### The monospace block

```
Chocolate Truffle              ← product name, own line, may wrap
Belgian dark · 1 kg            ← flavour · weight, own line
  1 x 1,450         1,450      ← qty x price ......... line total
  + Message on cake    50      ← add-on, indented
  + Candles            30
Sourdough loaf
  2 x   180           360
--------------------------     ← 26 chars
Subtotal              1,890
Discount 10%           -189    ← percentage shown when that is what was agreed
Delivery                100
TOTAL                 1,890
Advance paid            800
BALANCE DUE           1,090
```

```dart
const int W = 26;
String row(String label, Money amt) {
  final r = fmtInr(amt);                        // 1,890 — no ₹ inside the block
  return label.padRight(W - r.length).substring(0, W - r.length) + r;
}
```

**Rules**
- Every line ≤ `W`. Amounts right-aligned to `W`.
- Product name and flavour/weight get their own lines — they may wrap without harm.
- **A zero row is omitted entirely** (D10), never printed as `0`.

### Variants

| Condition | Renders |
|---|---|
| `discount_type == percent` | `Discount 10%           -189` |
| `discount_type == amount` | `Discount               -100` |
| no discount | row absent |
| no delivery charge | row absent |
| no advance | last two rows collapse to `AMOUNT DUE` |
| fully paid | collapse to `PAID · thank you`; UPI lines dropped |
| no UPI id and no phone in config | payment lines omitted; the rest still reads |

## 5. Void

```dart
Future<void> voidInvoice(Invoice i, String reason) => mutate(...,
  (b) => b.update(invoices, voidedAt: now, voidReason: reason));
// The number is never reused. Reports exclude voided invoices from revenue,
// and list them separately so the gap in the series is explained.
```

## 6. GST readiness

Columns exist and are unused: `gstin`, `hsn_code`, `tax_rate`, `cgst`, `sgst`, `igst`,
`place_of_supply`, behind `config.gst_enabled`. Turning it on retitles the document *Tax
Invoice*, reveals tax rows and starts a separate series.

**Known constraint:** a GST invoice number is capped at **16 characters**.
`LLB/26-27/0148-K7QP` is 19. The series shortens at that point — dropping the hyphens and
using a two-letter prefix reaches 16. Not worth contorting now.

## 7. Edge cases

| Case | Handling |
|---|---|
| Issue called twice | Unique `order_id` makes the second a no-op |
| Order line edited after issue | Invoice unchanged; order detail shows *"invoice issued before this edit"* |
| Item name longer than 26 chars | Wraps. Nothing is aligned to it, so alignment survives |
| Amount ≥ 10,00,000 | Label truncates before the amount does. The amount is never clipped |
| FY boundary | `fy()` uses the issue date, not today |
| Voided then re-delivered | Not possible — Delivered → Completed is the only path out |

## 8. What to test

- Every variant in §4 renders with **no line over 26 characters** — property test over random orders.
- Freezing: issue, then mutate the order, assert the invoice is byte-identical.
- Numbering: 1,000 sequential issues on one device, no duplicates, no gaps.
- Void keeps the number and removes it from revenue.
- A 40-character product name still leaves the totals column aligned.
