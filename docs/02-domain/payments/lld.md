# Payments — LLD

## 1. Schema

**Source of truth: [`schema.md`](schema.md).** Not repeated here — a schema in two places is a schema that disagrees with itself.

Tables: `payments` — append-only, no UPDATE path

## 2. Derived status

```dart
PaymentStatus statusOf(Order o) {
  final paid = paidTotal(o), total = totalOf(o);
  if (o.status == cancelled && paid.paise <= 0) return refunded;
  if (paid.isZero)              return unpaid;         // legitimate, not a warning
  if (paid.paise >= total.paise) return paid_;
  return advancePaid;
}
```
Never stored. Two devices cannot disagree about a number neither one holds.

## 3. Recording

```dart
Future<void> record(Order o, Money amount, PaymentMode mode, {String? ref}) {
  require(amount.paise != 0, 'zero payment');
  final kind = o.status.index < Status.delivered.index ? advance : balance;
  return mutate('payment', id, (b) => b.insert(payments,
      orderId: o.id, amount: amount, kind: kind, mode: mode,
      reference: ref, paidAt: now));
  // Nothing else happens. The order does NOT advance (D15) —
  // the UI offers "Completed" once the balance reaches zero.
}
```

## 4. UPI QR

```dart
String upiUri(Config c, Money amt, String note) =>
  'upi://pay?pa=${enc(c.upiId)}&pn=${enc(c.businessName)}'
  '&am=${(amt.paise / 100).toStringAsFixed(2)}&cu=INR&tn=${enc(note)}';
// Rendered with qr_flutter on the payment sheet. Never put in a message —
// upi:// is not reliably tappable inside WhatsApp.
```
If `upiId` is unset, the QR block is absent from the sheet. Cash and transfer still work.

## 5. Outstanding report

```sql
SELECT o.id, o.order_no, c.name, t.total - COALESCE(p.paid,0) AS due,
       julianday('now') - julianday(o.delivered_at/1000,'unixepoch') AS age_days
FROM orders o
JOIN <order totals> t ON t.order_id = o.id      -- OrderTotals, in Dart
LEFT JOIN (SELECT order_id, SUM(amount) paid FROM payments
           WHERE deleted_at IS NULL GROUP BY order_id) p ON p.order_id = o.id
WHERE o.status = 'delivered' AND o.deleted_at IS NULL AND due > 0
ORDER BY age_days DESC;
```
**Delivered only.** That is what the Delivered/Completed split exists to make possible (D14).

## 6. Refunds

```dart
Future<void> refund(Order o, Money amount, String reason) {
  require(o.status == cancelled, 'refunds only against a cancelled order');
  require(amount.paise <= paidTotal(o).paise, 'cannot refund more than was paid');
  return record(o, Money(-amount.paise), mode, kind: refundKind, ref: reason);
}
```

## 7. Edge cases

| Case | Handling |
|---|---|
| Duplicate cash entry from two devices | Both stand. Deleting one is a human decision — two genuine ₹500 payments are ordinary |
| Payment then the order total changes | Balance recomputes. If it goes negative, *Refund due* is shown |
| Payment on a device with a stale order | Fine — payments are inserts and never depend on the order's current total |
| Order completed, then a payment is deleted | Balance becomes non-zero. The order **stays** Completed; nothing auto-reverses (D15). Surfaced in the outstanding report |
| Advance recorded after Delivered | Stored as `balance` — the kind reflects when, not what it was called |

## 8. What to test

- Status derivation across: zero, partial, exact, over, refunded.
- Two devices insert concurrently → both rows survive, total is the sum.
- Deleting a payment on a Completed order surfaces it in outstanding without changing status.
- `upiUri` amount formatting at `₹1,090` and `₹1,090.50`.
- Outstanding excludes Created/Confirmed/Completed, includes only Delivered with a balance.
