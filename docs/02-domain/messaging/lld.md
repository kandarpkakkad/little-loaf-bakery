# Messaging — LLD

## 1. Schema

**Source of truth: [`schema.md`](schema.md).** Not repeated here — a schema in two places is a schema that disagrees with itself.

Tables: `share_log` — and why there is no `delivered_at`

## 2. Launch

```dart
Future<void> share(Order o, MessageKind kind) async {
  final text = compose(o, kind);
  final id   = await shareLog.insert(orderId: o.id, kind: kind, composedAt: now);
  final uri  = Uri.parse('https://wa.me/${o.customer.phoneE164.replaceAll("+","")}'
                         '?text=${Uri.encodeComponent(text)}');
  final ok = await launchUrl(uri, mode: externalApplication)
      .catchError((_) => Share.share(text));      // no WhatsApp → generic sheet
  if (ok) await shareLog.markShared(id, now);     // launched, not sent
}
```

**Encoding matters.** Newlines are `%0A`. The `*`, `_` and backtick formatting characters must
survive `encodeComponent` intact, or the message arrives as literal punctuation.

**Length:** the text goes into a URL. An order with more than 12 lines summarises
(`"…and 4 more items"`) rather than risking truncation by the launching intent.

## 3. Composition

```dart
String compose(Order o, MessageKind k) => switch (k) {
  confirmation    => _confirmation(o),
  outForDelivery  => _onItsWay(o),          // only reachable when trackingUrl != null
  delivery        => _delivery(o),          // two shapes, one function
  paymentReceived => _paymentReceived(o),
  invoice         => Invoicing.render(o.invoice!, o, config),
};

String _onItsWay(Order o) =>
  'Hi ${o.customer.firstName}, your order is on its way 🚚\n\n'
  'Order: ${o.orderNo}\n'
  'Track it here: ${o.trackingUrl}\n\n'
  '— ${config.businessName}';
// Bare on purpose. WhatsApp linkifies the URL itself; no shortening, no wrapping.

String _delivery(Order o) {
  final owed = balanceDue(o);
  return [
    'Hi ${o.customer.firstName}, your order has been delivered 🎂', '',
    'Order: ${o.orderNo}', ...itemLines(o), '',
    if (!owed.isZero) ...[
      'Total ${inr(total(o))} · Paid ${inr(paid(o))}',
      '*Balance due ${inr(owed)}*', '',
      ...payLines(config),                  // omitted entirely if neither UPI nor phone set
      '',
    ],
    if (owed.isZero)
      'Thank you for ordering from Little Loaf Bakery. We hope you enjoyed it — '
      'we would love to bake for you again.'
    else
      'Thank you for ordering from Little Loaf Bakery',
  ].join('\n');
}

String _paymentReceived(Order o) =>
  'Hi ${o.customer.firstName}, we have received your payment. Thank you!\n\n'
  '— ${config.businessName}';
```

**`_delivery` is one function with two shapes, not two messages.** The money lines are simply
absent when nothing is owed — the same rule as everywhere (D10).

## 4. When each is offered

```dart
void onTransition(Order o, Status to) => switch (to) {
  confirmed => offer(o, confirmation),
  out       => o.trackingUrl != null                      // only if there is a link
                 ? offer(o, outForDelivery) : null,
  delivered => offer(o, delivery),                        // always
  completed => hadBalanceBeforePayment(o)                 // only if there was one
                 ? offer(o, paymentReceived) : null,
  _         => null,
};

// The tracking message is also available as an action on order detail whenever
// trackingUrl != null and status is out-or-earlier — because the link is often
// pasted in after the order has already left.
bool canSendTracking(Order o) =>
    o.trackingUrl != null && o.status.index <= Status.out.index;
```
`hadBalanceBeforePayment` reads the payment history, not the current balance — by the time
Completed is reached the balance is zero by definition.

**Offer, never send.** The transition completes whether or not the message goes.

## 5. The nag

```sql
SELECT o.id, o.order_no, c.name FROM orders o
JOIN customers c ON c.id = o.customer_id
LEFT JOIN share_log s ON s.order_id = o.id AND s.kind='confirmation' AND s.shared_at IS NOT NULL
WHERE o.status >= 'confirmed' AND s.id IS NULL AND o.deleted_at IS NULL;
-- surfaced on Today as "N confirmations not sent"
```

## 6. Edge cases

| Case | Handling |
|---|---|
| Shared twice | Two log rows. Correct — it was handed over twice |
| Launched, then the user backs out without sending | Recorded as shared. **Unavoidable and stated in the UI** |
| Number changed after sharing | The log keeps what happened; nothing rewrites |
| Order cancelled after confirmation was shared | Log stays. History is history |
| Very long requirements | Truncated in the message at 300 chars with `…`; the full text is on the order and on the kitchen card |
| Tracking link is not a URL | Rejected at entry, not at send |
| Link sent, then changed | Send again. Two log rows — both are true |
| Emoji in a customer name | Fine — the whole text is URL-encoded |

## 7. What to test

- Encoding round-trip: newlines, `*bold*`, backticks, `&`, `#`, emoji, Devanagari.
- `_delivery` in both shapes, and with UPI id set / phone set / neither.
- `paymentReceived` is offered only when a balance existed before the final payment.
- WhatsApp absent → generic share sheet, same text.
- The nag query catches a confirmed order with a composed-but-never-shared row.
