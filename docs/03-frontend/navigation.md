# Navigation

## Shell

One shell, five tabs, identical on every device. **No roles, so no variants** (D1).

```
┌──────────────────────────────────────┐
│ app bar          brand background    │
│ sync strip       only when needed    │
├──────────────────────────────────────┤
│                                      │
│  tab content                         │
│                                      │
│                          ( + )  FAB  │
├──────────────────────────────────────┤
│ Today  Orders  Kitchen  Stock  More  │
└──────────────────────────────────────┘
```

| Tab | Holds | Start destination |
|---|---|---|
| **Today** | The day's deliveries, in production, money to collect, alerts | `/today` |
| **Orders** | List, search, order detail, invoice preview | `/orders` |
| **Kitchen** | Segmented: Board · Sheet · Deliveries | `/kitchen/board` |
| **Stock** | Levels, add stock, consumption, wastage, count, purchase list | `/stock` |
| **More** | Customers, reports, share log, sync & backup, **Config** | `/more` |

- **The FAB is New order, on every tab.** The most common action is never more than one tap away.
- **Tabs are places, not pages** — cross-fade, no slide, and each keeps its own back stack.
- **The sync strip appears only when it has something to say**: syncing, offline with N
  pending, or last synced over 24 hours ago. It never occupies space silently.

## Routes

```
/today
/orders                       ?status= &unpaid= &unshared= &q=
/orders/new                   ?customer=
/orders/:id
/orders/:id/invoice
/kitchen/board                ?from= &to=
/kitchen/sheet                ?day=
/kitchen/deliveries           ?day=
/stock
/stock/:materialId            movement history
/more
/more/customers               /more/customers/:id
/more/reports                 /more/reports/:key
/more/share-log
/more/sync                    /more/sync/restore
/more/config
/more/config/menu             /more/config/menu/:id
/more/config/materials        /more/config/materials/:id
/more/config/business
/more/config/payment
/more/config/device
/setup                        first run, outside the shell
/blocked                      version gate, outside the shell
```

## Sheets, not routes

Modal bottom sheets. They do not push a route, and they do not survive process death — a
half-entered payment is not worth restoring.

| Sheet | From |
|---|---|
| Record payment | Order detail · delivery run |
| Add stock | A material's row |
| Open location in… | Order detail · delivery run |
| Item picker | New/edit order |
| + New menu item | Inside the item picker |
| Discount | Order totals |

## Screens outside the shell

| | Why |
|---|---|
| `/setup` | Runs once. There is nothing to navigate to yet |
| `/blocked` | **No way past it.** No tabs, no back — the outbox is flushed before it appears |

## Back behaviour

- Back inside a tab pops that tab's stack.
- Back at a tab root goes to **Today**, not out of the app.
- Back at Today's root exits, after a confirm-on-double-back.
- **A sheet's back dismisses it and loses the draft.** Nothing half-entered is auto-saved,
  because a silently resurrected payment is worse than a lost one.

## Deep links

`littleloaf://order/:id` — used by local notifications only. Nothing external links into the
app, because nothing external knows it exists.

| Notification | Opens |
|---|---|
| Below threshold | `/stock` |
| Snapshot stale (3 days) | `/more/sync` |
| Update available | `/more/sync` |

## Cross-navigation rules

- **The order is the hub.** Payment, invoice, location, share and customer are all reached
  from it; none of them is a destination in its own right.
- **Config is never linked to from a working screen** — no "edit this menu item" shortcut from
  the order form. The one exception is **+ New item** inside the picker, which returns
  immediately with the item selected rather than navigating away (D16).
- **Kitchen screens never link to money.** No path from a board card to an invoice.
