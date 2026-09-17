# Fulfilment — HLD

## Purpose
Get the day's baking and delivering done from a phone, with flour on your hands and no signal.

## Covers
- **Production board** — kanban by status, for a date range.
- **Daily production sheet** — grouped by product, totals, read on screen.
- **Delivery run** — today's stops in time order, with the delivery charge editable at handover.
- **Open location in…** — the app chooser for a stop.

## Owns
Nothing of its own. It is a set of views over `orders`, plus the location chooser.

## Depends on
orders, payments (collecting at the door), config.

## Key decisions
- **No prices on Kitchen screens.** Noise to someone holding a piping bag, not a secret — every
  device holds the whole database anyway (D1).
- **Requirements print in full and untruncated** on the board card and the sheet. A requirement
  the baker cannot see may as well not have been recorded.
- **⚑ marks requirements edited after confirming**, until the kitchen acknowledges. Baking
  yesterday's version of a custom cake is the expensive mistake this prevents.
- **The delivery charge is editable at handover** — distance, a changed address, a favour on the
  day. The balance recalculates and the invoice carries what was actually charged.
- **The sheet groups by product, not by order** — the baker needs the day's bake, not twelve
  separate orders.
- **The location chooser never depends on a third-party deep link succeeding.**

## The location chooser
| App | How | Confidence |
|---|---|---|
| Google Maps | `geo:` intent / universal link | Documented |
| Uber | `uber://?action=setPickup&dropoff[latitude]=…` | Documented |
| Rapido, Porter | Deep link if one works; else open the app with the address on the clipboard | **Unverified — test in M5** |
| No pin at all | Maps with the written address as a search query | — |

**Copy address is always last, and always works.** Only installed apps are listed — no dead
entries, no Play Store detours.

## Failure modes
| Case | Behaviour |
|---|---|
| No signal in the kitchen | Everything works. Status changes queue |
| Two devices move the same card | LWW; a backwards move lands in the conflict log |
| No delivery time set | Sorts to the end of the day under *Any time* |
| Deep link fails | Falls through to the app with the address copied |
| Pickup order in the delivery run | Excluded — it has no address |

## Non-goals
No route optimisation. No rider tracking. No proof-of-delivery signature — an optional photo
is enough.
