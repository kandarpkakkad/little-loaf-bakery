import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/money.dart';
import 'package:little_loaf/domain/orders/model.dart';
import 'package:little_loaf/domain/orders/repository.dart';
import 'package:little_loaf/domain/stock/model.dart';

import '../support/harness.dart';

/// The handful of questions the owner actually asks.
/// docs/02-domain/reporting/lld.md
void main() {
  late AppServicesFixture f;
  late String menuId;
  late String customerId;

  setUp(() async {
    f = await AppServicesFixture.make();
    menuId = await f.services.menu.create(name: 'Cake');
    customerId = await f.services.customers
        .findOrCreate(name: 'Asha', phoneE164: '+919876543210');
  });
  tearDown(() => f.close());

  DraftLine draft(String name, {int price = 500, int qty = 1, String? itemId}) =>
      DraftLine(
        menuItemId: itemId ?? menuId,
        itemName: name,
        basePrice: Money.rupees(price),
        qty: qty,
        deliveryDate: DateTime(2026, 9, 10).millisecondsSinceEpoch,
        fulfilment: Fulfilment.pickup,
      );

  Future<String> order(List<DraftLine> lines) => f.services.orders.create(
        customerId: customerId,
        lines: lines,
        fulfilment: Fulfilment.pickup,
        deliveryDate: DateTime(2026, 9, 10).millisecondsSinceEpoch,
      );

  Future<void> deliverAll(String id) async {
    await f.services.orders.confirm(id);
    final v = await f.services.orders.watchOrder(id).first;
    for (final l in v!.lines) {
      for (final st in const [
        LineStatus.inProduction,
        LineStatus.ready,
        LineStatus.delivered,
      ]) {
        final rows = await f.rows('order_items');
        final now = LineStatus.parse(
            rows.firstWhere((r) => r['id'] == l.id)['status'] as String);
        if (now.canGoTo(st)) await f.services.orders.moveLine(l.id!, st);
      }
    }
  }

  group('sales', () {
    test('an undelivered order is not revenue yet', () async {
      await order([draft('Cake', price: 1000)]);
      expect(await f.services.reports.salesByMonth(), isEmpty,
          reason: 'promised is not sold');
    });

    test('a delivered order counts, billed and collected separately', () async {
      final id = await order([draft('Cake', price: 1000)]);
      await f.services.orders.addPayment(
          orderId: id, amount: Money.rupees(400), kind: 'advance', mode: 'upi');
      await deliverAll(id);

      final months = await f.services.reports.salesByMonth();
      expect(months, hasLength(1));
      expect(months.single.orders, 1);
      expect(months.single.revenue, Money.rupees(1000));
      expect(months.single.collected, Money.rupees(400));
      expect(months.single.outstanding, Money.rupees(600),
          reason: 'the gap between billed and banked is the number worth seeing');
    });

    test('a voided invoice removes the sale', () async {
      final id = await order([draft('Cake', price: 1000)]);
      await deliverAll(id);
      expect(await f.services.reports.salesByMonth(), hasLength(1));

      final inv = (await f.services.invoices.forOrder(id))!;
      await f.services.invoices.voidInvoice(inv.id, 'billed the wrong person');

      expect(await f.services.reports.salesByMonth(), isEmpty,
          reason: 'a voided bill is a sale that did not happen');
    });

    test('a cancelled item is not counted', () async {
      final id = await order([draft('Cake', price: 1000), draft('Buns', price: 400)]);
      await f.services.orders.confirm(id);
      final v = await f.services.orders.watchOrder(id).first;
      await f.services.orders.moveLine(
          v!.lines.firstWhere((l) => l.itemName == 'Buns').id!,
          LineStatus.cancelled,
          reason: 'out of flour');
      await deliverAll(id);

      final months = await f.services.reports.salesByMonth();
      expect(months.single.revenue, Money.rupees(1000));
    });
  });

  group('by product', () {
    test('groups on the id, so a rename does not split the history', () async {
      final id1 = await order([draft('Cake', price: 500, qty: 2)]);
      await deliverAll(id1);

      // the menu item is renamed; the next order snapshots the new name
      await f.services.menu.update(menuId, name: 'Chocolate cake');
      final id2 = await order([draft('Chocolate cake', price: 500)]);
      await deliverAll(id2);

      final rows = await f.services.reports.byProduct();
      expect(rows, hasLength(1), reason: 'one product, not two');
      expect(rows.single.qty, 3);
      expect(rows.single.name, 'Chocolate cake',
          reason: 'reads in todays words, groups on yesterdays id');
    });

    test('sorted by what earns most', () async {
      final other = await f.services.menu.create(name: 'Buns');
      final id = await order([
        draft('Cake', price: 100),
        draft('Buns', price: 900, itemId: other),
      ]);
      await deliverAll(id);

      final rows = await f.services.reports.byProduct();
      expect(rows.first.name, 'Buns');
    });
  });

  group('money owed', () {
    test('outstanding adds up what is still to come', () async {
      final a = await order([draft('Cake', price: 1000)]);
      await f.services.orders.addPayment(
          orderId: a, amount: Money.rupees(400), kind: 'advance', mode: 'upi');
      await order([draft('Buns', price: 300)]);

      expect(await f.services.reports.outstanding(), Money.rupees(900));
    });

    test('credit is counted apart from what is owed', () async {
      final id = await order([draft('Cake', price: 1000), draft('Buns', price: 400)]);
      await f.services.orders.addPayment(
          orderId: id, amount: Money.rupees(1400), kind: 'advance', mode: 'upi');
      final v = await f.services.orders.watchOrder(id).first;
      await f.services.orders.moveLine(
          v!.lines.firstWhere((l) => l.itemName == 'Buns').id!,
          LineStatus.cancelled,
          reason: 'out of flour');

      expect(await f.services.reports.credit(), Money.rupees(400));
      expect(await f.services.reports.outstanding(), Money.zero);
    });
  });

  group('stock value', () {
    test('values the shelf at the last price paid', () async {
      final id = await f.services.stock.createMaterial(
          name: 'Butter', category: 'raw', unit: 'kg', thresholdQty: 1);
      await f.services.stock.addMovement(
          materialId: id,
          kind: StockKind.stockIn,
          qty: 4,
          amount: Money.rupees(2000));

      final rows = await f.services.reports.stockValue();
      final butter = rows.firstWhere((r) => r.name == 'Butter');
      expect(butter.onHand, 4);
      expect(butter.value, Money.rupees(2000));
    });

    test('says it does not know rather than valuing at zero', () async {
      final id = await f.services.stock.createMaterial(
          name: 'Flour', category: 'raw', unit: 'kg', thresholdQty: 1);
      await f.services.stock
          .addMovement(materialId: id, kind: StockKind.count, qty: 10);

      final flour =
          (await f.services.reports.stockValue()).firstWhere((r) => r.name == 'Flour');
      expect(flour.onHand, 10);
      expect(flour.value, isNull);
    });
  });
}
