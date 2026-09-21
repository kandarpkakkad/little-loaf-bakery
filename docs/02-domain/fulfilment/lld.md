# Fulfilment — LLD

## 1. Production board

```sql
SELECT o.id, o.order_no, c.name, oi.item_name_snapshot, oi.flavour, oi.weight_value, oi.weight_unit,
       o.delivery_time, o.dietary_flags, o.requirements, o.item_message,
       (o.requirements_changed_at IS NOT NULL AND
        (o.requirements_ack_at IS NULL OR o.requirements_ack_at < o.requirements_changed_at)) AS flagged
FROM orders o JOIN customers c ON c.id=o.customer_id
JOIN order_items oi ON oi.order_id=o.id
WHERE o.delivery_date BETWEEN :from AND :to
  AND o.status IN ('confirmed','in_production','ready','out')
  AND o.deleted_at IS NULL
ORDER BY o.delivery_date, o.delivery_time IS NULL, o.delivery_time, o.created_at;
```

**Never selects a price column.** Not hidden in the UI — absent from the query.

Columns are the four in-flight statuses. Dragging a card calls `Orders.transition`, which is
the same guarded path as everywhere else.

> **Built (D25, D26).** Both queries above filtered on `o.delivery_date` and
> `o.status`. Once a line carries its own date and status, the board is a board
> **of lines**, not of orders, and every predicate moves one level down:
>
> ```sql
> WHERE oi.delivery_date BETWEEN :from AND :to
>   AND oi.status IN ('confirmed','in_production','ready','out')
>   AND oi.deleted_at IS NULL AND o.deleted_at IS NULL
> ORDER BY oi.delivery_date, oi.delivery_time IS NULL, oi.delivery_time, oi.position;
> ```
>
>
> **The board starts at `confirmed`, not `in_production`.** Confirming an order
> is what hands its items to the kitchen; before that it is still a
> conversation with the customer. Starting at `in_production` meant work only
> appeared once somebody had already begun it, so the board showed what was
> under way and never what was coming — which is the half a kitchen needs.
>
> This is the change the kitchen actually feels. An order with a cake on Friday
> and a snack box on Sunday currently appears whole on one day or the other;
> afterwards each line appears on its own day, which is the only version a baker
> can work from. Dragging a card calls `transitionLine`.
>
> The order's `confirmed` state still gates the board — an unconfirmed order's
> lines are not work yet — but it is read through `orderStatus(o)` rather than a
> stored column.

## 2. Daily production sheet

```sql
SELECT oi.menu_item_id, oi.item_name_snapshot, oi.weight_value, oi.weight_unit,
       SUM(oi.qty) AS total_qty,
       SUM(CASE WHEN o.dietary_flags & 1 THEN oi.qty ELSE 0 END) AS eggless,
       SUM(CASE WHEN o.dietary_flags & 2 THEN oi.qty ELSE 0 END) AS nut_free,
       GROUP_CONCAT(CASE WHEN o.requirements IS NOT NULL
                         THEN c.name || ' — ' || o.requirements END, char(10)) AS notes
FROM order_items oi
JOIN orders o ON o.id=oi.order_id JOIN customers c ON c.id=o.customer_id
WHERE o.delivery_date = :day AND o.status IN ('confirmed','in_production')
  AND o.deleted_at IS NULL
GROUP BY oi.menu_item_id, oi.weight_value, oi.weight_unit
ORDER BY oi.item_name_snapshot;
```
Requirements are concatenated **in full**. If they are long, the row grows — nothing is elided.

**Built (D25):** `WHERE oi.delivery_date = :day AND oi.status = 'in_production'`,
so a day's sheet lists what is due *that* day rather than every line of every
order that has a line due that day.

## 3. Delivery run

```sql
SELECT o.id, o.order_no, c.name, c.phone_e164, o.delivery_time,
       o.address_text, o.pin_lat, o.pin_lng, o.pin_url,
       o.delivery_type, o.tracking_url,
       o.delivery_charge, t.total - COALESCE(p.paid,0) AS to_collect, o.status
FROM orders o ... 
WHERE o.delivery_date = :today AND o.fulfilment='delivery'
  AND o.status IN ('ready','out','delivered') AND o.deleted_at IS NULL
ORDER BY o.delivery_time IS NULL, o.delivery_time, o.created_at;
```
Pickup orders are excluded — no address, nowhere to go.

### Editing the charge at handover
```dart
Future<void> setDeliveryCharge(Order o, Money c) {
  require(o.status.index < Status.completed.index, 'order already completed');
  return mutate('order', o.id, (b) => b.update(orders, deliveryCharge: c.paise));
  // to_collect recomputes. Nothing is frozen anywhere: invoicing is gone (D30)
}
```

### Tracking link, entered on the run

```dart
// The courier is booked while looking at the run, so the field lives here too.
Row: TextField "Tracking link"  value=@o.trackingUrl  keyboard=url
     when @o.trackingUrl != null
       Button text "Send link" -> messaging.offer(outForDelivery)
```
Entering a link does **not** move the order. Marking it Out for delivery is still a separate
tap (D15), and that transition offers the message.

## 4. Location chooser

```dart
Future<List<LocationTarget>> targets(Order o) async {
  final t = <LocationTarget>[];
  final hasPin = o.pinLat != null;
  final q = hasPin ? '${o.pinLat},${o.pinLng}' : Uri.encodeComponent(o.addressText ?? '');

  if (await canLaunch('geo:0,0?q=$q'))
    t.add(LocationTarget('Google Maps', 'geo:0,0?q=$q($label)'));

  if (hasPin && await isInstalled('com.ubercab'))
    t.add(LocationTarget('Uber',
      'uber://?action=setPickup&dropoff[latitude]=${o.pinLat}'
      '&dropoff[longitude]=${o.pinLng}&dropoff[nickname]=${enc(label)}'));

  for (final a in [rapido, porter]) {              // UNVERIFIED — see HLD
    if (await isInstalled(a.package))
      t.add(LocationTarget(a.name, a.deepLink(o), fallback: () async {
        await Clipboard.setData(o.addressText);    // always works
        await launchPackage(a.package);
      }));
  }

  t.add(LocationTarget('Copy address', copy: o.addressText));   // always last, always present
  return t;
}
```

**Every entry degrades to "the app opens with the address on the clipboard".** Nothing in this
list is allowed to be a dead end.

## 5. Edge cases

| Case | Handling |
|---|---|
| Order has a pin but no address text | Maps works; Copy address is disabled with a hint |
| Address but no pin | Maps searches the text; Uber is omitted (it needs coordinates) |
| Neither | The chooser is not offered at all |
| Card dragged while offline | Queued; conflict log catches a clash on sync |
| Same order marked Delivered on two devices | Same status; one wins; both events survive in history |
| Sheet printed then an order is added | Sheet is a live view. Print is a screenshot of a moment |

## 6. What to test

- Board query returns **no price column** — assert on the SQL, not the widget.
- Sheet grouping: two orders of the same item at different weights stay separate rows.
- Requirements over 300 characters render in full on card and sheet.
- Delivery-charge edit recomputes `to_collect` immediately and is audit-trailed.
- Chooser with: pin only · address only · both · neither · no apps installed.
- Untimed stop sorts last in the run.
