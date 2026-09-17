# Stock — HLD

## Purpose
Stock in, stock out, and a warning before something runs out. Nothing more.

## Responsibilities
- The raw materials list — the stock side of the menu.
- Movements: stock-in, consumption, wastage, count.
- Current level, the reference, and the threshold.
- Below-threshold alerts and the purchase list.

## Owns
`materials`, `stock_transactions`.

## Depends on
storage, sync, config (where the list is maintained).

## Key decisions
- **A material is four fields** (D19): name, category, unit, threshold. No price, no supplier,
  no shelf life, no batch tracking, no storage location — each was either already known or
  would go stale, and a stale field is worse than an absent one.
- **Current stock is never stored.** It is summed from movements, so two devices cannot
  disagree about it.
- **Price comes from history**, never the record (D17). Last paid is derived from stock-ins.
- **No purchase document.** No supplier, no bill number, no photo. Stock arrives and is
  entered against the material it is, from a sheet on its own row.
- **The bar has no configured maximum** (D18). It fills to the *reference* — the level right
  after stock was last added. The **threshold** is the notch.
- **Maintained in Config** (D22).

## The bar, precisely
| Case | Scale | Reads as |
|---|---|---|
| reference ≥ threshold (normal) | reference | how much of what I last bought is left |
| last restock fell short | **threshold** | notch hard at the right edge — *that restock didn't get you there* |

Colour carries urgency, but **position is the real signal** — whether the fill reaches the
notch survives being colour-blind, in sunlight, or photocopied.

## Failure modes
| Case | Behaviour |
|---|---|
| Restock below threshold | **Warned, not blocked** — sometimes 2 kg is all there was |
| Both devices alert on the same material | Acknowledging writes an op, so dismissing on one clears the other |
| Negative stock (consumption beyond what was recorded) | Allowed and shown. It means a stock-in was missed, and hiding it would hide the problem |
| Material deleted with movements | Tombstoned; history stays queryable |

## Non-goals
No recipes, no BOM, no per-order ingredient cost (v2). No batch or expiry tracking. No
supplier management. No stock valuation beyond last-paid × quantity.
