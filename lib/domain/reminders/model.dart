/// When somebody should be interrupted about a journey, and why.
///
/// Pure: no plugin, no clock of its own, no database. What actually raises a
/// notification is `platform/notifications`; this decides *what* and *when*,
/// so both are testable without a phone.
library;

import '../orders/model.dart';

enum ReminderSlot {
  /// A day out — start making it.
  ///
  /// The six o'clock digest lands on the morning a journey goes out, which is
  /// too late for anything baked the day before, and its "start X" line only
  /// speaks for items with a lead time set. This is the one that does.
  prep,

  /// Thirty minutes out — leave now.
  ///
  /// There was a two-hour one as well. It was dropped: two hours before a
  /// handover is not a moment anybody acts on, and at thirty orders a day it
  /// was a third of the day's notifications saying nothing new.
  halfHour,

  /// An hour past, and nobody has moved it.
  overdue,

  /// Handed over, still unpaid, and nobody has chased it.
  ///
  /// Twelve-hourly rather than daily: a morning-only nudge that lands during
  /// the bake is a morning-only nudge that gets swiped away.
  paymentDue,

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
    this.who = '',
    this.what = '',
    this.handover,
  });

  final String subOrderId;
  final ReminderSlot slot;
  final DateTime at;
  final String title;
  final String body;

  /// Who it is for and what is on it, kept apart from the rendered title so
  /// that several journeys sharing a minute can be merged into one
  /// notification without parsing the text back out of it.
  final String who;
  final String what;

  /// When the journey a prep reminder is about is due — midnight of its day
  /// when it has no hour. Kept for the same reason as [who]: a merged prep
  /// reminder has to say "today" or "tomorrow", and reading that back out of
  /// a title is exactly what these fields exist to avoid.
  final DateTime? handover;

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
    final body = '$what — $verb at ${_clock(due)} · $ref';

    // The half-hour mark may already have gone — an order taken for twenty
    // minutes' time, or one that reached this phone on a sync after the mark
    // had passed. Firing a little late is right: the handover itself is still
    // ahead, and the alternative is a rush order raising nothing at all until
    // it is already overdue. It says how long is really left, because "30
    // minutes" when there are twenty would be a lie.
    if (due.isAfter(at)) {
      final mark = due.subtract(const Duration(minutes: 30));
      final fireAt = mark.isAfter(at) ? mark : at.add(const Duration(minutes: 1));
      final left = due.difference(fireAt).inMinutes;
      moments.add((
        ReminderSlot.halfHour,
        fireAt,
        left >= 30
            ? '30 minutes: $who'
            : (left >= 2 ? 'Due in $left minutes: $who' : 'Due now: $who'),
        body,
      ));
    }

    moments.addAll([
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
          subOrderId: j.id,
          slot: slot,
          at: fireAt,
          title: title,
          body: body,
          who: who,
          what: what,
        ),
  ];
}

/// How far ahead of a handover the kitchen is told what to make.
const Duration kPrepAhead = Duration(hours: 24);

/// How long after confirming a short-notice order its prep reminder comes.
const Duration kPrepAfterConfirm = Duration(minutes: 30);

/// A day's notice of what to make for one journey, or nothing.
///
/// Separate from [remindersFor] because the filter is different: this is the
/// kitchen's work, so it speaks only for what the Kitchen board shows — a
/// journey still `created` belongs to an order nobody has confirmed, and
/// telling the kitchen to start it would be telling them to bake on spec.
///
/// [confirmedAt] is the order's `confirmed_at`. A journey due less than a day
/// after it can never get a day's notice, so it gets its reminder half an hour
/// after confirming instead.
///
/// docs/02-domain/reminders/lld.md §2a.
List<Reminder> prepRemindersFor(
  SubOrder j, {
  required String customerFirstName,
  required String orderNo,
  int? confirmedAt,
  DateTime? now,
}) {
  if (j.status.isDone || j.status == SubOrderStatus.created) return const [];
  if (j.liveLines.isEmpty) return const [];
  final at = now ?? DateTime.now();
  final who = customerFirstName;
  final what = _what(j, (l) => l.bakeLabel);
  final ref = j.reference(orderNo);

  final d = DateTime.fromMillisecondsSinceEpoch(j.deliveryDate);
  final due = scheduledAt(j);
  final handover = due ?? DateTime(d.year, d.month, d.day);

  // An untimed journey has no hour to count back from, so it gets the whole
  // day before — and every untimed journey for one day lands on one minute,
  // which batches them into one notification.
  final mark = due == null
      ? DateTime(d.year, d.month, d.day - 1, kMorningHour)
      : due.subtract(kPrepAhead);

  // Confirmed with less than a day to go — an order taken tonight for tomorrow
  // morning — so the mark was gone before the kitchen had the work. Half an
  // hour after confirming instead.
  //
  // Anchored to the confirmation, never to now. The schedule is rebuilt on
  // every edit and every sync, and "a minute from now" was tried first: each
  // rebuild after the mark would have raised the same reminder again. A fixed
  // moment that has passed is one that already fired, and is dropped below.
  final confirmed = confirmedAt == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(confirmedAt);
  final fireAt = confirmed != null && mark.isBefore(confirmed)
      ? confirmed.add(kPrepAfterConfirm)
      : mark;
  if (!fireAt.isAfter(at)) return const [];

  // Half an hour after confirming can be too close to the handover to say
  // anything the half-hour warning will not. An untimed journey has no such
  // warning, so it speaks until its day is over.
  final covering = due == null
      ? DateTime(d.year, d.month, d.day + 1)
      : due.subtract(const Duration(minutes: 30));
  if (!fireAt.isBefore(covering)) return const [];

  // Counted from when it fires, not from now: a short-notice order confirmed
  // on the day itself says "Today", and "Tomorrow" then would send somebody
  // to bed.
  final day = _sameDay(handover, fireAt) ? 'Today' : 'Tomorrow';
  final verb = j.isPickup ? 'collects' : 'delivery';

  return [
    Reminder(
      // The Kitchen, single or batched: the Bake sheet is where the prep is
      // read in full, and a one-journey payload has nowhere to go.
      subOrderId: kDigestPayload,
      slot: ReminderSlot.prep,
      at: fireAt,
      title: due == null ? '$day, any time: $who' : '$day ${_clock(due)}: $who',
      body: due == null
          ? '$what — ${j.isPickup ? 'pickup' : 'delivery'}, any time · $ref'
          : '$what — $verb at ${_clock(due)} · $ref',
      who: who,
      what: what,
      handover: handover,
    ),
  ];
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// "for today", "for tomorrow", or nothing when a late batch mixes the two.
String _prepFor(List<Reminder> group) {
  bool today(Reminder r) => r.handover != null && _sameDay(r.handover!, r.at);
  if (group.every(today)) return ' for today';
  if (!group.any(today)) return ' for tomorrow';
  return '';
}

/// One notification per moment, however many journeys share it.
///
/// Two cakes leaving at four o'clock produced two identical buzzes half an
/// hour earlier. At ten orders a day that is a notification every twenty
/// minutes and at thirty it is one every eight, which is the point where
/// somebody turns them off — and then the one that mattered does not arrive
/// either. Merging by the minute costs nothing and is the difference between
/// a useful phone and a silenced one.
///
/// Grouped on slot **and** minute: a half-hour warning and an overdue nudge
/// landing together are different things to say.
List<Reminder> batched(List<Reminder> reminders) {
  final byMoment = <String, List<Reminder>>{};
  for (final r in reminders) {
    final minute = r.at.millisecondsSinceEpoch ~/ 60000;
    (byMoment['${r.slot.name}|$minute'] ??= []).add(r);
  }

  return [
    for (final group in byMoment.values)
      if (group.length == 1)
        group.single
      else
        Reminder(
          // Several journeys, so a tap goes to the board rather than to any
          // one of them.
          subOrderId: kDigestPayload,
          slot: group.first.slot,
          at: group.first.at,
          title: switch (group.first.slot) {
            ReminderSlot.prep =>
              '${group.length} orders to prep${_prepFor(group)}',
            ReminderSlot.halfHour => '${group.length} handovers coming up',
            ReminderSlot.overdue =>
              '${group.length} still not handed over',
            ReminderSlot.paymentDue => '${group.length} orders still unpaid',
            _ => group.first.title,
          },
          body: [for (final r in group) '${r.who} — ${r.what}'].join(' · '),
        ),
  ]..sort((a, b) => a.at.compareTo(b.at));
}

/// The soonest a thing needing [leadDays] notice can be promised.
///
/// Midnight, so it compares with a journey's own date. Zero notice means
/// today — a bakery that has it on the shelf can hand it over now.
int soonestFor(int leadDays, {DateTime? now}) {
  final n = now ?? DateTime.now();
  return DateTime(n.year, n.month, n.day + leadDays).millisecondsSinceEpoch;
}

/// Whether a date is sooner than the notice its items need.
///
/// A warning, never a refusal: a bakery that wants to try can try, and the app
/// saying no to a customer standing in front of somebody is not its place.
bool isRush(int deliveryDate, int leadDays, {DateTime? now}) =>
    deliveryDate < soonestFor(leadDays, now: now);

/// One notification per day, at six, for every day that has work on it.
///
/// Scheduled rather than repeating: a daily repeat would fire on quiet days
/// too, and the requirement is a morning only when something is actually due.
/// The order book is known in advance, so the days that need one are known in
/// advance as well.
///
/// Tapping it opens the Kitchen, which is the screen the day is worked from.
List<Reminder> morningDigests(
  Iterable<SubOrder> journeys, {
  /// menu item id → days of notice it needs. Anything with none is left out:
  /// "start the buns today" on the morning they are due says nothing.
  Map<String, int> leadDays = const {},
  List<String> lowStock = const [],
  DateTime? now,
}) {
  final at = now ?? DateTime.now();

  // What has to go in the oven on a given morning to be ready on time.
  final startOn = <int, Set<String>>{};
  for (final j in journeys) {
    if (j.status.isDone) continue;
    for (final l in j.liveLines) {
      final lead = leadDays[l.menuItemId] ?? 0;
      if (lead <= 0) continue;
      final d = DateTime.fromMillisecondsSinceEpoch(j.deliveryDate);
      final day = DateTime(d.year, d.month, d.day - lead).millisecondsSinceEpoch;
      (startOn[day] ??= <String>{}).add(l.itemName);
    }
  }

  final byDay = <int, List<SubOrder>>{};
  for (final j in journeys) {
    if (j.status.isDone || j.liveLines.isEmpty) continue;
    (byDay[j.deliveryDate] ??= []).add(j);
  }

  final out = <Reminder>[];
  for (final day in {...byDay.keys, ...startOn.keys}) {
    final d = DateTime.fromMillisecondsSinceEpoch(day);
    final fireAt = DateTime(d.year, d.month, d.day, kMorningHour);
    if (!fireAt.isAfter(at)) continue;

    final toStart = startOn[day] ?? const <String>{};
    final all = byDay[day] ?? const <SubOrder>[];

    // A morning with nothing going out but something to begin is still a
    // morning worth speaking on — it is the whole point of a lead time.
    if (all.isEmpty) {
      out.add(Reminder(
        subOrderId: kDigestPayload,
        slot: ReminderSlot.morning,
        at: fireAt,
        title: toStart.length == 1
            ? 'Start one thing today'
            : 'Start ${toStart.length} things today',
        body: toStart.join(', '),
      ));
      continue;
    }
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
        if (toStart.isNotEmpty) 'start ${toStart.join(', ')}',
      ].join(' · '),
    ));
  }

  out.sort((a, b) => a.at.compareTo(b.at));

  // What is low gets one line on the NEXT morning only.
  //
  // Not on every morning in the list: the order book is known days ahead, but
  // how much butter there will be on Thursday is not. Saying so three mornings
  // running would be three guesses. The schedule is rebuilt whenever stock
  // moves, so by the time Thursday is the next morning, its line is current.
  if (lowStock.isNotEmpty) {
    final nextMorning = _nextMorning(at);
    final existing = out.indexWhere((r) => r.at == nextMorning);
    final what = lowStock.length <= 3
        ? lowStock.join(', ')
        : '${lowStock.take(3).join(', ')} and ${lowStock.length - 3} more';

    if (existing >= 0) {
      final r = out[existing];
      out[existing] = Reminder(
        subOrderId: r.subOrderId,
        slot: r.slot,
        at: r.at,
        title: r.title,
        body: '${r.body} · Low: $what',
      );
    } else {
      // A quiet morning, but there is shopping to do — which is exactly the
      // morning you would want to know.
      out.insert(
        0,
        Reminder(
          subOrderId: kDigestPayload,
          slot: ReminderSlot.morning,
          at: nextMorning,
          title: lowStock.length == 1
              ? 'One thing to buy'
              : '${lowStock.length} things to buy',
          body: '$what — below threshold',
        ),
      );
    }
  }

  return out;
}

/// Six o'clock on the next day that has not had its six o'clock yet.
DateTime _nextMorning(DateTime at) {
  final today = DateTime(at.year, at.month, at.day, kMorningHour);
  return today.isAfter(at) ? today : today.add(const Duration(days: 1));
}

/// Marks a reminder that belongs to the day rather than to one journey.
/// The platform side routes a tap on it to the Kitchen.
const String kDigestPayload = 'kitchen';

/// What is on the journey, short enough for a notification line.
///
/// By item name unless told otherwise: leaving the van, "Cake" is enough, but
/// the prep reminder passes [OrderLine.bakeLabel], because the kitchen has to
/// know which cake.
String _what(SubOrder j, [String Function(OrderLine l)? label]) {
  final live = j.liveLines;
  if (live.isEmpty) return 'Nothing on it';
  final counts = <String, int>{};
  for (final l in live) {
    final name = label == null ? l.itemName : label(l);
    counts[name] = (counts[name] ?? 0) + l.qty;
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

/// How often an unpaid order asks again once it has been handed over.
const Duration kPaymentNudge = Duration(hours: 12);

/// The next moment to mention an order that was handed over and not paid for.
///
/// Counted from the handover rather than from now, so the reminder lands at
/// the same two times of day for a given order instead of drifting forward
/// every time the app recalculates.
///
/// Returns null when there is nothing to chase — not handed over, or settled.
DateTime? nextPaymentNudge({
  required int? handedOverAt,
  required bool owes,
  required DateTime now,
}) {
  if (!owes || handedOverAt == null) return null;
  final from = DateTime.fromMillisecondsSinceEpoch(handedOverAt);
  var due = from.add(kPaymentNudge);
  while (!due.isAfter(now)) {
    due = due.add(kPaymentNudge);
  }
  return due;
}

/// One reminder per unpaid order, at its next nudge.
///
/// Only the next one: the service cancels and rewrites the whole schedule
/// whenever the orders change, so a queue of future nudges would be thrown
/// away and rebuilt anyway — and the one that matters is the next.
List<Reminder> paymentReminders(
  Iterable<({String orderId, String orderNo, String who, int? handedOverAt, bool owes, String amount})> orders, {
  required DateTime now,
}) {
  final out = <Reminder>[];
  for (final o in orders) {
    final at = nextPaymentNudge(
        handedOverAt: o.handedOverAt, owes: o.owes, now: now);
    if (at == null) continue;
    out.add(Reminder(
      subOrderId: o.orderId,
      slot: ReminderSlot.paymentDue,
      at: at,
      title: '${o.who} still owes ${o.amount}',
      body: '${o.orderNo} was handed over and has not been paid for.',
      who: o.who,
      what: o.amount,
    ));
  }
  return out;
}
