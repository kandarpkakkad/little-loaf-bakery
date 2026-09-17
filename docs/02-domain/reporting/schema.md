# Reporting — schema

**Views only.** Reporting owns no tables and writes nothing, ever.

Common columns: [`01-platform/storage/schema.md`](../../01-platform/storage/schema.md)

## v_order_totals

**The single definition of a total.** The order screen, the invoice and every report read this
view, so they cannot disagree with each other.

```sql
CREATE VIEW v_order_totals AS
SELECT
  o.id                                                              AS order_id,
  COALESCE(li.subtotal, 0)                                          AS subtotal,
  o.discount_amount                                                 AS discount,
  o.delivery_charge                                                 AS delivery,
  COALESCE(li.subtotal,0) - o.discount_amount + o.delivery_charge   AS total,
  COALESCE(pm.paid, 0)                                              AS paid,
  COALESCE(li.subtotal,0) - o.discount_amount + o.delivery_charge
    - COALESCE(pm.paid,0)                                           AS balance_due
FROM orders o
LEFT JOIN (
  SELECT oi.order_id,
         SUM(oi.base_price * oi.qty + COALESCE(ad.addons, 0)) AS subtotal
  FROM order_items oi
  LEFT JOIN (SELECT order_item_id, SUM(price) AS addons
             FROM order_item_addons WHERE deleted_at IS NULL
             GROUP BY order_item_id) ad ON ad.order_item_id = oi.id
  WHERE oi.deleted_at IS NULL
  GROUP BY oi.order_id) li ON li.order_id = o.id
LEFT JOIN (
  SELECT order_id, SUM(amount) AS paid FROM payments
  WHERE deleted_at IS NULL GROUP BY order_id) pm ON pm.order_id = o.id
WHERE o.deleted_at IS NULL;
```

All columns are **paise**. Add-ons are summed for the line and **not multiplied by quantity**.

## v_material_levels

```sql
CREATE VIEW v_material_levels AS
WITH last_count AS (
  SELECT material_id, MAX(at) AS at FROM stock_transactions
  WHERE kind = 'count' AND deleted_at IS NULL GROUP BY material_id)
SELECT
  m.id AS material_id,
  COALESCE((SELECT qty FROM stock_transactions s
            WHERE s.material_id = m.id AND s.kind='count' AND s.at = lc.at), 0)
  + COALESCE((SELECT SUM(CASE s.kind WHEN 'in' THEN s.qty ELSE -s.qty END)
              FROM stock_transactions s
              WHERE s.material_id = m.id AND s.kind <> 'count'
                AND s.at > COALESCE(lc.at, 0) AND s.deleted_at IS NULL), 0) AS level
FROM materials m
LEFT JOIN last_count lc ON lc.material_id = m.id
WHERE m.deleted_at IS NULL;
```

The most recent `count` is the base; everything after it is a delta on top.

## v_material_last_rate

```sql
CREATE VIEW v_material_last_rate AS
SELECT material_id,
       CAST(amount AS REAL) / NULLIF(qty, 0) AS rate       -- paise per unit
FROM stock_transactions s
WHERE kind = 'in' AND amount IS NOT NULL AND deleted_at IS NULL
  AND at = (SELECT MAX(at) FROM stock_transactions x
            WHERE x.material_id = s.material_id AND x.kind='in'
              AND x.amount IS NOT NULL AND x.deleted_at IS NULL);
```

Stock-ins with no amount are excluded, so an honest gap stays a gap rather than becoming a zero.

## v_material_reference

```sql
-- the level immediately AFTER the most recent stock-in — the bar's full mark
CREATE VIEW v_material_reference AS
SELECT s.material_id,
       (SELECT level FROM v_levels_at(s.material_id, s.at)) AS reference
FROM stock_transactions s
WHERE s.kind = 'in' AND s.deleted_at IS NULL
  AND s.at = (SELECT MAX(at) FROM stock_transactions x
              WHERE x.material_id = s.material_id AND x.kind='in' AND x.deleted_at IS NULL);
```

Bar scale is `max(reference, threshold_qty)` — the second branch is the short-restock case,
where the notch lands hard at the right edge (D18).

## Rules that hold across every report

- **Revenue counts `completed` orders only.** Delivered-but-unpaid is outstanding, not revenue.
- **Voided invoices are excluded** from revenue and listed separately.
- **Group by `menu_item_id`, never by name** — renaming an item must not split its history.
- **Price-over-time groups by weight as well**, because a 1 kg and a 2 kg cake are different
  prices for the same item and averaging them says nothing.
- **Material spend counts stock-ins with an amount** only.
