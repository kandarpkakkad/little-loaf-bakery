# Menu — LLD

## 1. Schema

**Source of truth: [`schema.md`](schema.md).** Not repeated here — a schema in two places is a schema that disagrees with itself.

Tables: `menu_items`

**No price column. No flavour column.** Both are decided per order (D17).

## 2. Availability

One gate, not two: `active` is a switch somebody flips — "we have stopped
making this". That is all.

**Seasonality was removed.** `season_from` / `season_to` were a fact about the
year that had to be set per item and then never looked at again, and no bakery
here needed it: a place that makes plum cake in December simply makes it in
December. What it cost was two month pickers between a person and saving a menu
item, and a note beside every name in the order picker explaining something
nobody had asked about. The columns survive this release because a v9 peer
still writes them; nothing reads them.

## 3. The picker

```
A flat list, whole thing on screen — no search-first, and no grouping: the
item *is* the category ("Cake", "Croissant", "Focaccia"), so there is no second
level to group by.
Inactive items are excluded — the picker asks for `list(activeOnly: true)`.
Everything else is shown by name and nothing else,
and hiding it would leave someone wondering whether they imagined it.
```

The picker creates nothing. An item that is not on the menu is added under
*More › Menu items* first — see D16 for why that cost was accepted. With an empty
menu the picker does not open at all; it says so and points at Config.

## 4. Flavour suggestions

```sql
SELECT flavour, MAX(created_at) AS last_used, COUNT(*) AS n
FROM order_items WHERE menu_item_id = ? AND flavour IS NOT NULL AND deleted_at IS NULL
GROUP BY flavour ORDER BY last_used DESC LIMIT 8;
```
Suggestions only. Typing something new is always allowed — flavour is free text.

## 5. Price hints

```sql
-- the customer's own last price for this item first, then recent prices across everyone
SELECT oi.base_price, o.created_at, o.customer_id
FROM order_items oi JOIN orders o ON o.id = oi.order_id
WHERE oi.menu_item_id = ? AND oi.deleted_at IS NULL
ORDER BY (o.customer_id = :thisCustomer) DESC, o.created_at DESC
LIMIT 3;
```
Rendered as chips. **Tapping fills the field; nothing auto-fills.** Nothing is ever priced by
accident.

## 6. Edge cases

| Case | Handling |
|---|---|
| Two items with the same name | Allowed, and indistinguishable in the picker — there is no category to tell them apart. Merging is a human decision in Config |
| Item deleted with open orders | Tombstoned. Lines keep `item_name_snapshot`; reports group by `menu_item_id`, so history stays intact |
| `lead_days` changed after an order exists | Only affects new orders; the rush warning is computed at edit time, and the reminder schedule is rebuilt (the reminder service follows `watchAll`) |
| Menu item created offline | Fine — it is a normal row with an op, and replicates like anything else |

## 6b. What notice needed does

`lead_days` was stored, shown in Config, and read by nothing for several
releases. It now does three things and nothing else:

```dart
int soonestFor(int leadDays) => midnight(today + leadDays);
bool isRush(int deliveryDate, int leadDays) =>
    deliveryDate < soonestFor(leadDays);
```

| | |
|---|---|
| **Seeds the date** | Choosing an item sets an **untouched** delivery date to `soonestFor`. A date already chosen is left alone — it was chosen |
| **Warns** | A date sooner than the notice shows "Rush: this normally needs 2 days notice". Never a refusal: an app saying no to a customer standing in front of somebody is not its place |
| **Starts the work** | The item appears on the six o'clock digest of `delivery date − lead_days`, as "Start one thing today" |

**Zero notice is left out of all three.** "Start the buns today" on the morning
they are due says nothing, and a bakery that has a thing on the shelf can hand
it over now. See [`../reminders/lld.md`](../reminders/lld.md).

## 7. What to test

- Picker excludes deleted, includes inactive-but-visible with a reason.
- Price hints put the customer's own last price first.
- Deleting an item leaves existing order lines readable and reports correct.
