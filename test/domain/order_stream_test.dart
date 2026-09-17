import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/money.dart';
import 'package:little_loaf/domain/orders/model.dart';
import 'package:little_loaf/domain/orders/repository.dart';

import '../support/harness.dart';

/// The order screens are built from these streams, and the totals they show are
/// assembled from tables the underlying query never names. Drift only re-runs a
/// query when a table *in it* changes, so without an explicit trigger a payment
/// was recorded and the balance on screen never moved.
void main() {
  late AppServicesFixture f;
  late String orderId;

  setUp(() async {
    f = await AppServicesFixture.make();
    final menu = await f.services.menu.create(name: 'Cake');
    final cust = await f.services.customers
        .findOrCreate(name: 'Asha', phoneE164: '+919876543210');
    orderId = await f.services.orders.create(
      customerId: cust,
      lines: [
        DraftLine(
            menuItemId: menu, itemName: 'Cake', basePrice: Money.rupees(1000))
      ],
      fulfilment: Fulfilment.pickup,
      deliveryDate: DateTime(2026, 9, 20).millisecondsSinceEpoch,
    );
  });

  tearDown(() => f.close());

  test('taking a payment moves the balance on the detail stream', () async {
    final seen = <int>[];
    final sub = f.services.orders
        .watchOrder(orderId)
        .listen((v) => seen.add(v!.totals.balanceDue.paise));
    await Future<void>.delayed(const Duration(milliseconds: 80));

    await f.services.orders.addPayment(
        orderId: orderId, amount: Money.rupees(400), kind: 'advance', mode: 'upi');
    await Future<void>.delayed(const Duration(milliseconds: 200));

    await sub.cancel();
    expect(seen.first, 100000);
    expect(seen.last, 60000,
        reason: 'the balance must fall without anything touching `orders`');
  });

  test('the list stream moves too', () async {
    final seen = <int>[];
    final sub = f.services.orders.watchOrders().listen(
        (rows) => seen.add(rows.single.totals.balanceDue.paise));
    await Future<void>.delayed(const Duration(milliseconds: 80));

    await f.services.orders.addPayment(
        orderId: orderId, amount: Money.rupees(250), kind: 'advance', mode: 'cash');
    await Future<void>.delayed(const Duration(milliseconds: 200));

    await sub.cancel();
    expect(seen.last, 75000);
  });

  test('instalments each move the balance', () async {
    final orders = f.services.orders;
    for (final (paid, expected) in [(400, 60000), (300, 30000), (300, 0)]) {
      await orders.addPayment(
          orderId: orderId,
          amount: Money.rupees(paid),
          kind: 'balance',
          mode: 'upi');
      final view = await orders.watchOrder(orderId).first;
      expect(view!.totals.balanceDue.paise, expected);
    }
    final view = await orders.watchOrder(orderId).first;
    expect(view!.totals.hasBalance, isFalse);
  });
}
