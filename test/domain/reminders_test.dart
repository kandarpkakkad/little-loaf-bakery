import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/money.dart';
import 'package:little_loaf/domain/orders/model.dart';
import 'package:little_loaf/domain/reminders/model.dart';

import '../support/harness.dart';

/// The prep reminder: a day's notice of what to make (reminders/lld.md §2a).
///
/// Pure functions with the clock passed in, so every case says exactly what
/// "now" is. Days come from `dayAfter`, never a literal date (AGENTS.md).
void main() {
  var n = 0;

  /// [hour]:[minute] on the day [day] days from today.
  DateTime on(int day, int hour, [int minute = 0]) =>
      DateTime.fromMillisecondsSinceEpoch(dayAfter(day))
          .add(Duration(hours: hour, minutes: minute));

  OrderLine line(
    String name, {
    int qty = 1,
    String? flavour,
    Weight? weight,
    LineStatus status = LineStatus.confirmed,
  }) =>
      OrderLine(
        id: 'l${n++}',
        menuItemId: 'm-$name',
        itemName: name,
        qty: qty,
        basePrice: Money.rupees(100),
        flavour: flavour,
        weight: weight,
        status: status,
      );

  SubOrder sub({
    required int day,
    int? hour,
    SubOrderStatus status = SubOrderStatus.confirmed,
    Fulfilment fulfilment = Fulfilment.delivery,
    List<OrderLine>? lines,
  }) =>
      SubOrder(
        id: 's${n++}',
        seq: 1,
        status: status,
        deliveryDate: dayAfter(day),
        deliveryTime: hour == null ? null : hour * 60,
        fulfilment: fulfilment,
        lines: lines ?? [line('Cake')],
      );

  List<Reminder> prep(SubOrder j, DateTime now,
          {String who = 'Priya', DateTime? confirmed}) =>
      prepRemindersFor(j,
          customerFirstName: who,
          orderNo: 'LLB-0001',
          confirmedAt: confirmed?.millisecondsSinceEpoch,
          now: now);

  group('when a prep reminder fires', () {
    test('a day before a confirmed timed journey', () {
      final r = prep(sub(day: 2, hour: 16), on(0, 9)).single;
      expect(r.slot, ReminderSlot.prep);
      expect(r.at, on(1, 16));
      expect(r.title, 'Tomorrow 4:00 pm: Priya');
      expect(r.subOrderId, kDigestPayload,
          reason: 'a tap opens the Kitchen, where the Bake sheet is');
    });

    test('at six the day before an untimed journey', () {
      final r = prep(sub(day: 2), on(0, 9)).single;
      expect(r.at, on(1, 6));
      expect(r.title, 'Tomorrow, any time: Priya');
      expect(r.body, contains('delivery, any time'));
    });

    test('never for work the kitchen does not have', () {
      for (final s in [
        SubOrderStatus.created,
        SubOrderStatus.delivered,
        SubOrderStatus.cancelled,
      ]) {
        expect(prep(sub(day: 2, hour: 16, status: s), on(0, 9)), isEmpty,
            reason: s.name);
      }
      expect(
          prep(
              sub(day: 2, hour: 16, lines: [
                line('Cake', status: LineStatus.cancelled),
              ]),
              on(0, 9)),
          isEmpty,
          reason: 'nothing live on it, so nothing to make');
    });

    test('for confirmed work at every stage before the handover', () {
      for (final s in [
        SubOrderStatus.confirmed,
        SubOrderStatus.inProduction,
        SubOrderStatus.ready,
        SubOrderStatus.out,
      ]) {
        expect(prep(sub(day: 2, hour: 16, status: s), on(0, 9)), hasLength(1),
            reason: s.name);
      }
    });
  });

  group('confirmed with less than a day to go', () {
    test('fires half an hour after confirming', () {
      final confirmed = on(0, 20);
      final r =
          prep(sub(day: 1, hour: 10), confirmed, confirmed: confirmed).single;
      expect(r.at, on(0, 20, 30));
      expect(r.title, 'Tomorrow 10:00 am: Priya');
    });

    test('says today when confirmed on the day itself', () {
      final confirmed = on(1, 9);
      final r =
          prep(sub(day: 1, hour: 14), confirmed, confirmed: confirmed).single;
      expect(r.at, on(1, 9, 30));
      expect(r.title, 'Today 2:00 pm: Priya');
    });

    test('a day or more ahead keeps the day-before mark', () {
      final confirmed = on(0, 9);
      final r =
          prep(sub(day: 1, hour: 16), confirmed, confirmed: confirmed).single;
      expect(r.at, on(0, 16));
    });

    test('is not raised again by a rebuild after it fired', () {
      // The schedule is rebuilt on every edit and sync. A reminder counted
      // from "now" would buzz again each time; one counted from the
      // confirmation has simply passed.
      expect(
          prep(sub(day: 1, hour: 14), on(1, 10), confirmed: on(1, 9)), isEmpty);
      expect(prep(sub(day: 2, hour: 16), on(1, 17), confirmed: on(0, 9)),
          isEmpty,
          reason: 'the day-before mark has passed too');
    });

    test('stays quiet when the half-hour warning would say it first', () {
      final confirmed = on(1, 13);
      expect(prep(sub(day: 1, hour: 14), confirmed, confirmed: confirmed),
          isEmpty);
    });

    test('an untimed one fires half an hour after confirming too', () {
      final evening = on(0, 20);
      expect(prep(sub(day: 1), evening, confirmed: evening).single.title,
          'Tomorrow, any time: Priya');
      final morning = on(1, 9);
      final r = prep(sub(day: 1), morning, confirmed: morning).single;
      expect(r.at, on(1, 9, 30));
      expect(r.title, 'Today, any time: Priya');
    });
  });

  group('what it says', () {
    test('names what to make the way the Bake sheet does', () {
      final r = prep(
        sub(day: 2, hour: 16, lines: [
          line('Sourdough', qty: 2, weight: const Weight(500, 'g')),
          line('Croissant', qty: 6),
          line('Cake', flavour: 'Chocolate'),
        ]),
        on(0, 9),
      ).single;
      expect(r.body,
          'Sourdough · 500 g ×2, Croissant ×6, Cake · Chocolate — '
          'delivery at 4:00 pm · LLB-0001-1');
    });

    test('leaves out a cancelled line', () {
      final r = prep(
        sub(day: 2, hour: 16, lines: [
          line('Cake'),
          line('Bread', status: LineStatus.cancelled),
        ]),
        on(0, 9),
      ).single;
      expect(r.body, isNot(contains('Bread')));
    });

    test('says collects for a pickup', () {
      final r = prep(
          sub(day: 2, hour: 16, fulfilment: Fulfilment.pickup), on(0, 9));
      expect(r.single.body, contains('collects at 4:00 pm'));
    });
  });

  group('batching', () {
    test('two journeys at one hour are one notification', () {
      final now = on(0, 9);
      final merged = batched([
        ...prep(sub(day: 2, hour: 16, lines: [line('Cake')]), now),
        ...prep(sub(day: 2, hour: 16, lines: [line('Bread')]), now,
            who: 'Ravi'),
      ]);
      expect(merged, hasLength(1));
      expect(merged.single.title, '2 orders to prep for tomorrow');
      expect(merged.single.body, 'Priya — Cake · Ravi — Bread');
      expect(merged.single.subOrderId, kDigestPayload);
    });

    test('two journeys at different hours stay two', () {
      final now = on(0, 9);
      expect(
          batched([
            ...prep(sub(day: 2, hour: 10), now),
            ...prep(sub(day: 2, hour: 16), now),
          ]),
          hasLength(2));
    });

    test('a short-notice batch on the day says for today', () {
      // One order, two journeys, confirmed at nine: both land at half past.
      final now = on(1, 9);
      final merged = batched([
        ...prep(sub(day: 1, hour: 14), now, confirmed: now),
        ...prep(sub(day: 1, hour: 15), now, who: 'Ravi', confirmed: now),
      ]);
      expect(merged.single.title, '2 orders to prep for today');
    });

    test('never merges with a half-hour warning on the same minute', () {
      final now = on(0, 9);
      // Prep for Saturday 4 pm and the half-hour warning for Friday 4:30 pm
      // both land at Friday 4 pm.
      final halfHour = remindersFor(
        SubOrder(
          id: 'x',
          seq: 1,
          status: SubOrderStatus.confirmed,
          deliveryDate: dayAfter(1),
          deliveryTime: 16 * 60 + 30,
          fulfilment: Fulfilment.delivery,
          lines: [line('Cake')],
        ),
        customerFirstName: 'Ravi',
        orderNo: 'LLB-0002',
        now: now,
      ).where((r) => r.slot == ReminderSlot.halfHour);
      final saturday = prep(sub(day: 2, hour: 16), now);
      expect(saturday.single.at, halfHour.single.at);
      expect(batched([...halfHour, ...saturday]), hasLength(2));
    });
  });
}
