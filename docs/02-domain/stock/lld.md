# Stock — LLD

## 1. Schema

**Source of truth: [`schema.md`](schema.md).** Not repeated here — a schema in two places is a schema that disagrees with itself.

Tables: `materials`, `stock_transactions` — including what `qty` means per kind

## 2. Current level

```sql
-- everything since the most recent count, on top of that count
WITH last_count AS (
  SELECT material_id, MAX(at) AS at FROM stock_transactions
  WHERE kind='count' AND deleted_at IS NULL GROUP BY material_id)
SELECT m.id,
  COALESCE((SELECT qty FROM stock_transactions
            WHERE material_id=m.id AND kind='count' AND at=lc.at), 0)
  + COALESCE((SELECT SUM(CASE kind WHEN 'in' THEN qty ELSE -qty END)
              FROM stock_transactions
              WHERE material_id=m.id AND kind<>'count'
                AND at > COALESCE(lc.at, 0) AND deleted_at IS NULL), 0) AS level
FROM materials m LEFT JOIN last_count lc ON lc.material_id = m.id;
```
A stock count is a **reset point**, which is what makes it a correction rather than another
guess.

## 3. The reference

```sql
-- the level immediately AFTER the most recent stock-in
SELECT level_at(material_id, (SELECT MAX(at) FROM stock_transactions
                              WHERE material_id=? AND kind='in' AND deleted_at IS NULL))
```
Computed once per material for the list and cached in memory for the session — it only
changes when a stock-in happens.

```dart
double barScale(Material m) => max(reference(m), m.thresholdQty);   // §HLD, the two cases
double fillFraction(Material m) => (level(m) / barScale(m)).clamp(0, 1);
double notchFraction(Material m) => m.thresholdQty / barScale(m);

BarState state(Material m) =>
    level(m) < m.thresholdQty                 ? BarState.bad
  : level(m) < m.thresholdQty * 1.15          ? BarState.warn
  :                                             BarState.good;
```
**No reference yet** (never stocked in): `reference = 0`, so `barScale = threshold` and the bar
reads against the threshold alone. Correct — there is nothing else to measure against.

## 4. Add stock

```dart
Future<void> addStock(Material m, double qty, {Money? amount}) {
  require(qty > 0, 'quantity must be positive');
  return mutate('stock_txn', id, (b) => b.insert(stockTransactions,
      materialId: m.id, kind: 'in', qty: qty, amount: amount?.paise, at: now));
}

Money? lastRate(Material m) {           // paise per unit
  final t = lastStockInWithAmount(m);
  return t == null ? null : Money((t.amount / t.qty).round());
}
// "Use last price" checkbox — unchecked by default:
Money suggested(Material m, double qty) => Money((lastRate(m)!.paise * qty).round());
// Shows its working: "₹520/kg × 5 kg = ₹2,600"
```

**Amount is optional.** Skipping it adds the stock and contributes nothing to last-paid or
valuation. Better an honest gap than a guessed number.

**Threshold check — warn, never block:**
```dart
final after = level(m) + qty;
if (after < m.thresholdQty)
  warn('After this: ${fmt(after)} ${m.unit}, still below your ${fmt(m.threshold)} threshold');
```

## 5. Alerts

```dart
// evaluated after every movement and on app resume
final below = materials.where((m) => level(m) < m.thresholdQty);
for (final m in below) {
  if (ackedAfter(m, lastCrossedBelowAt(m))) continue;   // already dismissed
  notify(m);
}
// Acknowledge writes an op, so dismissing on one device clears it on every device.
```
Without the op, every device nags about the same butter and the alerts get ignored inside a week.

## 6. Purchase list

```sql
SELECT name, unit, level, threshold_qty, threshold_qty - level AS shortfall
FROM v_material_levels WHERE level < threshold_qty AND active = 1
ORDER BY (level / NULLIF(threshold_qty,0)) ASC;     -- most depleted first
```
Rendered as shareable text. Grouped by nothing — there is no supplier (D19).

## 7. Edge cases

| Case | Handling |
|---|---|
| Consumption exceeds level | Negative level, shown as such. It means a stock-in was missed |
| Count entered for the wrong material | Tombstone it; the previous count becomes the reset point again |
| Two devices count the same material | Both rows exist; the later `at` wins as the reset point |
| Threshold changed | Bar rescales immediately; no movement is rewritten |
| Unit changed after movements exist | **Rejected.** Changing kg to g would silently rewrite every historical quantity |
| Material deleted with movements | Tombstoned; history queryable; excluded from the list and alerts |
| Stock-in with amount but qty later corrected | Rate recomputes from the surviving rows |

## 8. What to test

- Level after: in, in, consume, count, consume — the count must reset the base.
- `barScale` in both branches, including a material never stocked in.
- Add-stock threshold warning fires and does **not** block.
- Alert acknowledgement on one device clears it on the other after sync.
- Unit change is rejected once movements exist.
- Purchase list orders by proportion depleted, not absolute shortfall.
