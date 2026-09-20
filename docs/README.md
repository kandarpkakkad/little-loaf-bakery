# Little Loaf Bakery — design documentation

The [PRD](PRD.md) says **what** the product is. Everything here says **how** it is built.

```
docs/
  PRD.md                     the product definition — read this first
  00-overview/               whole-system view
    hld.md                   architecture, module map, cross-cutting rules
    decisions.md             every decision made, and what it cost
    glossary.md              terms used precisely throughout
  01-platform/               technical systems, no business meaning
    storage/                 common columns, settings, migrations
    sync/                    journals, ops, HLC, merge, compaction
    backup/                  snapshots, ownership, restore
    versioning/              the version gate, distribution
    security/                Drive auth, encryption, app lock, privacy
  02-domain/                 business systems
    orders/  menu/  customers/  payments/
    stock/   messaging/  fulfilment/  reporting/
  03-frontend/
    design-system.md         tokens, type, components — the visual language
    screen-dsl.md            a declarative notation, and all 29 screens in it
    navigation.md            shell, tabs, routes, deep links
```

## The code is the source of truth

These documents **describe** what is built; they do not define it. Where a
document and the code disagree, the code is right and the document is stale —
fix the document. The schema in particular lives in
`lib/platform/storage/tables.dart`; the `schema.md` files describe it.

Some of what follows is design for work that has not been done. Anything
unbuilt is marked **Not built** where it is described, and summarised here:

| Area | State |
|---|---|
| storage, sync, security (encryption) | built |
| orders, menu, customers, stock, payments, messaging, fulfilment | built |
| orders — per-line schedule and status, derived order status and due date (D25–D27) | built, including the v9→v10 migration |
| messaging — a receipt after every payment, partial included | built |
| messaging — per-drop "out for delivery" / "delivered", clubbed by day, time and destination | built |
| orders — advancing an item from order detail and the Kitchen board | built — baking per item, handover per drop |
| orders — editing and adding items on a live order | built, with what an item *is* locked once a baker starts |
| backup, restore, journal compaction | built — nightly snapshot at 00:02 IST, one owner device, 14 kept. Restore is staged and applied at the next launch |
| security — app lock | built — off by default, device PIN or biometric, asked on cold start and after five minutes away |
| versioning — the update gate | built — GitHub Releases for what exists, peers' `device.json` for the floor; unreadable never blocks |
| orders grouped by the day they are next needed; Today removed | built — Kitchen is the day's view; the alerts moved to Orders |
| kitchen board starts at **confirmed** | built — confirming an order is what hands its items to the kitchen |
| orders hold **sub-orders** hold items (D28, D29) | built — schema v12; the kitchen works to journeys, and each is delivered once |
| reminders — 2h/30m before, 1h after, 6am for untimed; a warning on a late journey | built — local notifications, no push server. **Delivery itself is unverified off-device** |
| reporting | built — sales by month and product, money owed, stock value. Computed over `OrderTotals`, not a SQL view |
| Kitchen reading journey dates | built — the board is a board of journeys, each delivered once |
| invoicing, in any form | **removed** in schema v13 — the bakery does not raise bills (D30). GST goes with it |

## What each document type contains

| | |
|---|---|
| **HLD** | Purpose · responsibilities · what it owns · what it depends on · key decisions · failure modes · explicit non-goals |
| **schema** | Tables, views and stored file shapes as they exist in code: DDL, constraints, indexes, and what is deliberately *not* stored. Never duplicated in an HLD or LLD |
| **LLD** | Algorithms in pseudocode · function contracts · state transitions · validation rules · edge cases · what to test. **References `schema.md`; never restates it** |
| **DSL** | Design tokens · primitives · components · composition rules · every screen expressed declaratively |

## Before you change anything

[`../AGENTS.md`](../AGENTS.md) — how work is done here, and why the documents
come first.

## Reading order

1. [PRD](PRD.md) — the product
2. [Overview HLD](00-overview/hld.md) — how it hangs together
3. [Decisions](00-overview/decisions.md) — why it hangs together that way
4. Then whichever system you are about to build. Platform before domain: **storage → sync → backup** underpin everything else.

## Rules that hold everywhere

These are repeated in the modules they affect, but they are true globally.

- **Local first.** Every write commits to SQLite before anything else happens. No UI waits on a network call.
- **UUID v7 primary keys.** Time-ordered, so id order is creation order. Human-facing numbers are separate attributes.
- **Money is integer paise.** Never a float, never a double, at any layer.
- **Append-only where it matters.** Payments, stock movements and status events are inserts, never updates.
- **Soft deletes only.** Tombstones, so a delete can replicate.
- **Every row carries `device_id` and `updated_at_hlc`.**
- **Schema lives in `schema.md`, and nowhere else.** A schema written in two places is a
  schema that disagrees with itself.
- **Zero never shows.** A ₹0 row is absent from every rendering, not printed as zero.
- **The app never advances an order by itself.** It offers; a person moves it.
