import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/money.dart';
import 'package:little_loaf/domain/orders/model.dart';

/// The worked example that runs through every document:
/// Chocolate Truffle 1×₹1,450 + Message ₹50 + Candles ₹30, Sourdough 2×₹180
/// subtotal ₹1,890 − discount ₹100 + delivery ₹100 = ₹1,890; paid ₹800 → ₹1,090
OrderTotals _worked({
  DiscountType? type,
  int value = 0,
  Money delivery = const Money(10000),
  Money paid = const Money(80000),
}) =>
    OrderTotals(
      lines: [
        OrderLine(
          menuItemId: 'm1',
          itemName: 'Chocolate Truffle',
          flavour: 'Belgian dark',
          weight: const Weight(1, 'kg'),
          qty: 1,
          basePrice: Money.rupees(1450),
          addons: [
            Addon(name: 'Message on cake', price: Money.rupees(50)),
            Addon(name: 'Candles', price: Money.rupees(30)),
          ],
          // The discount is per item now (D31). The worked example's figures
          // are unchanged — the whole of it simply sits on the cake.
          discountType: type,
          discountValue: value,
        ),
        OrderLine(
          menuItemId: 'm2',
          itemName: 'Sourdough loaf',
          qty: 2,
          basePrice: Money.rupees(180),
        ),
      ],
      deliveryCharge: delivery,
      paid: paid,
    );

void main() {
  group('totals', () {
    test('match the worked example used throughout the docs', () {
      final t = _worked(type: DiscountType.amount, value: 10000);
      expect(t.subtotal, Money.rupees(1890));
      expect(t.discount, Money.rupees(100));
      expect(t.total, Money.rupees(1890));
      expect(t.balanceDue, Money.rupees(1090));
    });

    test('add-ons are priced for the line, not multiplied by quantity', () {
      final line = OrderLine(
        menuItemId: 'm', itemName: 'Cake', qty: 2,
        basePrice: Money.rupees(1000),
        addons: [Addon(name: 'Message', price: Money.rupees(50))],
      );
      expect(line.total, Money.rupees(2050)); // not 2100
    });

    test('a percentage applies to its own item, never to delivery', () {
      // 10% off the CAKE (D31), which is ₹1450 + ₹50 + ₹30 = ₹1530 — its
      // add-ons go with it, because they are part of what was bought. It used
      // to be 10% of the whole ₹1890 basket, which is what changed.
      final t = _worked(type: DiscountType.percent, value: 1000);
      expect(t.discount, Money.rupees(153));
      expect(t.subtotal, Money.rupees(1890), reason: 'list price, undiscounted');
      // ₹1890 − ₹153 + ₹100 delivery. The courier is never discounted, and now
      // by construction: a delivery is not an item, so there is nothing on it
      // to take off.
      expect(t.total, Money.rupees(1837));
    });

    test('a discount larger than its item is clamped to that item', () {
      final t = _worked(type: DiscountType.amount, value: 999999900);
      expect(t.discount, Money.rupees(1530),
          reason: 'the whole cake, and not a paisa of the loaf beside it');
      // The loaf still costs what it costs, and delivery is still owed.
      expect(t.total, Money.rupees(360) + t.deliveryCharge);
      expect(t.total.paise, greaterThan(0));
    });

    test('no discount, no delivery — the rows simply do not exist', () {
      final t = _worked(delivery: Money.zero, paid: Money.zero);
      expect(t.discount.isZero, isTrue);
      expect(t.deliveryCharge.isZero, isTrue);
      expect(t.total, Money.rupees(1890));
      expect(t.balanceDue, Money.rupees(1890));
    });
  });

  group('payment status', () {
    test('is derived across every case', () {
      expect(paymentStatusOf(_worked(paid: Money.zero), cancelled: false),
          PaymentStatus.unpaid);
      expect(paymentStatusOf(_worked(), cancelled: false),
          PaymentStatus.advancePaid);
      // no discount here, so the total is 1890 + 100 delivery = 1990
      expect(paymentStatusOf(_worked(paid: Money.rupees(1990)), cancelled: false),
          PaymentStatus.paid);
      expect(paymentStatusOf(_worked(paid: Money.rupees(2100)), cancelled: false),
          PaymentStatus.paid); // overpaid still reads as paid
      expect(paymentStatusOf(_worked(paid: Money.zero), cancelled: true),
          PaymentStatus.refunded);
    });
  });

  group('lifecycle', () {
    test('allows exactly the documented transitions', () {
      expect(kAllowedTransitions[OrderStatus.created],
          {OrderStatus.confirmed, OrderStatus.cancelled});
      expect(kAllowedTransitions[OrderStatus.delivered], {OrderStatus.completed});
      expect(kAllowedTransitions[OrderStatus.completed], isEmpty);
      expect(kAllowedTransitions[OrderStatus.cancelled], isEmpty);
    });

    test('cannot cancel after handover', () {
      for (final s in [OrderStatus.delivered, OrderStatus.completed]) {
        expect(kAllowedTransitions[s]!.contains(OrderStatus.cancelled), isFalse);
      }
    });

    test('cancel is reachable from every state before delivered', () {
      for (final s in [OrderStatus.created, OrderStatus.confirmed,
                       OrderStatus.inProduction, OrderStatus.ready, OrderStatus.out]) {
        expect(kAllowedTransitions[s]!.contains(OrderStatus.cancelled), isTrue);
      }
    });

    test('an order offers only the moves a person actually makes', () {
      // D26: everything between confirmed and delivered is derived from the
      // items, so it is not something anyone taps. Three moments remain.
      expect(kAllowedTransitions[OrderStatus.created],
          {OrderStatus.confirmed, OrderStatus.cancelled});
      expect(kAllowedTransitions[OrderStatus.delivered],
          {OrderStatus.completed});

      for (final s in [OrderStatus.confirmed, OrderStatus.inProduction,
          OrderStatus.ready, OrderStatus.out]) {
        expect(kAllowedTransitions[s], {OrderStatus.cancelled},
            reason: '$s moves when its items do, not when anyone taps');
      }
    });

    test('nothing forward is reachable by typing it', () {
      for (final to in [OrderStatus.inProduction, OrderStatus.ready,
          OrderStatus.out, OrderStatus.delivered]) {
        for (final from in OrderStatus.values) {
          expect(allowedNext(from), isNot(contains(to)),
              reason: '$to is derived from the items');
        }
      }
    });

    test('wire values round-trip', () {
      for (final s in OrderStatus.values) {
        expect(OrderStatus.parse(s.wire), s);
      }
    });
  });

  test('dietary flags decode', () {
    expect(Dietary.labels(Dietary.eggless | Dietary.nutFree),
        ['Eggless', 'Nut-free']);
    expect(Dietary.labels(0), isEmpty);
  });
}
