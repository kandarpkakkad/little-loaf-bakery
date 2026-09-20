import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/money.dart';
import 'package:little_loaf/domain/orders/model.dart';
import 'package:little_loaf/domain/orders/repository.dart';

import '../support/harness.dart';

/// Editing an order after it was taken, and taking payment in instalments.
void main() {
  late AppServicesFixture f;
  late String orderId;

  setUp(() async {
    f = await AppServicesFixture.make();
    final menu = await f.services.menu.create(name: 'Cake');
    final customer = await f.services.customers
        .findOrCreate(name: 'Asha', phoneE164: '+919876543210');
    orderId = await f.services.orders.create(
      customerId: customer,
      lines: [
        DraftLine(
            menuItemId: menu, itemName: 'Cake', basePrice: Money.rupees(1000))
      ],
      fulfilment: Fulfilment.delivery,
      deliveryType: DeliveryType.local,
      addressText: '14 Turner Rd',
      deliveryDate: DateTime(2026, 9, 20).millisecondsSinceEpoch,
      deliveryTime: 600,
      deliveryCharge: Money.rupees(50),
      itemMessage: 'Happy birthday',
      requirements: 'no fondant',
    );
  });

  tearDown(() => f.close());

  Future<Map<String, Object?>> order() async =>
      (await f.row('orders', orderId))!;

  test('the charge can change', () async {
    await f.services.orders
        .updateDetails(orderId, deliveryCharge: Money.rupees(80));
    expect((await order())['delivery_charge'], 8000);
  });

  test('the delivery date is not something this can change', () async {
    // The order is due when its last item is (D25), so the column is a copy of
    // that derivation. updateDetails has no date parameter at all — the
    // compiler enforces it; this records why.
    final before = (await order())['delivery_date'];
    await f.services.orders
        .updateDetails(orderId, deliveryCharge: Money.rupees(80));
    expect((await order())['delivery_date'], before,
        reason: 'editing the order cannot move its date');
  });

  test('the items, message and requirements are never touched', () async {
    await f.services.orders
        .updateDetails(orderId, deliveryCharge: Money.rupees(80));
    final o = await order();
    expect(o['item_message'], 'Happy birthday');
    expect(o['requirements'], 'no fondant');
    expect(await f.rows('order_items'), hasLength(1));
  });

  test('switching to pickup clears what only a delivery can have', () async {
    await f.services.orders
        .updateDetails(orderId, fulfilment: Fulfilment.pickup);
    final o = await order();
    expect(o['fulfilment'], 'pickup');
    // the schema CHECK forbids a pickup keeping these
    expect(o['delivery_type'], isNull);
    expect(o['tracking_url'], isNull);
  });

  test('an address can be cleared, not just replaced', () async {
    await f.services.orders.updateDetails(orderId, addressText: null);
    expect((await order())['address_text'], isNull);
  });

  test('untouched fields stay untouched', () async {
    await f.services.orders.updateDetails(orderId, dietaryFlags: 2);
    final o = await order();
    expect(o['address_text'], '14 Turner Rd',
        reason: 'not passed, so not changed');
    expect(o['delivery_charge'], 5000);
  });

  test('the whole edit travels as one op', () async {
    final before = (await f.rows('outbox')).length;
    await f.services.orders.updateDetails(
      orderId,
      deliveryCharge: Money.rupees(70),
      dietaryFlags: 1,
    );
    expect((await f.rows('outbox')).length, before + 1,
        reason: 'one op, so a peer can never see half the edit');
  });

  test('payment can arrive in instalments', () async {
    final orders = f.services.orders;
    // ₹1000 + ₹50 delivery
    await orders.addPayment(
        orderId: orderId, amount: Money.rupees(400), kind: 'advance', mode: 'upi');
    var view = await orders.watchOrder(orderId).first;
    expect(view!.totals.paid, Money.rupees(400));
    expect(view.totals.balanceDue, Money.rupees(650));
    expect(view.totals.hasBalance, isTrue);

    await orders.addPayment(
        orderId: orderId, amount: Money.rupees(300), kind: 'balance', mode: 'cash');
    view = await orders.watchOrder(orderId).first;
    expect(view!.totals.paid, Money.rupees(700));
    expect(view.totals.balanceDue, Money.rupees(350),
        reason: 'a second partial payment adds, it does not replace');

    await orders.addPayment(
        orderId: orderId, amount: Money.rupees(350), kind: 'balance', mode: 'cash');
    view = await orders.watchOrder(orderId).first;
    expect(view!.totals.balanceDue, Money.zero);
    expect(view.totals.hasBalance, isFalse);
  });

  test('a locked message is left alone, not cleared', () async {
    // kUnchanged is what a form passes for a field it did not render
    await f.services.orders
        .updateDetails(orderId, itemMessage: kUnchanged, dietaryFlags: 2);
    expect((await order())['item_message'], 'Happy birthday',
        reason: 'passing null here would have wiped it');
  });

  test('the message can be changed, and cleared on purpose', () async {
    await f.services.orders.updateDetails(orderId, itemMessage: 'Happy 40th');
    expect((await order())['item_message'], 'Happy 40th');

    await f.services.orders.updateDetails(orderId, itemMessage: null);
    expect((await order())['item_message'], isNull);
  });

  group('status flow', () {
    // The pickup-skips-"out" rule moved down to the item with the fulfilment
    // (D25), and an order no longer has ready or out at all (D26). What is
    // left at order level is the three moments a person decides.
    test('an order is confirmed by confirming it, items and all', () async {
      final orders = f.services.orders;
      await orders.moveTo(orderId, OrderStatus.confirmed);

      final v = await orders.watchOrder(orderId).first;
      expect(v!.status, OrderStatus.confirmed,
          reason: 'the status every screen reads is derived from the items');
      expect(v.lines.every((l) => l.status == LineStatus.confirmed), isTrue,
          reason: 'confirming an order is what confirms its items');
      expect((await order())['confirmed_at'], isNotNull);
    });

    test('confirming twice is refused by the derived status', () async {
      final orders = f.services.orders;
      await orders.moveTo(orderId, OrderStatus.confirmed);
      expect(() => orders.moveTo(orderId, OrderStatus.confirmed),
          throwsStateError);
    });

    test('an order cannot be walked forward by hand', () async {
      final orders = f.services.orders;
      await orders.moveTo(orderId, OrderStatus.confirmed);
      for (final to in [OrderStatus.inProduction, OrderStatus.ready,
          OrderStatus.out, OrderStatus.delivered]) {
        expect(() => orders.moveTo(orderId, to), throwsStateError,
            reason: '$to follows the items; it is not a button');
      }
    });

    test('a pickup is handed over by moving its item', () async {
      final orders = f.services.orders;
      await orders.moveTo(orderId, OrderStatus.confirmed);
      var v = await orders.watchOrder(orderId).first;

      for (final l in v!.lines) {
        await orders.updateLine(l.id!, fulfilment: Fulfilment.pickup);
        for (final st in const [LineStatus.inProduction, LineStatus.ready,
            LineStatus.delivered]) {
          await orders.moveLine(l.id!, st);
        }
      }

      v = await orders.watchOrder(orderId).first;
      expect(v!.status, OrderStatus.delivered);
      expect((await order())['status'], 'delivered',
          reason: 'the column is a cache of the derived value');
    });

    test('a pickup item still cannot go out for delivery', () async {
      final orders = f.services.orders;
      await orders.moveTo(orderId, OrderStatus.confirmed);
      final v = await orders.watchOrder(orderId).first;
      final l = v!.lines.first;
      await orders.updateLine(l.id!, fulfilment: Fulfilment.pickup);
      await orders.moveLine(l.id!, LineStatus.inProduction);
      await orders.moveLine(l.id!, LineStatus.ready);

      expect(() => orders.moveLine(l.id!, LineStatus.out), throwsStateError,
          reason: 'nobody is taking a pickup anywhere');
    });
  });

  group('what may still be edited', () {
    test('details are editable until the order leaves', () {
      for (final s in [OrderStatus.created, OrderStatus.confirmed,
                       OrderStatus.inProduction, OrderStatus.ready]) {
        expect(canEditOrder(s), isTrue, reason: '$s should be editable');
      }
      for (final s in [OrderStatus.out, OrderStatus.delivered,
                       OrderStatus.completed, OrderStatus.cancelled]) {
        expect(canEditOrder(s), isFalse, reason: '$s should be locked');
      }
    });

    test('the message locks one step earlier, at ready', () {
      expect(canEditItemMessage(OrderStatus.inProduction), isTrue);
      expect(canEditItemMessage(OrderStatus.ready), isFalse,
          reason: 'by then it has been piped on');
      expect(canEditOrder(OrderStatus.ready), isTrue,
          reason: 'but the rest of the order is still editable');
    });
  });
}
