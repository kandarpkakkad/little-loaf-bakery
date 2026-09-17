# Orders — LLD

## 1. Schema

**Source of truth: [`schema.md`](schema.md).** Not repeated here — a schema in two places is a schema that disagrees with itself.

Tables: `orders`, `order_items`, `order_item_addons`, `order_status_events`, `attachments`

## 2. Totals — computed, never stored

```dart
Money lineTotal(OrderItem i) =>
    i.basePrice.times(i.qty) + i.addons.fold(Money.zero, (a, x) => a + x.price);

Money subtotal(Order o) => o.items.fold(Money.zero, (a, i) => a + lineTotal(i));

Money discountOf(Order o) => switch (o.discountType) {
  null      => Money.zero,
  amount    => Money(o.discountValue),
  percent   => subtotal(o).percentRounded(o.discountValue),   // half-up to the rupee
};

Money total(Order o)      => subtotal(o) - discountOf(o) + Money(o.deliveryCharge);
Money paid(Order o)       => o.payments.fold(Money.zero, (a, p) => a + p.amount);
Money balanceDue(Order o) => total(o) - paid(o);
```

**The percentage applies to the subtotal, never to delivery.** Nobody intends "10% off" to
discount the courier.

**Freezing:** when the invoice is issued (at Delivered), `discount_amount` is written with the
resolved figure and the invoice stores `frozen_totals_json`. After that the document never
quietly changes what it says, even if a line is corrected.

## 3. Order number

```dart
String orderNo(String orderId, int seq) =>
    'LLB-${seq.toString().padLeft(4, '0')}-${crockford4(sha256(orderId))}';
// Crockford base32, minus I L O U — these get read aloud on the phone.
```
`seq` is this device's own counter, consecutive on that device. The hash makes the whole
number unique regardless (D8). The number is **not** the primary key.

## 4. State machine

```dart
const allowed = {
  created:       {confirmed, cancelled},
  confirmed:     {in_production, cancelled},
  in_production: {ready, cancelled},
  ready:         {out, cancelled},
  out:           {delivered, cancelled},
  delivered:     {completed},          // no cancel after handover
  completed:     {},                   // terminal
  cancelled:     {},
};
```

```dart
Future<void> transition(Order o, Status to, {String? reason}) async {
  require(allowed[o.status]!.contains(to), 'illegal transition');
  if (to == confirmed)  requireConfirmable(o);
  if (to == cancelled)  require(reason != null, 'cancellation needs a reason');
  if (to == completed)  require(balanceDue(o).isZero, 'balance still outstanding');

  await mutate('order', o.id, (b) {
    b.update(orders, status: to);
    b.insert(orderStatusEvents, from: o.status, to: to, reason: reason, at: now);
    if (to == delivered) Invoicing.issue(o);       // domain event, not a direct call
  });
  // The UI then OFFERS the next thing. Nothing here moves the order again. (D15)
}

void requireConfirmable(Order o) {
  require(o.items.isNotEmpty,            'at least one line');
  require(o.customer.phoneE164 != null,  'a valid WhatsApp number');
  require(o.deliveryDate != null,        'a delivery date');
  // NO advance requirement (D9)
}
```

**`completed` requires a zero balance** — it is the one guarded transition, because it means
"the money is in".

## 5. Sort order

```sql
ORDER BY delivery_date ASC,
         delivery_time IS NULL ASC,   -- timed first
         delivery_time ASC,
         created_at ASC               -- breaks every tie, including among untimed
```
Untimed orders gather at the end of their day under *Any time*, ordered among themselves by
creation. Stable — it never rearranges itself.

## 6. Rush warning

```dart
final leadDays = o.items.map((i) => i.menuItem.leadDays).fold(0, max);
final rush = o.deliveryDate.isBefore(today.add(Duration(days: leadDays)));
// Non-blocking. Shown on the form, and as a chip on the board card.
```

## 7. Requirements change flag

```dart
// on any edit to requirements / item_message / dietary_flags while status >= confirmed
requirements_changed_at = now; requirements_ack_at = null;
// kitchen taps Acknowledge on the board card or order detail
requirements_ack_at = now;
final flagged = requirements_changed_at != null &&
                (requirements_ack_at == null || requirements_ack_at < requirements_changed_at);
```

## 8. Address

```dart
// "Same as last order" — shown only if this customer has a previous order with an address
final prior = await orders.lastWithAddressFor(customerId);
// unchecked by default; ticking copies address_text + pin_* onto THIS order
```
Pin capture: paste a shared link, extract `lat,lng` where present, keep `pin_url` regardless
— a Plus Code or place link often resolves better than bare coordinates. **No GPS, ever.**

## 8b. Delivery type and tracking

```dart
enum DeliveryType { local, outstation }     // NULL when fulfilment == pickup

Money defaultCharge(DeliveryType t) => switch (t) {
  local      => config.deliveryChargeLocal,
  outstation => config.deliveryChargeOutstation,
};
// Changing the type re-applies its default ONLY if the charge is still untouched.
// Once someone has typed a number, the type no longer overwrites it.

Future<void> setTracking(Order o, String url) {
  require(o.status.index < Status.delivered.index, 'already delivered');
  require(isHttpUrl(url), 'not a link');
  return mutate('order', o.id, (b) => b.update(orders, trackingUrl: url));
}
```

**Both types can carry a link** — a local rider app and an outstation courier both produce
one. The type drives the default charge and the reporting cut; the link drives the message.

**Where it is entered:** the order form, and the delivery run — because booking the courier is
something you do while looking at the run, not while taking the order.

## 9. Edge cases

| Case | Handling |
|---|---|
| Confirm with no advance | Allowed. Whole amount becomes balance due |
| Discount larger than subtotal | Clamp to subtotal. Total never goes negative |
| Percentage discount, then a line is added | Recomputes while editable; frozen at invoice |
| Delivery charge edited at handover | Balance recalculates; invoice carries the charged figure |
| Quantity set to 0 | Rejected — remove the line instead |
| All lines removed from a confirmed order | Rejected. Cancel it instead |
| Two devices confirm the same order | Same target status; LWW resolves to one; both status events survive in history |
| Cancel after Delivered | Not allowed by the state machine |
| Delivery type changed after a charge was typed | Charge is **not** overwritten. The default applies only to an untouched field |
| Tracking link added after Out for delivery | Allowed until Delivered; the message becomes offerable at that point |
| Pickup order given a tracking link | Rejected — `delivery_type` is NULL and there is nothing to track |
| Menu item made inactive after ordering | Line unaffected — it holds the name snapshot |

## 10. What to test

- Every illegal transition is rejected, and every legal one emits exactly one status event.
- `completed` blocked while a balance remains; allowed the instant it hits zero.
- Totals: percentage rounding at `.5` paise; discount clamping; add-ons not multiplied by qty.
- Sort: mixed timed/untimed on one day, asserting the exact expected order.
- Requirements flag: set on edit after confirm, cleared only by a *later* acknowledgement.
- Two-device edit of different fields on one order → both survive.
- Freeze: issue an invoice, change a line, assert the invoice total is unchanged.
