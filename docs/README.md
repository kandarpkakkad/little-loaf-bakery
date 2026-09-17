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
    versioning/              app.json, the version gate, distribution
    security/                Drive auth, encryption, app lock, privacy
  02-domain/                 business systems
    orders/  menu/  customers/  invoicing/  payments/
    stock/   messaging/  fulfilment/  reporting/
  03-frontend/
    design-system.md         tokens, type, components — the visual language
    screen-dsl.md            a declarative notation, and all 29 screens in it
    navigation.md            shell, tabs, routes, deep links
```

## What each document type contains

| | |
|---|---|
| **HLD** | Purpose · responsibilities · what it owns · what it depends on · key decisions · failure modes · explicit non-goals |
| **schema** | **The source of truth for tables, views and stored file shapes.** DDL, constraints, indexes, and what is deliberately *not* stored. Never duplicated in an HLD or LLD |
| **LLD** | Algorithms in pseudocode · function contracts · state transitions · validation rules · edge cases · what to test. **References `schema.md`; never restates it** |
| **DSL** | Design tokens · primitives · components · composition rules · every screen expressed declaratively |

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
