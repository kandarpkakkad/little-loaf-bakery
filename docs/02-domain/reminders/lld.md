# Reminders — LLD

**Source of truth for shapes: none.** This system stores nothing. Everything
below is computed from `orders`, `stock` and `menu` on every change.

## 1. The moments

```dart
enum ReminderSlot { halfHour, overdue, morning }
```

| Slot | When | Covers |
|---|---|---|
| `halfHour` | 30 minutes before a journey's time | one journey |
| `overdue` | 1 hour after, if it has not been handed over | one journey |
| `morning` | 06:00, on any day with work, something to start, or shopping | the whole day |

**There was a two-hour warning and it was removed.** Two hours out is not a
moment anybody acts on, and it was a third of the day's notifications saying
nothing the thirty-minute one would not.

**An untimed journey gets no per-journey reminder at all.** It has no hour to
count from, and the day's own six o'clock digest already names it — two
notifications at the same instant about one cake is how people learn to swipe
them away without reading.

## 2. A moment already gone

```dart
// The half-hour mark may have passed: an order taken for twenty minutes'
// time, or one that arrived on a sync after the mark. Fire late rather than
// not at all -- but only while the HANDOVER is still ahead.
if (due.isAfter(now)) {
  final mark = due.subtract(const Duration(minutes: 30));
  final fireAt = mark.isAfter(now) ? mark : now.add(const Duration(minutes: 1));
  final left = due.difference(fireAt).inMinutes;
  title = left >= 30 ? '30 minutes: $who'
        : left >= 2  ? 'Due in $left minutes: $who'
                     : 'Due now: $who';
}
```

The title counts from **when it fires**, not from now: "30 minutes" when there
are twenty would be a lie. A handover already past gets nothing beforehand —
there is nothing left to warn about and the overdue nudge covers it.

This is a deliberate narrowing of "drop moments already past". That rule is
right for a moment whose event has also gone; it was wrong for one whose event
is still coming.

## 3. Batching

```dart
// Grouped on slot AND minute: a half-hour warning and an overdue nudge
// landing together are different things to say.
key = '${slot.name}|${at.millisecondsSinceEpoch ~/ 60000}'
```

One in a group keeps its own text. Several become `"2 handovers coming up"`
with a body of `who — what` joined, and tap through to the **board** rather
than to any one journey, because there is no single order they are about.

`Reminder` carries `who` and `what` beside the rendered title so a merge
composes from the parts instead of parsing a sentence it wrote earlier.

## 4. The morning digest

One per day that has **any** of: a handover, something that has to be started,
or something below its threshold. Scheduled, never a daily repeat — a
notification on a quiet morning is how people learn to ignore them.

| Carries | From |
|---|---|
| how many handovers, how they split, the earliest hour | the journeys due that day |
| `start X, Y` | items whose `delivery date − lead_days` is that day, and whose notice is **more than zero** |
| `Low: Butter, Flour` | stock below threshold — **the next morning only** |

**Only the next morning gets the stock line.** The order book is known days
ahead; how much butter there will be on Thursday is not, and saying so three
mornings running would be three guesses. The schedule rebuilds whenever stock
moves, so by the time Thursday is tomorrow its line is current.

Tapping a digest opens the **Kitchen** (payload `kitchen`).

## 5. Late, and very late

```dart
bool isLate(SubOrder j)      // past its hour and not handed over
bool isVeryLate(SubOrder j)  // more than four hours past
```

An **untimed** journey is late only once its **day** is over — "any time
Friday" is not late at four in the afternoon. `isVeryLate` never applies to one
at all: there is no hour for it to be four hours past.

Both clear on **delivered and cancelled and nothing else**. A journey marked
`out` is still one the customer has not received.

`isVeryLate` asks once before recording a handover, and **never refuses**: a
van that broke down still has to be recorded.

## 6. Keeping it in step

The service follows three streams — `watchOrders`, `watchLevels`,
`watchAll` on the menu — sharing one two-second debounce, and rebuilds the
**whole** schedule: cancel everything, lay it out again.

Wholesale rather than incrementally, because the alternative is tracking which
notification id belongs to which journey across every edit, reschedule and
sync — and a stale reminder for a cake already delivered is exactly what makes
somebody turn notifications off.

Following `watchOrders` covers a local edit and a peer's edit arriving over
sync in one hook, because both land in the same database.

## 7. What to test

- A moment already past fires soon and says the real number of minutes left.
- A handover already past raises nothing before it.
- Two journeys on one minute become one notification; on different minutes, two.
- A digest appears on a start-morning with nothing going out.
- An untimed journey produces no per-journey reminder.
- `isLate` clears on delivered and on cancelled, and on no other status.
- Volume: ten orders and thirty land within a few of each other.

**Nothing here can be tested off a device beyond the schedule itself.** Whether
a notification appears is Android's answer, not Dart's.
