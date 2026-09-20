# Reporting — LLD

## 1. Views

**Source of truth: the code** — `lib/domain/reporting/repository.dart`, over `OrderTotals`.
[`schema.md`](schema.md) states the shape of each answer as SQL; the views it describes were
not built, and where the two disagree the code is right.

`OrderTotals` is the single definition of a total — the order screen and every report read it, so they cannot disagree.

## 2. Sales

```sql
-- by period; revenue = completed only
SELECT strftime('%Y-%m', o.delivery_date/1000, 'unixepoch') AS month,
       COUNT(*) AS orders, SUM(t.total) AS revenue
FROM orders o JOIN <order totals> t ON t.order_id=o.id
WHERE o.status='completed' AND o.deleted_at IS NULL
GROUP BY month ORDER BY month DESC;

-- by product
SELECT oi.menu_item_id, MAX(oi.item_name_snapshot) AS name,
       SUM(oi.qty) AS qty, SUM(oi.base_price*oi.qty) AS revenue
FROM order_items oi JOIN orders o ON o.id=oi.order_id
WHERE o.status='completed' AND o.delivery_date BETWEEN :a AND :b
  AND oi.deleted_at IS NULL AND o.deleted_at IS NULL
GROUP BY oi.menu_item_id ORDER BY revenue DESC;
```
Grouped by `menu_item_id`, not by name — so renaming an item does not split its history (D16).

## 3. Price charged over time

```sql
SELECT oi.menu_item_id, MAX(oi.item_name_snapshot) name,
       strftime('%Y-%m', o.created_at/1000,'unixepoch') month,
       MIN(oi.base_price) lo, MAX(oi.base_price) hi,
       AVG(oi.base_price) avg, COUNT(*) n
FROM order_items oi JOIN orders o ON o.id=oi.order_id
WHERE oi.deleted_at IS NULL AND o.deleted_at IS NULL
GROUP BY oi.menu_item_id, oi.weight_value, oi.weight_unit, month
ORDER BY name, month;
```
Grouped by **weight as well**, because a 1 kg and a 2 kg cake are different prices for the
same item and averaging them together would say nothing. Weight is a number and a
unit (`weight_value`, `weight_unit`), not a typed string, so both columns are in
the grouping — "1 kg" and "1000 g" would otherwise be two different groups.

## 4. Stock reports

```sql
-- spend by period
SELECT strftime('%Y-%m', at/1000,'unixepoch') month, SUM(amount) spend
FROM stock_transactions WHERE kind='in' AND amount IS NOT NULL AND deleted_at IS NULL
GROUP BY month;

-- wastage by material and reason
SELECT m.name, s.reason, SUM(s.qty) qty
FROM stock_transactions s JOIN materials m ON m.id=s.material_id
WHERE s.kind='waste' AND s.deleted_at IS NULL AND s.at BETWEEN :a AND :b
GROUP BY m.id, s.reason ORDER BY qty DESC;

-- valuation: level × last price paid
SELECT m.name, v.level, r.rate, v.level * r.rate AS value
FROM v_material_levels v JOIN materials m ON m.id=v.material_id
LEFT JOIN v_material_last_rate r ON r.material_id=m.id
WHERE m.active=1;
```
Spend counts only stock-ins **where an amount was recorded** — the optional amount (D19)
means an honest gap rather than a guess.

## 5. Material spend against revenue

The v2-recipes substitute (PRD §10):

```sql
SELECT :period, (SELECT SUM(total) FROM …completed orders in period…) AS revenue,
                (SELECT SUM(amount) FROM …stock-ins in period…)        AS material_spend;
```
Period-level only. It is deliberately **not** presented as a margin — without recipes,
consumption is not linked to orders, and calling it margin would be a lie.

## 6. CSV export

```dart
const exports = ['orders','order_items','payments','materials',
                 'stock_transactions','customers'];
// One file per table, UTF-8 with BOM (Excel), ISO-8601 dates, money as rupees with 2dp.
// Zipped, shared through the Android share sheet.
```
Money is exported as **rupees with two decimals**, not paise — the accountant is not reading
integers. Everywhere else it stays paise.

## 7. Edge cases

| Case | Handling |
|---|---|
| Order completed in one month, delivered in another | Grouped by `delivery_date` — the work is when it happened |
| Cancelled before delivery | Never counted as trade |
| Deleted customer | "Deleted customer" in the row; totals unaffected |
| Stock-in with no amount | Counted in quantity, excluded from spend |
| Negative stock level | Shown; valuation clamps at zero rather than going negative |
| Date range crossing a financial year | Allowed; nothing here is FY-aware |

## 8. What to test

- Reporting agrees with the order screen, because both read `OrderTotals`. There is nothing to
  cross-check, which was the point of not writing it twice.
- Revenue excludes non-completed and voided.
- Price-over-time separates weights of the same item.
- CSV round-trip: export, re-import into a scratch DB, assert equality.
- A 3-year range over 30,000 orders returns in under a second on a mid-range phone.

## Which month a sale belongs to

**One rule, used by every figure on the screen: `_soldOn`** — when the last
item actually went, falling back to the order's own date for anything still
outstanding.

The monthly chart and the top-items list already used it; the month's order
list filtered and sorted on `orders.delivery_date` instead. That column is a
cache of the *promised* date (and, once nothing is outstanding, of the last
journey's), so "September" meant two different sets of orders depending on
which half of the screen you read.

A split order still counts once, in the month its **last** journey lands. That
is a deliberate simplification: an order is the unit being counted, and
splitting its value across months would make the order count and the value
disagree about what they are counting.
