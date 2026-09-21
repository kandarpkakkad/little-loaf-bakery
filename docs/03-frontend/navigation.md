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
│   Orders   Kitchen   Stock   More    │
└──────────────────────────────────────┘
```

| Tab | Holds | Start destination |
|---|---|---|
| **Orders** | Every order, **grouped by the day it is next needed**, plus search and the alerts worth acting on | `/orders` |
| **Kitchen** | Segmented: Board · Sheet · Deliveries. **This is the day's view** — what is due now and what is in the oven | `/kitchen/board` |
| **Stock** | Levels, add stock, consumption, wastage, count, purchase list | `/stock` |
| **More** | Customers, reports, share log, sync & backup, **Config** | `/more` |

- **The FAB is New order, on Orders and Kitchen only.** Those are the two places where taking
  an order is the next thing someone might do. On Stock it sat over a shelf count, and on More
  over a settings list, offering an action nobody standing there had in mind.
- **Tabs are places, not pages** — cross-fade, no slide, and each keeps its own back stack.
- **The sync strip appears only when it has something to say**: syncing, offline with N
  pending, or last synced over 24 hours ago. It never occupies space silently.

## Routes

```
/orders                       ?status= &unpaid= &unshared= &q=
/orders/new                   ?customer=
/orders/:id
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

Modal bottom sheets on a phone, **centred dialogs capped at 560 on anything wider** — one
helper, `loafSheet`, decides. A bottom sheet is a phone shape: it comes up from the thumb and
spans the width because the width is small. On a tablet the same call produced a slab across
1,200 logical pixels with a form column stranded in the middle of it.

They do not push a route, and they do not survive process death — a half-entered payment is
not worth restoring.

**Drop focus before opening one.** A button tapped while a text field has focus leaves that
focus where it was, and Flutter hands it straight back when the route pops — so choosing a
delivery date threw the person back into whatever they had typed last, keyboard and all.
`dismissKeyboard(context)` is the fix and lives beside the fields it is about.

| Sheet | From |
|---|---|
| Record payment | Order detail · delivery run |
| Add stock | A material's row |
| Open location in… | Order detail · delivery run |
| Item picker | New/edit order |
| + New menu item | Inside the item picker |
| Discount | Set on the item, in the item editor (D31) |

## On a tablet

Not the same layout stretched. Each screen takes the shape its content wants, and where the
answer is "nothing", that is a decision rather than an omission.

| Screen | Wide |
|---|---|
| **Orders** | Status board in columns **ascending**, or the date list. A phone opens on the date list — one column of anything, and what a phone is holding is *what is due next* |
| **Kitchen** | Four stages side by side. The phone stacks them **reversed**, because a scroll is read top-down under time pressure and what is nearest the door belongs first |
| **New order** | Customer and money left, items right — a ten-line order never pushes the total out of view |
| **Reports** | The month left, the standing summaries right |
| **Order detail** | Journeys left, money right — **except embedded** in the Orders two-pane, where it is already half a tablet |
| **Customers** | A list beside `CustomerDetail`, which shows their orders |
| **Menu · Materials · Stock** | A card each, in columns. A divider separates rows in one column and means nothing across two |
| **Forms, More** | A capped column. A form across 1,200 pixels is not more usable, only further for the eye to travel |

The board order differs between Orders and Kitchen on purpose: a **row** is read left to
right, where the pipeline order is the natural one, and a **scroll** is read top-down.

## Screens outside the shell

| | Why |
|---|---|
| `/setup` | Runs once. There is nothing to navigate to yet |
| `/blocked` | **No way past it.** No tabs, no back — the outbox is flushed before it appears |

## Back behaviour

- Back inside a tab pops that tab's stack.
- Back at a tab root goes to **Orders**, not out of the app.
- Back at Orders' root exits, after a confirm-on-double-back.
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

- **The order is the hub.** Payment, location, share and customer are all reached
  from it; none of them is a destination in its own right.
- **Config is never linked to from a working screen** — no "edit this menu item" shortcut from
  the order form. There is no exception: an item that is not on the menu is added in
  immediately with the item selected rather than navigating away (D16).
- **Kitchen screens never link to money.** No path from a board card to a total.
