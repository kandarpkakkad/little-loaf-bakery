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
