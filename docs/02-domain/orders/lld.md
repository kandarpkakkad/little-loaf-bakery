# Orders — LLD

## 1. Schema

**Source of truth: [`schema.md`](schema.md).** Not repeated here — a schema in two places is a schema that disagrees with itself.

Tables: `orders`, `order_items`, `order_item_addons`, `order_status_events`, `attachments`

## 2. Totals — computed, never stored

```dart
Money lineTotal(OrderItem i) =>
    i.basePrice.times(i.qty) + i.addons.fold(Money.zero, (a, x) => a + x.price);

// NOT BUILT (D27): a cancelled line leaves the total entirely. Excluding it
// here is what can put a paid-up order into credit -- see §4.4.
Money subtotal(Order o) => o.items
    .where((i) => i.status != cancelled)
    .fold(Money.zero, (a, i) => a + lineTotal(i));

Money discountOf(Order o) => switch (o.discountType) {
  null      => Money.zero,
  amount    => Money(o.discountValue),
  percent   => subtotal(o).percentRounded(o.discountValue),   // half-up to the rupee
};

Money total(Order o)      => subtotal(o) - discountOf(o) + Money(o.deliveryCharge);
Money paid(Order o)       => o.payments.fold(Money.zero, (a, p) => a + p.amount);
Money balanceDue(Order o) => total(o) - paid(o);
// Negative balance is not a balance. NOT BUILT (D27):
bool  inCredit(Order o)     => balanceDue(o).paise < 0;
Money creditDue(Order o)    => inCredit(o) ? -balanceDue(o) : Money.zero;
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

> **Not built** (D25, D26). The app today has one status on the order and one
> delivery date on the order. What follows replaces both. Everything in §4.1–4.4
> is design.

### 4.1 The line is the thing that moves

A line is what gets made and handed over, so the line has the status:

```dart
const lineAllowed = {
  in_production: {ready, cancelled},
  ready:         {out, delivered, cancelled},   // pickup skips 'out'
  out:           {delivered, cancelled},
  delivered:     {},                            // terminal; no cancel after handover
  cancelled:     {},
};
```

`ready → delivered` without passing `out` is legal and is the **pickup** path:
nothing goes out for delivery when the customer collects it. A line whose
`fulfilment` is `pickup` may not enter `out` at all.

### 4.2 The order's status is read, not written

```dart
Status orderStatus(Order o) {
  final live = o.items.where((i) => i.status != cancelled);

  if (live.isEmpty)                       return cancelled;   // every line gone
  if (o.confirmedAt == null)              return created;
  if (live.every((i) => i.status == delivered))
                                          return o.completedAt != null
                                            ? completed
                                            : delivered;
  if (live.any((i) => i.status != in_production) || o.startedAt != null)
                                          return in_production;
  return confirmed;
}
```

Only three moments are written by a person, and they are the three that are not
facts about lines:

| Written | Why it cannot be derived |
|---|---|
| `confirmed_at` | a conversation with the customer, not a state of the cakes |
| `completed_at` | deliberate, and still requires a zero balance |
| `cancelled` (all lines) | needs a reason, and the reason belongs to the order |

The order's **due date** is derived the same way — the earliest line still
outstanding, which is the honest answer to "when does this order next need me":

```dart
int? dueAt(Order o) => o.items
    .where((i) => i.status != delivered && i.status != cancelled)
    .map((i) => i.deliveryDate)
    .fold(null, (a, b) => a == null || b < a ? b : a);
```

Today, Kitchen and the Orders sort all read `dueAt`. An order with a cake on
Friday and a snack box on Sunday appears on Friday, and again on Sunday once
Friday's line is delivered.

### 4.3 Moving several lines at once

Deriving the order status costs the one-tap "the whole order is ready" move, so
the UI keeps it as a bulk action over lines rather than a status on the order:

```dart
Future<void> advanceAll(Order o, LineStatus to) async {
  final movable = o.items.where((i) => lineAllowed[i.status]!.contains(to));
  for (final line in movable) await transitionLine(line, to);
  // Lines that cannot legally reach `to` are skipped in silence: the intent is
  // "catch everything up", and refusing the whole batch because one line is
  // already delivered would be a worse reading of that intent.
}
```

### 4.4 Cancelling one line

A cancelled line leaves the totals (§2), which is the part that surprises:

```dart
Future<void> cancelLine(OrderItem i, String reason) async {
  require(i.status != delivered, 'delivered lines cannot be cancelled');
  // The order total drops. If payments already cover more than the new total,
  // the order is in **credit** -- surfaced as such, not as a negative balance,
  // and settled by recording a refund payment.
}
```

If every line is cancelled the order is cancelled, and the reason shown is the
last line's.

### 4.5 Writing a move

```dart
Future<void> transitionLine(OrderItem i, LineStatus to, {String? reason}) async {
  require(lineAllowed[i.status]!.contains(to), 'illegal transition');
  require(to != out || i.fulfilment == delivery, 'a pickup never goes out');
  if (to == cancelled) require(reason != null, 'cancellation needs a reason');

  await mutate('order_item', i.id, (b) {
    b.update(orderItems, status: to, deliveredAt: to == delivered ? now : null);
    b.insert(orderItemStatusEvents, from: i.status, to: to, reason: reason, at: now);
    // The order's own status is derived, so there is nothing to update on it.
    // The invoice is the exception: it is issued once, when the LAST live line
    // is delivered, because an invoice covers the order and not the line.
    if (to == delivered && everyLiveLineDelivered(i.order)) Invoicing.issue(i.order);
  });
  // The UI then OFFERS the next thing. Nothing here moves anything again. (D15)
}

/// Only the three order-level moments (§4.2).
Future<void> confirmOrder(Order o) async {
  requireConfirmable(o);
  await mutate('order', o.id, (b) {
    b.update(orders, confirmedAt: now);
    b.insert(orderStatusEvents, from: created, to: confirmed, at: now);
  });
}

void requireConfirmable(Order o) {
  require(o.items.isNotEmpty,                  'at least one line');
  require(o.customer.phoneE164 != null,        'a valid WhatsApp number');
  require(o.items.every((i) => i.deliveryDate != null),
                                               'every line needs a date');
  // NO advance requirement (D9)
}
```

**`completed` requires a zero balance** — it is the one guarded transition, because it means
"the money is in". It is refused while the order is in credit too: a refund is owed, and
"completed" would bury it.

## 5. Sort order

Every list reads the same way — earliest first, in one direction. A list that
changes direction with the tab is harder to read than one that never does, so
Delivered and Cancelled sort forward alongside Open.

```sql
ORDER BY delivery_date ASC,
         delivery_time IS NULL ASC,   -- timed first
         delivery_time ASC,
         created_at ASC               -- breaks every tie, including among untimed
```

**NOT BUILT (D25).** Once lines carry the date, the order list sorts by the
derived `dueAt` (§4.2) rather than a column, so the same ordering has to be
expressed over the lines:

```sql
-- the order's position is its earliest outstanding line
LEFT JOIN (
  SELECT order_id,
         MIN(delivery_date) AS due_date,
         MIN(delivery_time) AS due_time      -- of that date's lines
  FROM   order_items
  WHERE  deleted_at IS NULL
    AND  status NOT IN ('delivered','cancelled')
  GROUP BY order_id
) due ON due.order_id = o.id
ORDER BY due.due_date ASC, due.due_time IS NULL ASC, due.due_time ASC, o.created_at ASC
```

An order with every line delivered has no `due_date` and sorts last — which is
right, because it is waiting on money rather than on the kitchen.
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
