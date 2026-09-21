# Reminders — HLD

Telling somebody, before the moment rather than after it, what the bakery has
to do.

## Purpose

An order the app knows about is an order the app can raise its hand over. Every
reminder here is a moment the device can work out from data it already holds,
so none of it needs a server, an account, or a network.

## Responsibilities

- Deciding **what** is worth interrupting somebody for, and **when**.
- Keeping that schedule in step with the orders, the stock and the menu.
- Saying, on the journey itself, when one is past its hour and still here.

## Owns

Nothing in the database. The schedule is derived on every change and thrown
away — there is no reminders table, because there is nothing to remember that
the orders do not already say.

## Depends on

`orders` (journeys, their items and their hours), `stock` (what is below its
threshold), `menu` (the notice an item needs).

## Key decisions

**No push server, and none needed.** Every moment is computable locally, so
each device schedules its own. Both phones therefore raise the same reminder:
with no server there is nobody to decide whose should ring, and for a delivery
both owners want to know anyway.

**One notification per moment, not per journey.** Two cakes leaving at four
o'clock are one buzz at half past three naming both. This is the property that
keeps the phone usable as the bakery grows — volume follows the number of
distinct handover times in a day, not the number of orders, so ten orders and
thirty both cost about seventeen notifications.

**A warning on the journey outlives the notification.** A buzz is easy to miss
and impossible to come back to; a line on the journey is still there when you
next look. Both exist because they answer different questions.

**Nothing is ever refused.** Four hours late still has to be recordable — a
handover the app will not accept is a journey that can never be closed.

## Failure modes

| | |
|---|---|
| Notifications denied | Everything else still works. The in-app warnings do not depend on permission |
| Phone asleep at six | Android fires it late. The digest describes a day, not an instant, so late is still useful |
| Phone rebooted | The plugin's boot receiver reschedules; the manifest declares it |
| Two devices | Both ring. Accepted, and deliberate — see above |
| Exact alarms restricted | `USE_EXACT_ALARM` is granted at install because the app is side-loaded rather than shipped through Play |

## Non-goals

- **No reminder table, no delivery receipts, no read state.** The app knows it
  asked Android to raise something. Whether anyone saw it is not knowable.
- **No per-item reminders.** The kitchen works to journeys (D29).
- **No reminder for money owed.** Chasing a payment is a decision somebody
  makes with a minute to spare, not a moment they need interrupting for.
