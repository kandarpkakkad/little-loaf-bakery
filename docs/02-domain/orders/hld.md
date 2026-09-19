# Orders — HLD

## Purpose
The centre of the product. An order is created once and carries everything downstream: the
production sheet, the delivery run, the invoice and all three messages come out of it.

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
- **A line is scheduled, not the order** (D25, D26, D27) — **not built**. Each line
  carries its own delivery date, time, type, address and status; the order's status and
  due date are derived from its lines; money stays on the order.
- **Items come from the menu** (D16). `menu_item_id` is not null and the picker
  creates a real menu entry rather than a one-off string.
- **The line stores a copy of the item name**, so renaming a menu item never rewrites history.
- **Prices are typed**, with the last three shown as hints (D17). There is no price on a menu
  item to inherit.
- **Advance is optional** (D9). Confirming with nothing collected is normal.
- **Zero never shows** (D10) — one rule, applied to discount, delivery and advance alike.
- **The address belongs to the order** (D20), starts empty, with *Same as last order*.
- **Delivery charge stays editable until Delivered**, including from the delivery run.

## Failure modes
| Case | Behaviour |
|---|---|
| Two devices edit different fields | Both survive — field-level LWW |
| Two devices move status differently | LWW; a backwards move is written to the conflict log |
| Requirements edited after Confirmed | Board card flagged ⚑ until the kitchen acknowledges |
| Delivery date inside the lead time | **Rush warning, non-blocking** |
| Menu item deleted after being ordered | The line keeps its name snapshot and stays readable |
| Customer deleted | Orders tombstone with them; invoices survive with the name scrubbed |

## Non-goals
No quotes or drafts distinct from Created. No recurring orders. No partial fulfilment — an
order is delivered whole or not at all.
