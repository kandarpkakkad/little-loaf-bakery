/// When somebody should be interrupted about a journey, and why.
///
/// Pure: no plugin, no clock of its own, no database. What actually raises a
/// notification is `platform/notifications`; this decides *what* and *when*,
/// so both are testable without a phone.
library;

import '../orders/model.dart';

enum ReminderSlot {
  /// Two hours out — enough time to finish and box.
  twoHours,

  /// Thirty minutes out — leave now.
  halfHour,

  /// An hour past, and nobody has moved it.
  overdue,

  /// Six in the morning, once for the whole day. Replaced the per-journey
  /// version: an untimed journey used to get its own 6 am ping, which meant
  /// two notifications at the same instant saying overlapping things.
  morning,
}

class Reminder {
  const Reminder({
    required this.subOrderId,
    required this.slot,
    required this.at,
    required this.title,
    required this.body,
  });

  final String subOrderId;
  final ReminderSlot slot;
  final DateTime at;
  final String title;
  final String body;

  @override
  String toString() => '${slot.name} @ $at — $title / $body';
}

/// The hour an untimed journey is announced on its own day.
const int kMorningHour = 6;

/// How late a handover may be before the app says something out loud.
const Duration kLateAfter = Duration(hours: 4);

/// The scheduled moment of a journey, or null when it has no time of its own.
DateTime? scheduledAt(SubOrder j) {
  if (j.deliveryTime == null) return null;
  final d = DateTime.fromMillisecondsSinceEpoch(j.deliveryDate);
  return DateTime(d.year, d.month, d.day)
      .add(Duration(minutes: j.deliveryTime!));
}

/// Whether a journey is past its hour and still not handed over.
///
/// An untimed journey is late only once its **day** is over — "any time
/// Friday" is not late at four in the afternoon.
bool isLate(SubOrder j, {DateTime? now}) {
  if (j.status.isDone) return false;
  final at = now ?? DateTime.now();
  final due = scheduledAt(j);
  if (due != null) return at.isAfter(due);
  final d = DateTime.fromMillisecondsSinceEpoch(j.deliveryDate);
  return at.isAfter(DateTime(d.year, d.month, d.day + 1));
}

/// Whether handing this over now is late enough to be worth a question.
///
/// Untimed journeys are excluded by decision: there is no hour to be four
/// hours past.
bool isVeryLate(SubOrder j, {DateTime? now}) {
  if (j.status.isDone) return false;
  final due = scheduledAt(j);
  if (due == null) return false;
  return (now ?? DateTime.now()).isAfter(due.add(kLateAfter));
}

/// Every moment worth a notification for one journey, in order.
///
/// Moments already past are dropped — scheduling one is either a notification
/// that fires immediately or one that never fires, and both are worse than
/// silence. A done journey has none at all.
List<Reminder> remindersFor(
  SubOrder j, {
  required String customerFirstName,
  required String orderNo,
  DateTime? now,
}) {
  if (j.status.isDone) return const [];
  final at = now ?? DateTime.now();
  final what = _what(j);
  final who = customerFirstName;
  final ref = j.reference(orderNo);

  final due = scheduledAt(j);
  final moments = <(ReminderSlot, DateTime, String, String)>[];

  if (due == null) {
    // Nothing per-journey: an untimed journey has no hour to count from, and
    // the day's own six o'clock digest already names it. Two notifications at
    // the same instant about the same cake is how people learn to swipe them
    // away without reading.
  } else {
    final verb = j.isPickup ? 'collects' : 'delivery';
    moments.addAll([
      (
        ReminderSlot.twoHours,
        due.subtract(const Duration(hours: 2)),
        '2 hours: $who',
        '$what — $verb at ${_clock(due)} · $ref',
      ),
      (
        ReminderSlot.halfHour,
        due.subtract(const Duration(minutes: 30)),
        '30 minutes: $who',
        '$what — $verb at ${_clock(due)} · $ref',
      ),
      (
        ReminderSlot.overdue,
        due.add(const Duration(hours: 1)),
        'Still not ${j.isPickup ? "collected" : "delivered"}: $who',
        '$what — was due at ${_clock(due)} · $ref',
      ),
    ]);
  }

  return [
    for (final (slot, fireAt, title, body) in moments)
      if (fireAt.isAfter(at))
        Reminder(
            subOrderId: j.id, slot: slot, at: fireAt, title: title, body: body),
  ];
}

/// One notification per day, at six, for every day that has work on it.
///
/// Scheduled rather than repeating: a daily repeat would fire on quiet days
/// too, and the requirement is a morning only when something is actually due.
/// The order book is known in advance, so the days that need one are known in
/// advance as well.
///
/// Tapping it opens the Kitchen, which is the screen the day is worked from.
List<Reminder> morningDigests(Iterable<SubOrder> journeys, {DateTime? now}) {
  final at = now ?? DateTime.now();

  final byDay = <int, List<SubOrder>>{};
  for (final j in journeys) {
    if (j.status.isDone || j.liveLines.isEmpty) continue;
    (byDay[j.deliveryDate] ??= []).add(j);
  }

  final out = <Reminder>[];
  for (final entry in byDay.entries) {
    final d = DateTime.fromMillisecondsSinceEpoch(entry.key);
    final fireAt = DateTime(d.year, d.month, d.day, kMorningHour);
    if (!fireAt.isAfter(at)) continue;

    final all = entry.value;
    final pickups = all.where((j) => j.isPickup).length;
    final deliveries = all.length - pickups;

    // The earliest hour on the day, so the first line answers "how soon".
    final times = [
      for (final j in all)
        if (j.deliveryTime != null) j.deliveryTime!,
    ]..sort();

    out.add(Reminder(
      // The day itself, not a journey: this is about all of them.
      subOrderId: kDigestPayload,
      slot: ReminderSlot.morning,
      at: fireAt,
      title: all.length == 1
          ? 'One handover today'
          : '${all.length} handovers today',
      body: [
        if (deliveries > 0)
          '$deliveries ${deliveries == 1 ? 'delivery' : 'deliveries'}',
        if (pickups > 0) '$pickups ${pickups == 1 ? 'pickup' : 'pickups'}',
        if (times.isNotEmpty)
          'first at ${_clock(DateTime(d.year, d.month, d.day).add(Duration(minutes: times.first)))}'
        else
          'no set times',
      ].join(' · '),
    ));
  }

  out.sort((a, b) => a.at.compareTo(b.at));
  return out;
}

/// Marks a reminder that belongs to the day rather than to one journey.
/// The platform side routes a tap on it to the Kitchen.
const String kDigestPayload = 'kitchen';

/// What is on the journey, short enough for a notification line.
String _what(SubOrder j) {
  final live = j.liveLines;
  if (live.isEmpty) return 'Nothing on it';
  final counts = <String, int>{};
  for (final l in live) {
    counts[l.itemName] = (counts[l.itemName] ?? 0) + l.qty;
  }
  return counts.entries
      .map((e) => e.value > 1 ? '${e.key} ×${e.value}' : e.key)
      .join(', ');
}

String _clock(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m ${d.hour < 12 ? 'am' : 'pm'}';
}
