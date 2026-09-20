# Stock — LLD

## 1. Schema

**Source of truth: [`schema.md`](schema.md).** Not repeated here — a schema in two places is a schema that disagrees with itself.

Tables: `materials`, `stock_transactions` — including what `qty` means per kind

## 2. Current level

`levelOf` in `domain/stock/model.dart` — Dart, not SQL. The whole movement list for a material
is already in memory for the bar and the history, so a second definition in SQL would be a
second thing to keep right.

```dart
// everything since the most recent count, on top of that count
sorted     = movements sorted by (at, id)
lastCount  = the LAST INDEX where kind == count          // position, not timestamp
level      = lastCount < 0 ? 0 : sorted[lastCount].qty
for m in sorted after lastCount:
    level += m.kind == stockIn ? m.qty : -m.qty
```

A stock count is a **reset point**, which is what makes it a correction rather than another
guess.

**Two movements can share a millisecond**, and counting the shelf then recording the delivery
that just arrived does exactly that. So two things matter:

- **The tie is broken by `id`**, which is UUID v7 and therefore ordered by the moment the row
  was made — *including within one millisecond*, which took a second fix to be true. The
  generator now carries a counter in the 12 bits after the version nibble (RFC 9562 method 1);
  before that everything after the timestamp was random, so same-millisecond ids sorted by a
  coin flip and this answer changed run to run.
- **The last count is found by position, not by comparing `at`.** An earlier version asked
  "is this movement later than the count?" and a same-millisecond purchase answered no, so it
  was dropped: three kilos counted plus two bought read as three. CI caught it; the local
  suite never did, because the two writes happened to land in different milliseconds here.

## 3. The reference

The level immediately **after** the most recent stock-in — the bar's full mark.

```dart
lastIn = the LAST INDEX where kind == stockIn
return levelOf(sorted.sublist(0, lastIn + 1));      // sliced by position
```

Sliced by position for the same reason as above: a count sharing the stock-in's millisecond
must not be dragged in or left out by luck.

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
