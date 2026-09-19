import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/money.dart';
import 'package:little_loaf/domain/orders/model.dart';

/// The line state machine, and the order status derived from it (D25, D26).
void main() {
  OrderLine line(
    LineStatus status, {
    int? date,
    int? time,
    Fulfilment? fulfilment,
    int price = 100,
  }) =>
      OrderLine(
        menuItemId: 'm1',
        itemName: 'Cake',
        qty: 1,
        basePrice: Money.rupees(price),
        status: status,
        deliveryDate: date,
        deliveryTime: time,
        fulfilment: fulfilment,
      );

  group('the line state machine', () {
    test('runs forward and stops at the ends', () {
      expect(LineStatus.created.canGoTo(LineStatus.confirmed), isTrue);
      expect(LineStatus.confirmed.canGoTo(LineStatus.inProduction), isTrue);
      expect(LineStatus.inProduction.canGoTo(LineStatus.ready), isTrue);
      expect(LineStatus.ready.canGoTo(LineStatus.out), isTrue);
      expect(LineStatus.out.canGoTo(LineStatus.delivered), isTrue);
      expect(LineStatus.delivered.next, isEmpty, reason: 'terminal');
      expect(LineStatus.cancelled.next, isEmpty, reason: 'terminal');
    });

    test('a delivered line cannot be cancelled', () {
      expect(LineStatus.delivered.canGoTo(LineStatus.cancelled), isFalse,
          reason: 'no cancel after handover');
    });

    test('ready goes straight to delivered — that is the pickup path', () {
      expect(LineStatus.ready.canGoTo(LineStatus.delivered), isTrue);
    });

    test('a pickup is never offered "out for delivery"', () {
      final pickup = line(LineStatus.ready, fulfilment: Fulfilment.pickup);
      final delivery = line(LineStatus.ready, fulfilment: Fulfilment.delivery);
      expect(pickup.nextStatuses, isNot(contains(LineStatus.out)));
      expect(pickup.nextStatuses, contains(LineStatus.delivered));
      expect(delivery.nextStatuses, contains(LineStatus.out));
    });

    test('what an item is stays editable until work starts', () {
      expect(LineStatus.created.isEditable, isTrue);
      expect(LineStatus.confirmed.isEditable, isTrue);
      expect(LineStatus.inProduction.isEditable, isFalse,
          reason: 'the tin has been weighed');
      expect(LineStatus.inProduction.hasStarted, isTrue);
      expect(LineStatus.confirmed.hasStarted, isFalse);
    });

    test('the finishing item decides how the order ends', () {
      final lines = [
        line(LineStatus.ready, date: 100, fulfilment: Fulfilment.delivery),
        line(LineStatus.ready, date: 900, fulfilment: Fulfilment.pickup),
      ];
      expect(finishingLine(lines)!.fulfilment, Fulfilment.pickup,
          reason: 'the last one to be handed over is collected');
    });

    test('a status from a newer build is read as not-started, not a crash', () {
      expect(LineStatus.parse('teleported'), LineStatus.created);
    });
  });

  group('the order status is derived', () {
    test('no confirmation yet means created, whatever the lines say', () {
      expect(deriveOrderStatus([line(LineStatus.ready)]), OrderStatus.created);
    });

    test('confirmed while every line is still waiting', () {
      expect(
        deriveOrderStatus([line(LineStatus.confirmed)], confirmedAt: 1),
        OrderStatus.confirmed,
      );
    });

    test('the first item to start puts the order in production', () {
      expect(
        deriveOrderStatus(
          [line(LineStatus.confirmed), line(LineStatus.inProduction)],
          confirmedAt: 1,
        ),
        OrderStatus.inProduction,
        reason: 'one baker has started, so the order has',
      );
    });

    test('the order never reads ready or out', () {
      // Those are facts about one item. An order whose cake is ready while its
      // cookies are still mixing is neither.
      for (final st in [LineStatus.ready, LineStatus.out]) {
        expect(
          deriveOrderStatus(
            [line(LineStatus.confirmed), line(st)],
            confirmedAt: 1,
          ),
          OrderStatus.inProduction,
        );
      }
    });

    test('delivered only when every live line is', () {
      final partly = [line(LineStatus.delivered), line(LineStatus.out)];
      expect(deriveOrderStatus(partly, confirmedAt: 1), OrderStatus.inProduction,
          reason: 'one line still out — the order is not delivered');

      final all = [line(LineStatus.delivered), line(LineStatus.delivered)];
      expect(deriveOrderStatus(all, confirmedAt: 1), OrderStatus.delivered);
    });

    test('a cancelled line does not hold delivery back', () {
      expect(
        deriveOrderStatus(
          [line(LineStatus.delivered), line(LineStatus.cancelled)],
          confirmedAt: 1,
        ),
        OrderStatus.delivered,
      );
    });

    test('every line cancelled cancels the order', () {
      expect(
        deriveOrderStatus([line(LineStatus.cancelled)], confirmedAt: 1),
        OrderStatus.cancelled,
      );
      // and before it was ever confirmed
      expect(deriveOrderStatus([line(LineStatus.cancelled)]),
          OrderStatus.cancelled);
    });

    test('completed is delivered plus the deliberate moment', () {
      final lines = [line(LineStatus.delivered)];
      expect(deriveOrderStatus(lines, confirmedAt: 1), OrderStatus.delivered);
      expect(deriveOrderStatus(lines, confirmedAt: 1, completedAt: 2),
          OrderStatus.completed);
    });
  });

  group('the due date is the LAST line still outstanding', () {
    test('the order is not done until everything has gone', () {
      final lines = [
        line(LineStatus.delivered, date: 900), // done — does not hold it open
        line(LineStatus.ready, date: 300),
        line(LineStatus.inProduction, date: 200),
      ];
      expect(deriveDueDate(lines), 300);
    });

    test('shortens as the far line is delivered', () {
      var lines = [
        line(LineStatus.ready, date: 200),
        line(LineStatus.inProduction, date: 500),
      ];
      expect(deriveDueDate(lines), 500, reason: 'Sunday is when it finishes');

      lines = [
        line(LineStatus.ready, date: 200),
        line(LineStatus.delivered, date: 500),
      ];
      expect(deriveDueDate(lines), 200, reason: 'only Friday left to do');
    });

    test('nothing outstanding has no due date, so it sorts last', () {
      expect(deriveDueDate([line(LineStatus.delivered, date: 100)]), isNull);
      expect(deriveDueDate([line(LineStatus.cancelled, date: 100)]), isNull);
    });

    test('the time is the last one on the finishing day', () {
      final lines = [
        line(LineStatus.ready, date: 100, time: 600),
        line(LineStatus.ready, date: 200, time: 540),
        line(LineStatus.ready, date: 200, time: 900),
      ];
      expect(deriveDueDate(lines), 200);
      expect(deriveDueTime(lines), 900,
          reason: 'the moment the order completes, on the day it completes');
    });
  });

  group('the next line is a separate question', () {
    test('an order spanning two days is due later than it is needed', () {
      final lines = [
        line(LineStatus.inProduction, date: 200), // Friday's cake
        line(LineStatus.inProduction, date: 500), // Sunday's box
      ];
      expect(deriveDueDate(lines), 500, reason: 'it finishes Sunday');
      expect(deriveNextLineDate(lines), 200,
          reason: 'but somebody is baking on Friday');
    });

    test('they agree on a single-day order', () {
      final lines = [line(LineStatus.ready, date: 300)];
      expect(deriveDueDate(lines), deriveNextLineDate(lines));
    });

    test('both ignore what is already done', () {
      final lines = [
        line(LineStatus.delivered, date: 100),
        line(LineStatus.ready, date: 400),
      ];
      expect(deriveNextLineDate(lines), 400);
      expect(deriveDueDate(lines), 400);
    });
  });

  group('money (D27)', () {
    OrderTotals totals(List<OrderLine> lines, {Money paid = Money.zero}) =>
        OrderTotals(lines: lines, paid: paid);

    test('a cancelled line leaves the total', () {
      final t = totals([
        line(LineStatus.delivered, price: 1000),
        line(LineStatus.cancelled, price: 400),
      ]);
      expect(t.subtotal, Money.rupees(1000));
    });

    test('cancelling after payment puts the order in credit', () {
      final t = totals(
        [line(LineStatus.delivered, price: 1000), line(LineStatus.cancelled, price: 400)],
        paid: Money.rupees(1400),
      );
      expect(t.hasBalance, isFalse);
      expect(t.inCredit, isTrue);
      expect(t.creditDue, Money.rupees(400),
          reason: 'owed back to the customer, not a negative balance');
    });

    test('an ordinary part-paid order is not in credit', () {
      final t = totals([line(LineStatus.ready, price: 1000)],
          paid: Money.rupees(400));
      expect(t.inCredit, isFalse);
      expect(t.balanceDue, Money.rupees(600));
    });
  });
}
