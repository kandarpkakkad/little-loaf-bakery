# Reporting — HLD


Built — `lib/domain/reporting/repository.dart` and **More › Reports**, ten
tests.

**Deviation from the design below, deliberately.** It called for a
`v_order_totals` view as "the single definition of a total". The app already
has one — `OrderTotals` in Dart — and every screen reads it. A SQL copy would
be a *second* definition, and the two would drift the first time a rule changed:
cancelled items leaving the total, credit, a discount resolved at invoice. So
the reports compute in Dart over the same object the screens use. At a bakery's
volumes that costs nothing; two definitions would cost a report that disagrees
with the order screen.

## Purpose
Answer the handful of questions the owner actually asks, and export everything for the
accountant.

## The reports
| Report | Answers |
|---|---|
| Sales by period / product / category | What sold |
| **Price charged per item over time** | Low, high, average, trend — *what we actually charge*, which matters because nothing is fixed (D17) |
| Order volume by day of week and source | When and where orders come from |
| Top customers | By value and by frequency |
| Advance vs balance collection | Whether money arrives up front or late |
| Outstanding | Delivered with money owed, oldest first |
| Material spend by period | What stock costs |
| Wastage by material and reason | Where money leaks |
| Stock valuation | Level × last price paid |

## Owns
Nothing. Read-only views over other modules' tables.

## Depends on
orders, payments, invoicing, stock, customers.

## Key decisions
- **Read-only.** No report writes anything, ever.
- **Computed live** from the same derived functions the UI uses — a report can never disagree
  with the screen it came from.
- **Revenue counts Completed orders only.** Delivered-but-unpaid is outstanding, not revenue.
- **Voided invoices are excluded from revenue and listed separately**, so a gap in the series
  is explained rather than mysterious.
- **CSV export** for everything, shared from the phone. There is no accountant login (D1).
- **Price-over-time is the report this architecture makes possible.** With prices in history
  rather than on records, it is the only way to see whether pricing is drifting.

## Failure modes
| Case | Behaviour |
|---|---|
| Report run while a device is unsynced | Shows this device's view, with the sync banner visible. Never silently stale |
| Large date range | Queries are indexed on `delivery_date`; a 3-year range is still sub-second at 30k orders |
| Deleted customer in a historical report | Appears as "Deleted customer" — the money stays, the identity does not |

## Non-goals
No dashboards beyond Today. No charts in v1 — numbers and CSV. No forecasting, no
recommendations.
