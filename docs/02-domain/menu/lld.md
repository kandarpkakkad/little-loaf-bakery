# Menu — LLD

## 1. Schema

**Source of truth: [`schema.md`](schema.md).** Not repeated here — a schema in two places is a schema that disagrees with itself.

Tables: `menu_items`

**No price column. No flavour column.** Both are decided per order (D17).

## 2. Availability

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
Grouped by category, whole list on screen — no search-first.
Unavailable items are shown greyed with the reason ("Out of season until Nov"),
not hidden: knowing it exists and is unavailable beats wondering where it went.
Last row: [ + New item ]
```

**+ New item** opens a minimal form — name and category only, the rest defaulted — creates the
row, and returns it selected. Lead time and photo can be filled in later from Config.

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
| Two items with the same name | Allowed. The picker shows category to disambiguate; merging is a human decision |
| Item deleted with open orders | Tombstoned. Lines keep `item_name_snapshot`; reports group by `menu_item_id`, so history stays intact |
| Season crossing new year | Handled by the wrap branch in §2 |
| `lead_days` changed after an order exists | Only affects new orders; the rush warning is computed at edit time |
| + New item created offline | Fine — it is a normal row with an op, and replicates like anything else |

## 7. What to test

- Season wrap: Nov→Jan availability on 15 Dec and on 15 Jun.
- Picker excludes deleted, includes inactive-but-visible with a reason.
- `+ New item` returns the created item selected, and the row carries an op.
- Price hints put the customer's own last price first.
- Deleting an item leaves existing order lines readable and reports correct.
