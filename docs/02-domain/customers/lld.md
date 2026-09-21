# Customers — LLD

## 1. Schema

**Source of truth: [`schema.md`](schema.md).** Not repeated here — a schema in two places is a schema that disagrees with itself.

Tables: `customers`

## 2. Phone normalisation

```dart
String? toE164(String raw, {String defaultCc = '+91'}) {
  final d = raw.replaceAll(RegExp(r'[^\d+]'), '');
  if (d.startsWith('+'))    return validate(d);
  if (d.length == 10)       return validate('$defaultCc$d');
  if (d.startsWith('0'))    return validate('$defaultCc${d.substring(1)}');
  if (d.startsWith('91') && d.length == 12) return validate('+$d');
  return null;      // reject — a bad number means wa.me opens a blank chat
}
```
Validated on entry, not at send time. The failure has to surface while someone can fix it.

## 3. Dedupe on merge

Two devices can both create the same person offline. On the second op arriving:

```dart
Future<void> onCustomerUpsert(Op op) async {
  final clash = await customers.findByPhone(op.fields['phone_e164']);
  if (clash != null && clash.id != op.entityId) {
    final survivor = clash.id.compareTo(op.entityId) < 0 ? clash.id : op.entityId;  // UUID v7 = older wins
    final loser    = survivor == clash.id ? op.entityId : clash.id;
    await orders.reassign(from: loser, to: survivor);
    await mergeNonEmptyFields(from: loser, to: survivor);   // keep any note the loser had
    await tombstone('customer', loser);
  }
}
```

**The older UUID wins**, deterministically, so every device reaches the same survivor without
coordination.

## 4. Derived values

Shown as SQL for the shape; computed in Dart by summing `OrderTotals` over the customer's
orders, so it cannot disagree with what the order screen shows.

```sql
-- lifetime value: completed orders only
SELECT SUM(total) FROM <order totals> t JOIN orders o ON o.id = t.order_id
WHERE o.customer_id = ? AND o.status = 'completed' AND o.deleted_at IS NULL;

-- outstanding: delivered, not yet completed
SELECT SUM(balance_due) ... WHERE o.status = 'delivered';

-- last address, as a reference and for "Same as last order"
SELECT address_text, pin_lat, pin_lng, pin_url FROM orders
WHERE customer_id = ? AND address_text IS NOT NULL AND deleted_at IS NULL
ORDER BY created_at DESC LIMIT 1;
```

## 4b. Addresses are learned from orders

A customer's addresses come from two places, and for a long time only one of
them worked.

```dart
// in OrderRepository._subOrderFor -- the single point at which a journey, and
// therefore an address, comes into existence
if (!isPickup) await rememberAddress(orderId, line);

Future<void> rememberAddress(String orderId, DraftLine l) async {
  if (l.addressText.isNullOrBlank) return;
  final saved = await addresses(order.customerId);
  // the same door typed twice, with different spacing or capitals, is one
  // address -- not a second one cluttering the picker
  if (saved.any((a) => norm(a.addressText) == norm(l.addressText))) return;
  insert(customerAddresses,
    label: l.addressLabel ?? 'Home',
    isDefault: saved.isEmpty);          // the first one leads the list
}
```

**Why it was missing.** `pickAddress` offers the saved addresses and lets a new
one be typed, and the typed one went onto the journey and no further —
`address_picker.dart` even said so ("has not been saved against the customer
yet") and nothing finished the sentence. Only the Customers screen's own button
reached `customer_addresses`, so a customer who had only ever been given an
address while ordering showed none on their page and got an empty picker on
their next order.

**Saved on order write, not on typing**, so an abandoned order leaves nothing
behind. **Pickups save nothing** — there is no door. **The label travels with
the draft** (`DraftLine.addressLabel`); it used to be dropped between the picker
and the line, so the name the customer gave a door was lost even where one was
stored.

Addresses from orders placed **before this existed are not backfilled** — the
journeys kept their text, and the customer's list starts from the next order.

## 5. Allergy pull-forward

```dart
// on order create, and whenever the customer is changed on a draft order
if (customer.allergyNote != null) order.showAllergyBanner(customer.allergyNote);
```
Displayed as a banner on the order form and on the board card. **Not copied into the order's
own requirements** — it belongs to the person, and editing it should update it everywhere.

## 6. Edge cases

| Case | Handling |
|---|---|
| Same person, two numbers | Two rows. `alt_phone` exists for the second number on one record; merging is manual |
| Number reassigned to a different person by the telco | Rare and unsolvable. Editing the name is the fix |
| Customer with no orders | Allowed — created inline during a draft that is then abandoned |
| Dedupe merge while an order is open on another device | Reassignment is an op; the other device follows |

## 7. What to test

- `toE164` across: `98765 43210`, `+91 98765-43210`, `098765 43210`, `9198765 43210`, junk.
- Offline duplicate creation on two devices → one survivor, orders reassigned, the same
  survivor chosen on **both** devices.
- Allergy note edited after orders exist → banner updates on all of them.
- Lifetime value counts completed only; outstanding counts delivered only.

## On a screen with room

An expansion tile is a phone's answer to not having a second pane. With the
room, the pane is strictly better, because it can show **what they have
ordered** — which is the question somebody opens a customer to answer, and a
tile had nowhere to put it.

| | |
|---|---|
| Phone | The list, each row expanding to its addresses |
| Tablet | A list of names beside `CustomerDetail`: who they are, their allergy note, their addresses, and their orders as cards that open |

The address list is one widget used by both, so the two cannot drift into
showing different things about the same person.
