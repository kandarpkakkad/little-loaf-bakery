import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/money.dart';
import 'package:little_loaf/domain/invoicing/repository.dart';
import 'package:little_loaf/domain/orders/model.dart';
import 'package:little_loaf/domain/orders/repository.dart';

import '../support/harness.dart';

/// One invoice per order, issued when the last item has gone, frozen at that
/// moment. docs/02-domain/invoicing/lld.md
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

  DraftLine draft(String name, {int date = 1000, int price = 500}) => DraftLine(
        menuItemId: menuId,
        itemName: name,
        basePrice: Money.rupees(price),
        deliveryDate: date,
        fulfilment: Fulfilment.pickup,
      );

  Future<String> order(List<DraftLine> lines,
          {DiscountType? discountType, int discountValue = 0}) =>
      f.services.orders.create(
        customerId: customerId,
        lines: lines,
        fulfilment: Fulfilment.pickup,
        deliveryDate: 1000,
        discountType: discountType,
        discountValue: discountValue,
      );

  Future<OrderView> view(String id) =>
      f.services.orders.watchOrder(id).first.then((v) => v!);

  Future<void> deliver(String lineId) async {
    for (final st in const [
      LineStatus.confirmed,
      LineStatus.inProduction,
      LineStatus.ready,
      LineStatus.delivered,
    ]) {
      final v = await f.rows('order_items');
      final now = LineStatus.parse(
          v.firstWhere((r) => r['id'] == lineId)['status'] as String);
      if (now.canGoTo(st)) await f.services.orders.moveLine(lineId, st);
    }
  }

  test('no invoice until the last item has gone', () async {
    final id = await order([draft('Cake'), draft('Buns')]);
    await f.services.orders.confirm(id);
    var v = await view(id);

    await deliver(v.lines.first.id!);
    expect(await f.services.invoices.forOrder(id), isNull,
        reason: 'one item delivered is not the whole sale');

    v = await view(id);
    await deliver(v.lines.last.id!);
    expect(await f.services.invoices.forOrder(id), isNotNull);
  });

  test('the number carries the financial year and never repeats', () async {
    final a = await order([draft('Cake')]);
    final b = await order([draft('Buns')]);
    await f.services.orders.confirm(a);
    await f.services.orders.confirm(b);

    await deliver((await view(a)).lines.single.id!);
    await deliver((await view(b)).lines.single.id!);

    final one = (await f.services.invoices.forOrder(a))!;
    final two = (await f.services.invoices.forOrder(b))!;
    expect(one.invoiceNo, startsWith('LLB/'));
    expect(one.invoiceNo, isNot(two.invoiceNo));
  });

  test('issuing twice returns the same invoice', () async {
    final id = await order([draft('Cake')]);
    await f.services.orders.confirm(id);
    await deliver((await view(id)).lines.single.id!);

    final first = (await f.services.invoices.forOrder(id))!;
    final again = await f.services.invoices.issue(
      orderId: id,
      lines: (await view(id)).lines,
      totals: (await view(id)).totals,
    );
    expect(again.id, first.id);
    expect((await f.rows('invoices')), hasLength(1));
  });

  test('the totals are frozen, not recomputed', () async {
    final id = await order([draft('Cake', price: 1000), draft('Buns', price: 400)]);
    await f.services.orders.confirm(id);
    for (final l in (await view(id)).lines) {
      await deliver(l.id!);
    }

    final inv = (await f.services.invoices.forOrder(id))!;
    final frozen = FrozenTotals.fromJson(
        jsonDecode(inv.frozenTotalsJson) as Map<String, Object?>);
    expect(frozen.total, Money.rupees(1400));
    expect(frozen.lines, hasLength(2));
    expect(frozen.lines.first.name, 'Cake');

    // the live order can still change; the document cannot
    final v = await view(id);
    expect(v.totals.total, frozen.total);
  });

  test('a percentage discount is resolved to an amount at issue', () async {
    final id = await order(
      [draft('Cake', price: 1000)],
      discountType: DiscountType.percent,
      discountValue: 1000, // 10.00%
    );
    await f.services.orders.confirm(id);
    await deliver((await view(id)).lines.single.id!);

    final inv = (await f.services.invoices.forOrder(id))!;
    final frozen = FrozenTotals.fromJson(
        jsonDecode(inv.frozenTotalsJson) as Map<String, Object?>);
    expect(frozen.discount, Money.rupees(100));
    expect(frozen.discountLabel, 'Discount 10%',
        reason: 'how it was agreed is worth keeping, not just the amount');

    final o = (await f.row('orders', id))!;
    expect(o['discount_amount'], 10000,
        reason: 'resolved on the order too, so adding an item cannot move it');
  });

  test('a cancelled item is not on the bill', () async {
    final id = await order([draft('Cake', price: 1000), draft('Buns', price: 400)]);
    await f.services.orders.confirm(id);
    var v = await view(id);

    await f.services.orders.moveLine(
        v.lines.firstWhere((l) => l.itemName == 'Buns').id!,
        LineStatus.cancelled,
        reason: 'out of flour');
    v = await view(id);
    await deliver(v.lines.firstWhere((l) => l.itemName == 'Cake').id!);

    final inv = (await f.services.invoices.forOrder(id))!;
    final frozen = FrozenTotals.fromJson(
        jsonDecode(inv.frozenTotalsJson) as Map<String, Object?>);
    expect(frozen.lines, hasLength(1));
    expect(frozen.total, Money.rupees(1000));
  });

  test('voiding needs a reason and spends the number', () async {
    final id = await order([draft('Cake')]);
    await f.services.orders.confirm(id);
    await deliver((await view(id)).lines.single.id!);
    final inv = (await f.services.invoices.forOrder(id))!;

    expect(() => f.services.invoices.voidInvoice(inv.id, '  '),
        throwsStateError);

    await f.services.invoices.voidInvoice(inv.id, 'wrong customer');
    final after = (await f.services.invoices.forOrder(id))!;
    expect(after.voidedAt, isNotNull);
    expect(after.voidReason, 'wrong customer');
    expect(after.invoiceNo, inv.invoiceNo,
        reason: 'the number is spent — a gap is explained, a reuse is not');
  });
}
