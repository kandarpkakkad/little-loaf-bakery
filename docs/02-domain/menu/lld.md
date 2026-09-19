# Menu — LLD

## 1. Schema

**Source of truth: [`schema.md`](schema.md).** Not repeated here — a schema in two places is a schema that disagrees with itself.

Tables: `menu_items`

**No price column. No flavour column.** Both are decided per order (D17).

## 2. Availability

Built — `lib/domain/menu/availability.dart`, eight tests.

Two gates that mean different things: `active` is a switch somebody flips
("we have stopped making this"), a season is a fact about the year that needs
no attention once set. A season is picked by **month** in Config; "from" takes
the first of the month and "to" the last, so Nov–Jan runs to the 31st.

```dart
bool availableOn(MenuItem m, Date d) {
  if (!m.active || m.deletedAt != null) return false;
  if (m.seasonFrom == null) return true;
  final md = d.monthDay;                       // MMDD
  return m.seasonFrom <= m.seasonTo
      ? md >= m.seasonFrom && md <= m.seasonTo         // Mar–Aug
      : md >= m.seasonFrom || md <= m.seasonTo;        // Nov–Jan, wrapping the year
}
```
The wrapping case is the one that matters — plum cake runs November to January.

## 3. The picker

```
A flat list, whole thing on screen — no search-first, and no grouping: the
item *is* the category ("Cake", "Croissant", "Focaccia"), so there is no second
level to group by.
Inactive items are excluded — the picker asks for `list(activeOnly: true)`.
An item that is merely **out of season is still shown**, with its season beside
it: a customer can order a Christmas cake in June if they want one in December,
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
| Season crossing new year | Handled by the wrap branch in §2 |
| `lead_days` changed after an order exists | Only affects new orders; the rush warning is computed at edit time |
| Menu item created offline | Fine — it is a normal row with an op, and replicates like anything else |

## 7. What to test

- Picker excludes deleted, includes inactive-but-visible with a reason.
- Price hints put the customer's own last price first.
- Deleting an item leaves existing order lines readable and reports correct.
