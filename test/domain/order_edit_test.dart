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

  test('the date, time and charge can all change', () async {
    await f.services.orders.updateDetails(
      orderId,
      deliveryDate: DateTime(2026, 9, 25).millisecondsSinceEpoch,
      deliveryTime: 1020,
      deliveryCharge: Money.rupees(80),
    );
    final o = await order();
    expect(o['delivery_date'], DateTime(2026, 9, 25).millisecondsSinceEpoch);
    expect(o['delivery_time'], 1020);
    expect(o['delivery_charge'], 8000);
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
    await f.services.orders.updateDetails(orderId, deliveryTime: 900);
    final o = await order();
    expect(o['address_text'], '14 Turner Rd',
        reason: 'not passed, so not changed');
    expect(o['delivery_charge'], 5000);
  });

  test('the whole edit travels as one op', () async {
    final before = (await f.rows('outbox')).length;
    await f.services.orders.updateDetails(
      orderId,
      deliveryTime: 900,
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
        .updateDetails(orderId, itemMessage: kUnchanged, deliveryTime: 900);
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
    test('a delivery goes out before it is delivered', () {
      expect(allowedNext(OrderStatus.ready, isPickup: false),
          contains(OrderStatus.out));
      expect(allowedNext(OrderStatus.ready, isPickup: false),
          isNot(contains(OrderStatus.delivered)));
    });

    test('a pickup skips out-for-delivery entirely', () {
      final next = allowedNext(OrderStatus.ready, isPickup: true);
      expect(next, contains(OrderStatus.delivered));
      expect(next, isNot(contains(OrderStatus.out)),
          reason: 'nobody is taking a pickup anywhere');
    });

    test('a pickup can be handed over straight from ready', () async {
      await f.services.orders
          .updateDetails(orderId, fulfilment: Fulfilment.pickup);
      final orders = f.services.orders;
      await orders.moveTo(orderId, OrderStatus.confirmed);
      await orders.moveTo(orderId, OrderStatus.inProduction);
      await orders.moveTo(orderId, OrderStatus.ready);
      await orders.moveTo(orderId, OrderStatus.delivered);
      expect((await order())['status'], 'delivered');
    });

    test('a delivery still cannot skip out', () async {
      final orders = f.services.orders;
      await orders.moveTo(orderId, OrderStatus.confirmed);
      await orders.moveTo(orderId, OrderStatus.inProduction);
      await orders.moveTo(orderId, OrderStatus.ready);
      expect(() => orders.moveTo(orderId, OrderStatus.delivered),
          throwsStateError);
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
