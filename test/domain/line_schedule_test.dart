import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/money.dart';
import 'package:little_loaf/domain/orders/model.dart';
import 'package:little_loaf/domain/orders/repository.dart';

import '../support/harness.dart';

/// Lines carry their own schedule and status through the database (D25, D26).
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

  DraftLine draft(
    String name, {
    required int date,
    int? time,
    Fulfilment fulfilment = Fulfilment.delivery,
    String? address,
  }) =>
      DraftLine(
        menuItemId: menuId,
        itemName: name,
        basePrice: Money.rupees(500),
        deliveryDate: date,
        deliveryTime: time,
        fulfilment: fulfilment,
        deliveryType:
            fulfilment == Fulfilment.pickup ? null : DeliveryType.local,
        addressText: address,
      );

  Future<String> order(List<DraftLine> lines) => f.services.orders.create(
        customerId: customerId,
        lines: lines,
        deliveryDate: lines.first.deliveryDate!,
      );

  Future<OrderView> view(String id) =>
      f.services.orders.watchOrder(id).first.then((v) => v!);

  /// Walks a line forward one legal step at a time. The lifecycle has real
  /// intermediate states now, and a test that skipped them would be asserting
  /// against a machine that does not exist.
  Future<void> advance(String lineId, LineStatus to) async {
    const order = [
      LineStatus.created,
      LineStatus.confirmed,
      LineStatus.inProduction,
      LineStatus.ready,
      LineStatus.out,
      LineStatus.delivered,
    ];
    for (final step in order.skip(1)) {
      final rows = await f.rows('order_items');
      final now = LineStatus.parse(
          rows.firstWhere((r) => r['id'] == lineId)['status'] as String);
      if (now.index >= to.index) break;
      if (step.index <= now.index) continue;
      // pickup skips 'out'
      if (!now.canGoTo(step)) continue;
      await f.services.orders.moveLine(lineId, step);
      if (step == to) break;
    }
  }

  test('two lines keep two different dates', () async {
    final id = await order([
      draft('Cake', date: 1000, address: '14 Turner Rd'),
      draft('Croissants', date: 5000, fulfilment: Fulfilment.pickup),
    ]);

    final v = await view(id);
    expect(v.lines.map((l) => l.deliveryDate), [1000, 5000]);
    expect(v.lines[0].fulfilment, Fulfilment.delivery);
    expect(v.lines[1].fulfilment, Fulfilment.pickup);
    expect(v.lines[0].addressText, '14 Turner Rd');
    expect(v.lines[1].deliveryType, isNull,
        reason: 'a pickup carries no delivery type');
  });

  test('the order is due when its last outstanding line is', () async {
    final id = await order([
      draft('Cake', date: 5000),
      draft('Croissants', date: 1000),
    ]);
    var v = await view(id);
    expect(v.dueDate, 5000, reason: 'the order is not done until Sunday');
    expect(v.nextLineDate, 1000, reason: 'but Friday still needs a baker');

    // delivering the far one shortens the order
    await f.services.orders.confirm(id);
    final far = v.lines.firstWhere((l) => l.deliveryDate == 5000);
    await advance(far.id!, LineStatus.delivered);

    v = await view(id);
    expect(v.dueDate, 1000, reason: 'only Friday left to do');
  });

  test('the order status follows the lines', () async {
    final id = await order([draft('Cake', date: 1000), draft('Buns', date: 1000)]);
    var v = await view(id);
    expect(v.status, OrderStatus.created, reason: 'not confirmed yet');

    await f.services.orders.confirm(id);
    v = await view(id);
    expect(v.status, OrderStatus.confirmed);

    await f.services.orders
        .moveLine(v.lines.first.id!, LineStatus.inProduction);
    v = await view(id);
    expect(v.status, OrderStatus.inProduction, reason: 'one baker started');

    for (final l in v.lines) {
      await advance(l.id!, LineStatus.delivered);
    }
    v = await view(id);
    expect(v.status, OrderStatus.delivered);
  });

  test('an illegal line move is refused', () async {
    final id = await order([draft('Cake', date: 1000)]);
    final v = await view(id);
    expect(
      () => f.services.orders.moveLine(v.lines.first.id!, LineStatus.delivered),
      throwsStateError,
      reason: 'in_production cannot jump to delivered',
    );
  });

  test('a pickup line is never sent out for delivery', () async {
    final id = await order([
      draft('Croissants', date: 1000, fulfilment: Fulfilment.pickup),
    ]);
    final v = await view(id);
    await f.services.orders.confirm(id);
    await advance(v.lines.first.id!, LineStatus.ready);
    expect(
      () => f.services.orders.moveLine(v.lines.first.id!, LineStatus.out),
      throwsStateError,
    );
  });

  test('cancelling a line needs a reason and drops it from the total',
      () async {
    final id = await order([draft('Cake', date: 1000), draft('Buns', date: 1000)]);
    var v = await view(id);
    expect(v.totals.subtotal, Money.rupees(1000));

    expect(
      () => f.services.orders.moveLine(v.lines.first.id!, LineStatus.cancelled),
      throwsStateError,
      reason: 'a cancellation needs a reason',
    );

    await f.services.orders
        .moveLine(v.lines.first.id!, LineStatus.cancelled, reason: 'out of eggs');
    v = await view(id);
    expect(v.totals.subtotal, Money.rupees(500));
    expect(v.liveLines, hasLength(1));
  });

  test('cancelling after payment leaves the order in credit', () async {
    final id = await order([draft('Cake', date: 1000), draft('Buns', date: 1000)]);
    await f.services.orders.addPayment(
        orderId: id, amount: Money.rupees(1000), kind: 'advance', mode: 'upi');

    var v = await view(id);
    expect(v.totals.balanceDue, Money.zero);

    await f.services.orders
        .moveLine(v.lines.first.id!, LineStatus.cancelled, reason: 'out of eggs');
    v = await view(id);
    expect(v.totals.inCredit, isTrue);
    expect(v.totals.creditDue, Money.rupees(500));
  });

  test('moveAllLines catches up what it legally can', () async {
    final id = await order([
      draft('Cake', date: 1000),
      draft('Buns', date: 1000, fulfilment: Fulfilment.pickup),
    ]);
    await f.services.orders.confirm(id);

    var moved = await f.services.orders.moveAllLines(id, LineStatus.inProduction);
    expect(moved, 2);
    moved = await f.services.orders.moveAllLines(id, LineStatus.ready);
    expect(moved, 2);

    // only the delivery line can go out; the pickup is skipped, not refused
    final outMoved = await f.services.orders.moveAllLines(id, LineStatus.out);
    expect(outMoved, 1);

    final v = await view(id);
    final byName = {for (final l in v.lines) l.itemName: l.status};
    expect(byName['Cake'], LineStatus.out);
    expect(byName['Buns'], LineStatus.ready);
  });

  test("a line created without a date inherits the order's", () async {
    // The order-level values are the defaults a line copies (D25), so a caller
    // that knows nothing about per-line scheduling still produces dated lines.
    final id = await f.services.orders.create(
      customerId: customerId,
      lines: [
        DraftLine(
            menuItemId: menuId, itemName: 'Cake', basePrice: Money.rupees(500))
      ],
      deliveryDate: 4242,
    );
    final v = await view(id);
    expect(v.lines.single.deliveryDate, 4242);
    expect(v.dueDate, 4242);
  });

  test('confirming is refused when a line has no date at all', () async {
    // Reachable only from outside create(): a row migrated from v9, or an op
    // from a peer that predates per-line scheduling.
    final id = await order([draft('Cake', date: 1000)]);
    final v = await view(id);
    await f.services.db.customStatement(
      'UPDATE order_items SET delivery_date = NULL WHERE id = ?',
      [v.lines.single.id],
    );
    expect(() => f.services.orders.confirm(id), throwsStateError);
  });

  test('completing is refused while the order is in credit', () async {
    final id = await order([draft('Cake', date: 1000), draft('Buns', date: 1000)]);
    await f.services.orders.confirm(id);
    await f.services.orders.addPayment(
        orderId: id, amount: Money.rupees(1000), kind: 'advance', mode: 'upi');

    var v = await view(id);
    for (final l in v.lines) {
      if (l.itemName == 'Buns') {
        await f.services.orders
            .moveLine(l.id!, LineStatus.cancelled, reason: 'out of flour');
      } else {
        await advance(l.id!, LineStatus.delivered);
      }
    }
    v = await view(id);
    expect(v.status, OrderStatus.delivered);
    expect(v.totals.inCredit, isTrue);
    expect(() => f.services.orders.complete(id), throwsStateError,
        reason: 'a refund is owed; completed would bury it');
  });

  group('editing a line', () {
    test('moving an item later moves the whole order later', () async {
      final id =
          await order([draft('Cake', date: 1000), draft('Buns', date: 2000)]);
      var v = await view(id);
      expect(v.dueDate, 2000);

      // push the far item out by a week
      final far = v.lines.firstWhere((l) => l.deliveryDate == 2000);
      await f.services.orders.updateLine(far.id!, deliveryDate: 9000);

      v = await view(id);
      expect(v.dueDate, 9000,
          reason: 'derived, so it follows the item without being told');
      expect(v.nextLineDate, 1000, reason: 'the near item did not move');
    });

    test('moving the last item earlier pulls the order in', () async {
      final id =
          await order([draft('Cake', date: 1000), draft('Buns', date: 8000)]);
      var v = await view(id);
      expect(v.dueDate, 8000);

      final far = v.lines.firstWhere((l) => l.deliveryDate == 8000);
      await f.services.orders.updateLine(far.id!, deliveryDate: 1500);

      v = await view(id);
      expect(v.dueDate, 1500);
    });

    test('price and quantity changes reach the total', () async {
      final id = await order([draft('Cake', date: 1000)]);
      var v = await view(id);
      expect(v.totals.subtotal, Money.rupees(500));

      await f.services.orders
          .updateLine(v.lines.first.id!, qty: 3, basePrice: Money.rupees(200));
      v = await view(id);
      expect(v.totals.subtotal, Money.rupees(600));
    });

    test('switching an item to pickup drops its delivery type', () async {
      final id = await order([draft('Cake', date: 1000)]);
      var v = await view(id);
      expect(v.lines.first.deliveryType, DeliveryType.local);

      await f.services.orders
          .updateLine(v.lines.first.id!, fulfilment: Fulfilment.pickup);
      v = await view(id);
      expect(v.lines.first.fulfilment, Fulfilment.pickup);
      expect(v.lines.first.deliveryType, isNull,
          reason: 'a pickup goes nowhere, so it carries no delivery type');
    });

    test('a delivered item cannot be edited', () async {
      final id = await order([draft('Cake', date: 1000)]);
      await f.services.orders.confirm(id);
      final v = await view(id);
      await advance(v.lines.first.id!, LineStatus.delivered);

      expect(
        () => f.services.orders
            .updateLine(v.lines.first.id!, basePrice: Money.rupees(1)),
        throwsStateError,
        reason: 'editing what was handed over rewrites what happened',
      );
    });

    test('an item added later joins the order and its dates', () async {
      final id = await order([draft('Cake', date: 1000)]);
      await f.services.orders.addLine(id, draft('Cookies', date: 7000));

      final v = await view(id);
      expect(v.lines, hasLength(2));
      expect(v.dueDate, 7000);
      expect(v.totals.subtotal, Money.rupees(1000));
    });

    test('an item added to a confirmed order is confirmed with it', () async {
      final id = await order([draft('Cake', date: 1000)]);
      await f.services.orders.confirm(id);

      await f.services.orders.addLine(id, draft('Cookies', date: 1000));

      final v = await view(id);
      final added = v.lines.firstWhere((l) => l.itemName == 'Cookies');
      expect(added.status, LineStatus.confirmed,
          reason: 'it arrived through the same conversation');
      expect(v.status, OrderStatus.confirmed,
          reason: 'the order must not look unconfirmed again');
    });

    test('an item added before confirmation is only created', () async {
      final id = await order([draft('Cake', date: 1000)]);
      await f.services.orders.addLine(id, draft('Cookies', date: 1000));

      final v = await view(id);
      expect(v.lines.firstWhere((l) => l.itemName == 'Cookies').status,
          LineStatus.created);
      expect(v.status, OrderStatus.created);
    });

    test('an item added while the order is in production is still confirmed',
        () async {
      final id = await order([draft('Cake', date: 1000)]);
      await f.services.orders.confirm(id);
      var v = await view(id);
      await f.services.orders
          .moveLine(v.lines.first.id!, LineStatus.inProduction);

      await f.services.orders.addLine(id, draft('Cookies', date: 1000));
      v = await view(id);
      final added = v.lines.firstWhere((l) => l.itemName == 'Cookies');
      expect(added.status, LineStatus.confirmed,
          reason: 'agreed, but nobody has started it');
      expect(added.status.isEditable, isTrue);
    });
  });

  group('what an item is, once work has started', () {
    Future<String> started(String id) async {
      await f.services.orders.confirm(id);
      final v = await view(id);
      final lineId = v.lines.first.id!;
      await f.services.orders.moveLine(lineId, LineStatus.inProduction);
      return lineId;
    }

    test('flavour, weight, quantity and price all lock', () async {
      final id = await order([draft('Cake', date: 1000)]);
      final lineId = await started(id);

      for (final change in [
        () => f.services.orders.updateLine(lineId, flavour: 'Vanilla'),
        () => f.services.orders
            .updateLine(lineId, weight: const Weight(2, 'kg')),
        () => f.services.orders.updateLine(lineId, qty: 5),
        () => f.services.orders
            .updateLine(lineId, basePrice: Money.rupees(999)),
      ]) {
        expect(change, throwsStateError,
            reason: 'the tin has been weighed; this is already half-made');
      }
    });

    test('when and where it goes still change — a van can be redirected',
        () async {
      final id = await order([draft('Cake', date: 1000)]);
      final lineId = await started(id);

      await f.services.orders.updateLine(
        lineId,
        deliveryDate: 6000,
        deliveryTime: 1020,
        addressText: 'The office',
      );

      final v = await view(id);
      final l = v.lines.single;
      expect(l.deliveryDate, 6000);
      expect(l.deliveryTime, 1020);
      expect(l.addressText, 'The office');
      expect(v.dueDate, 6000, reason: 'and the order follows it');
    });

    test('an item nobody has started is still fully editable', () async {
      final id =
          await order([draft('Cake', date: 1000), draft('Buns', date: 1000)]);
      await f.services.orders.confirm(id);
      var v = await view(id);

      // start one of them
      await f.services.orders
          .moveLine(v.lines.first.id!, LineStatus.inProduction);
      v = await view(id);
      expect(v.status, OrderStatus.inProduction);

      // the other is untouched, so it can still change entirely
      final untouched = v.lines.firstWhere((l) => l.itemName == 'Buns');
      await f.services.orders
          .updateLine(untouched.id!, flavour: 'Cinnamon', qty: 4);

      v = await view(id);
      final buns = v.lines.firstWhere((l) => l.itemName == 'Buns');
      expect(buns.flavour, 'Cinnamon');
      expect(buns.qty, 4,
          reason: 'the order being in production does not lock an item '
              'nobody has started');
    });

    test('confirming the order confirms its items', () async {
      final id = await order([draft('Cake', date: 1000)]);
      var v = await view(id);
      expect(v.lines.single.status, LineStatus.created);
      expect(v.lines.single.status.isEditable, isTrue);

      await f.services.orders.confirm(id);
      v = await view(id);
      expect(v.lines.single.status, LineStatus.confirmed);
      expect(v.lines.single.status.isEditable, isTrue,
          reason: 'agreed with the customer, but nothing is in the oven');
    });
  });
}
