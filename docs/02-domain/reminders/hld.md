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

**A day's notice, so the bake can start the day before.** The six o'clock
digest arrives on the morning a journey goes out, which is too late for
anything that has to be made the day before — and the "start X" line only
speaks for items with a lead time set. So every confirmed journey also gets a
**prep** reminder twenty-four hours before its handover, naming what to make
with flavour, weight and count. Confirmed only, the same line the Kitchen
board draws: an order still merely created is not the kitchen's yet. An order
confirmed with less than a day to go gets it thirty minutes after confirming —
counted from the confirmation, not from now, so rebuilding the schedule never
raises it twice. It costs
one notification per distinct handover time, batched like the rest.

**The schedule follows the database, wherever the write came from.** A running
app rebuilds it on every change. A closed one used to keep whatever it last
laid out, so an order the other phone took at seven was missing from tonight's
prep reminder until somebody opened the app here. The background sync now
rebuilds the schedule whenever it applies a peer's ops.

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
| An order arrives over sync while the app is closed | The background sync rebuilds the schedule after applying it. WorkManager runs that every fifteen minutes at best and later under Doze, so a reminder can still be one sync behind |
| Foreground and background rebuild at once | Both cancel everything and lay out the same schedule from the same database. The last one wins, with the same result |
| Exact alarms restricted | `USE_EXACT_ALARM` is granted at install because the app is side-loaded rather than shipped through Play |

## Non-goals

- **No reminder table, no delivery receipts, no read state.** The app knows it
  asked Android to raise something. Whether anyone saw it is not knowable.
- **No per-item reminders.** The kitchen works to journeys (D29).
- **No reminder for money owed before the handover.** An order that has been
  handed over and not paid for is nudged every twelve hours until it is
  settled (`ReminderSlot.paymentDue`); nothing chases money that is not yet
  due. This line used to say there was no payment reminder at all, which the
  code had stopped being true of.
