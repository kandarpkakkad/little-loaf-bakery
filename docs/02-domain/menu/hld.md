# Menu — HLD

## Purpose
The fixed list of what the bakery makes. Every order line comes from it, so the same thing is
always called the same thing.

## Responsibilities
- The menu items and their attributes.
- The active flag, and the **notice** an item needs before it can be promised.
- The picker used on the order form, including inline creation.
- Flavour suggestions drawn from order history.

## Owns
`menu_items`.

## Depends on
storage, sync. Orders depends on menu; menu depends on nothing in the domain.

## Key decisions
- **No price** (D17). Customization changes what a thing costs, so there is no such thing as
  *the* price of a chocolate truffle cake. Prices are typed per order, with history as hints.
- **No flavour list.** Flavour is free text on the line; past flavours for that item are
  offered as suggestions.
- **Items are never typed onto an order** (D16). `menu_item_id` is not null.
- **The menu is maintained in Config, not mid-order.** The order picker only lists what
  exists; adding an item means leaving the order form for *More › Menu items*
  mid-phone-call. What it creates is a real menu entry, not a string.
- **Maintained in Config** (D22) — nothing here is touched during a working day.

## Why the constraint earns its place
With typed names, "Choc truffle" and "Chocolate Truffle" are two products and *sales by
product* becomes a spelling survey. With the menu authoritative, it is a real number.

## Failure modes
| Case | Behaviour |
|---|---|
| Item deleted while on an open order | The line keeps its name snapshot and stays readable |
| Item renamed | Existing lines unchanged; new lines take the new name |
| Two devices add the same item | Two rows. Dedupe is a human decision in Config, not automatic |

## Non-goals
No variants matrix, no modifiers, no per-item options. Flavour, weight and special
requirements do that work on the order.
