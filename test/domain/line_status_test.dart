import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/money.dart';
import 'package:little_loaf/domain/orders/model.dart';

/// The three status machines, each derived from the one below (D28, D29).
void main() {
  var n = 0;

  OrderLine line(LineStatus status, {int price = 100}) => OrderLine(
        id: 'l${n++}',
        menuItemId: 'm1',
        itemName: 'Cake',
        qty: 1,
        basePrice: Money.rupees(price),
        status: status,
      );

  SubOrder sub(
    SubOrderStatus status, {
    int date = 100,
    int? time,
    Fulfilment fulfilment = Fulfilment.delivery,
    int charge = 0,
    List<OrderLine> lines = const [],
  }) =>
      SubOrder(
        id: 's${n++}',
        seq: 1,
        status: status,
        deliveryDate: date,
        deliveryTime: time,
        fulfilment: fulfilment,
        deliveryCharge: Money(charge),
        lines: lines,
      );

  group('the item state machine', () {
    test('runs forward and stops at the ends', () {
      expect(LineStatus.created.canGoTo(LineStatus.confirmed), isTrue);
      expect(LineStatus.confirmed.canGoTo(LineStatus.inProduction), isTrue);
      expect(LineStatus.inProduction.canGoTo(LineStatus.ready), isTrue);
      expect(LineStatus.ready.canGoTo(LineStatus.delivered), isTrue);
      expect(LineStatus.delivered.next, isEmpty, reason: 'terminal');
      expect(LineStatus.cancelled.next, isEmpty, reason: 'terminal');
    });

    test('an item never goes out for delivery', () {
      // It does not travel on its own — its sub-order does (D29). The enum
      // has no such value to reach.
      expect(LineStatus.values.map((s) => s.wire), isNot(contains('out')));
    });

    test('a delivered item cannot be cancelled', () {
      expect(LineStatus.delivered.canGoTo(LineStatus.cancelled), isFalse,
          reason: 'no cancel after handover');
    });

    test('what an item is stays editable until work starts', () {
      expect(LineStatus.created.isEditable, isTrue);
      expect(LineStatus.confirmed.isEditable, isTrue);
      expect(LineStatus.inProduction.isEditable, isFalse,
          reason: 'the tin has been weighed');
      expect(LineStatus.inProduction.hasStarted, isTrue);
      expect(LineStatus.confirmed.hasStarted, isFalse);
    });

    test('a status from a newer build is read as not-started, not a crash', () {
      expect(LineStatus.parse('teleported'), LineStatus.created);
    });
  });

  group('a journey follows its items', () {
    test('nothing confirmed yet means created, whatever the items say', () {
      expect(
        deriveSubOrderStatus(SubOrderStatus.created, [line(LineStatus.ready)],
            orderConfirmed: false),
        SubOrderStatus.created,
      );
    });

    test('confirmed while everything on it is still waiting', () {
      expect(
        deriveSubOrderStatus(
            SubOrderStatus.confirmed, [line(LineStatus.confirmed)],
            orderConfirmed: true),
        SubOrderStatus.confirmed,
      );
    });

    test('the first item to start puts the journey in production', () {
      expect(
        deriveSubOrderStatus(
          SubOrderStatus.confirmed,
          [line(LineStatus.confirmed), line(LineStatus.inProduction)],
          orderConfirmed: true,
        ),
        SubOrderStatus.inProduction,
        reason: 'one baker has started, so the journey has',
      );
    });

    test('ready only when every live item is', () {
      expect(
        deriveSubOrderStatus(
          SubOrderStatus.confirmed,
          [line(LineStatus.ready), line(LineStatus.inProduction)],
          orderConfirmed: true,
        ),
        SubOrderStatus.inProduction,
        reason: 'one cake still in the oven holds the van',
      );
      expect(
        deriveSubOrderStatus(
          SubOrderStatus.confirmed,
          [line(LineStatus.ready), line(LineStatus.ready)],
          orderConfirmed: true,
        ),
        SubOrderStatus.ready,
      );
    });

    test('once a person has moved it, the items stop deciding', () {
      // Nothing about a cake can tell you the van has left.
      expect(
        deriveSubOrderStatus(
            SubOrderStatus.out, [line(LineStatus.ready)], orderConfirmed: true),
        SubOrderStatus.out,
      );
      expect(
        deriveSubOrderStatus(SubOrderStatus.delivered,
            [line(LineStatus.delivered)], orderConfirmed: true),
        SubOrderStatus.delivered,
      );
    });

    test('everything on it cancelled cancels the journey', () {
      expect(
        deriveSubOrderStatus(
            SubOrderStatus.confirmed, [line(LineStatus.cancelled)],
            orderConfirmed: true),
        SubOrderStatus.cancelled,
        reason: 'nobody cancels a journey — they cancel what was on it',
      );
    });

    test('a delivery goes out; a pickup is collected straight from ready', () {
      expect(SubOrderStatus.ready.nextFor(isPickup: false), SubOrderStatus.out);
      expect(SubOrderStatus.ready.nextFor(isPickup: true),
          SubOrderStatus.delivered);
      expect(SubOrderStatus.out.nextFor(isPickup: false),
          SubOrderStatus.delivered);
      expect(SubOrderStatus.delivered.nextFor(isPickup: false), isNull);
    });
  });

  group('an order follows its journeys', () {
    test('no confirmation yet means created, whatever the journeys say', () {
      expect(deriveOrderStatus([sub(SubOrderStatus.ready)]),
          OrderStatus.created);
    });

    test('the first journey to start puts the order in production', () {
      expect(
        deriveOrderStatus(
          [sub(SubOrderStatus.confirmed), sub(SubOrderStatus.inProduction)],
          confirmedAt: 1,
        ),
        OrderStatus.inProduction,
      );
    });

    test('the order never reads ready or out', () {
      // Half a ready order is not a thing, and an order does not travel.
      for (final st in [SubOrderStatus.ready, SubOrderStatus.out]) {
        expect(
          deriveOrderStatus([sub(SubOrderStatus.confirmed), sub(st)],
              confirmedAt: 1),
          OrderStatus.inProduction,
        );
      }
    });

    test('delivered only when every live journey is', () {
      expect(
        deriveOrderStatus(
            [sub(SubOrderStatus.delivered), sub(SubOrderStatus.out)],
            confirmedAt: 1),
        OrderStatus.inProduction,
        reason: 'one van still out — the order is not delivered',
      );
      expect(
        deriveOrderStatus(
            [sub(SubOrderStatus.delivered), sub(SubOrderStatus.delivered)],
            confirmedAt: 1),
        OrderStatus.delivered,
      );
    });

    test('a cancelled journey does not hold delivery back', () {
      expect(
        deriveOrderStatus(
            [sub(SubOrderStatus.delivered), sub(SubOrderStatus.cancelled)],
            confirmedAt: 1),
        OrderStatus.delivered,
      );
    });

    test('every journey cancelled cancels the order', () {
      expect(
        deriveOrderStatus([sub(SubOrderStatus.cancelled)], confirmedAt: 1),
        OrderStatus.cancelled,
      );
      expect(deriveOrderStatus([sub(SubOrderStatus.cancelled)]),
          OrderStatus.cancelled);
    });

    test('completed is delivered plus the deliberate moment', () {
      final subs = [sub(SubOrderStatus.delivered)];
      expect(deriveOrderStatus(subs, confirmedAt: 1), OrderStatus.delivered);
      expect(deriveOrderStatus(subs, confirmedAt: 1, completedAt: 2),
          OrderStatus.completed);
    });

    test('the finishing journey decides how the order ends', () {
      final subs = [
        sub(SubOrderStatus.ready, date: 100, fulfilment: Fulfilment.delivery),
        sub(SubOrderStatus.ready, date: 900, fulfilment: Fulfilment.pickup),
      ];
      expect(finishingSubOrder(subs)!.fulfilment, Fulfilment.pickup,
          reason: 'the last one to be handed over is collected');
    });
  });

  group('dates, and what they are for', () {
    test('due is the LAST journey still outstanding', () {
      final subs = [
        sub(SubOrderStatus.delivered, date: 900), // done — does not hold it
        sub(SubOrderStatus.ready, date: 300),
        sub(SubOrderStatus.inProduction, date: 200),
      ];
      expect(deriveDueDate(subs), 300);
    });

    test('next is the EARLIEST, which is what the lists sort on', () {
      final subs = [
        sub(SubOrderStatus.ready, date: 500),
        sub(SubOrderStatus.confirmed, date: 200),
      ];
      expect(deriveDueDate(subs), 500, reason: 'Sunday is when it finishes');
      expect(deriveNextDate(subs), 200,
          reason: 'Friday is when somebody has to do something');
    });

    test('nothing outstanding has no date, so it sorts last', () {
      expect(deriveDueDate([sub(SubOrderStatus.delivered, date: 100)]), isNull);
      expect(deriveNextDate([sub(SubOrderStatus.delivered, date: 100)]), isNull);
    });
  });

  group('one charge per journey', () {
    test('two items in one van are charged once', () {
      final one = sub(SubOrderStatus.confirmed,
          charge: 5000,
          lines: [line(LineStatus.confirmed), line(LineStatus.confirmed)]);
      expect(deliveryTotal([one]), Money.rupees(50));
    });

    test('two journeys are charged twice', () {
      expect(
        deliveryTotal([
          sub(SubOrderStatus.confirmed, date: 100, charge: 5000),
          sub(SubOrderStatus.confirmed, date: 200, charge: 5000),
        ]),
        Money.rupees(100),
      );
    });

    test('a cancelled journey costs nothing to send', () {
      expect(
        deliveryTotal([
          sub(SubOrderStatus.delivered, charge: 5000),
          sub(SubOrderStatus.cancelled, date: 200, charge: 5000),
        ]),
        Money.rupees(50),
      );
    });
  });

  group('the journey key', () {
    test('same day, time, way out and place is one journey', () {
      final a = SubOrder.keyOf(
          date: 100,
          time: 600,
          fulfilment: Fulfilment.delivery,
          addressText: '14 Turner Rd');
      final b = SubOrder.keyOf(
          date: 100,
          time: 600,
          fulfilment: Fulfilment.delivery,
          addressText: '14 Turner Rd');
      expect(a, b);
    });

    test('a different address on the same day is a different journey', () {
      final a = SubOrder.keyOf(
          date: 100, fulfilment: Fulfilment.delivery, addressText: 'here');
      final b = SubOrder.keyOf(
          date: 100, fulfilment: Fulfilment.delivery, addressText: 'there');
      expect(a, isNot(b), reason: 'two doors is two journeys');
    });

    test('collecting and delivering on one day are two journeys', () {
      final a = SubOrder.keyOf(date: 100, fulfilment: Fulfilment.delivery);
      final b = SubOrder.keyOf(date: 100, fulfilment: Fulfilment.pickup);
      expect(a, isNot(b));
    });
  });
}
