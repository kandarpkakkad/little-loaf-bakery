# Orders — HLD

## Purpose
The centre of the product. An order is created once and carries everything downstream: the
production sheet, the delivery run and every message come out of it.

## Responsibilities
- The lifecycle and its transitions.
- Lines: menu item, flavour, weight, quantity, base price, add-ons.
- Order-level money: discount, delivery charge, advance.
- Delivery date, time, address and pin.
- Special requirements, and the flag when they change after confirming.
- Totals, derived — never stored.

## Owns
`orders`, `order_items`, `order_item_addons`, `order_status_events`, `attachments`.

## Depends on
menu (items), customers (who), storage, sync. **Invoicing, payments and messaging depend on
orders, not the other way round** — orders raises domain events; it does not call them.

## Lifecycle
```
Created → Confirmed → In production → Ready → Out for delivery → Delivered → Completed
   │           │             │                                        │
   └───────────┴─────────────┴──────────► Cancelled ◄─────────────────┘
```

**Every transition is manual** (D15). The app offers the next step — a Delivered tap opens the
payment sheet, Confirmed opens WhatsApp — but the order never moves itself. Not on a payment,
not on a share, not on the delivery date.

**Delivered and Completed are separate facts** (D14). A cake handed over on Saturday and paid
for on Monday sits at Delivered all weekend, which is exactly where the outstanding report
should find it.

## Key decisions
- **A line is scheduled, not the order** (D25, D26, D27). Each line carries its own
  delivery date, time, type, address and status. The order's status is derived from
  them; its due date is the **last** outstanding line and is never edited; lists sort
  by the **earliest** outstanding line. Money stays on the order.
- **Items come from the menu** (D16). `menu_item_id` is not null and the picker
  creates a real menu entry rather than a one-off string.
- **The line stores a copy of the item name**, so renaming a menu item never rewrites history.
- **Prices are typed**, with the last three shown as hints (D17). There is no price on a menu
  item to inherit.
- **Advance is optional** (D9). Confirming with nothing collected is normal.
- **Zero never shows** (D10) — one rule, applied to discount, delivery and advance alike.
- **The address belongs to the order** (D20), starts empty, with *Same as last order*.
- **Delivery charge stays editable until Delivered**, including from the delivery run —
  so the timing guard below applies to the date and time only, not to every field that
  moves with a journey.
- **An order is settled before it closes, either way.** Completing already required
  nothing owed and nothing owed back; cancelling now requires that no money has been taken.
  The credit a cancellation would leave has nothing able to clear it — refunds do not exist
  and a payment is removed rather than reversed — so the cash goes back, the payment comes
  off, and only then is the order called off. An unpaid order cancels freely, which is the
  ordinary case.

  **Cancelling a single line is not covered by this** and can still leave credit, which is
  the honest record of an item that was paid for and could not be made. Worth revisiting
  when refunds exist.
- **A closed order takes no more items.** `completedAt` short-circuits the derivation, so
  an item added to a completed order left it reading Completed while holding unbaked work
  and an unpaid balance: on the kitchen board, absent from open orders, and with money that
  could never surface as payment pending. Anything more is a new order.
- **How far along an item is decides how far its handover may move**
  (`scheduleRefusal`). Nothing started: any date and time, it is still a
  conversation. In production or ready: **later only, and by at most six
  hours** — a cake cannot be handed over sooner than it exists, and a bigger
  move is a different promise that wants a conversation rather than an edit.
  Out with a courier, collected or delivered: nothing, because the schedule
  now describes something that already happened.

  Measured between the schedule as it stands and the one being asked for, at
  the moment of the edit. Two edits can therefore push it further than six
  hours in total; that is accepted deliberately, as the alternative is a
  column to freeze the original promise in.

  **The journey is consulted as well as the item.** An item riding in a van is
  still `ready` on its own row, so the line status alone would let somebody
  re-time a delivery already on the road.

## Failure modes
| Case | Behaviour |
|---|---|
| Two devices edit different fields | Both survive — field-level LWW |
| Two devices move status differently | LWW; a backwards move is written to the conflict log |
| Requirements edited after Confirmed | Board card flagged ⚑ until the kitchen acknowledges |
| Delivery date inside the lead time | **Rush warning, non-blocking** |
| Menu item deleted after being ordered | The line keeps its name snapshot and stays readable |
| Customer deleted | Orders tombstone with them |

## Non-goals
No quotes or drafts distinct from Created. No recurring orders. No partial fulfilment — an
order is delivered whole or not at all.
