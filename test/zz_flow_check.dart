// TEMPORARY — a verification harness, not a test to keep.
// Walks every flow through the real schema and pumps every screen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/money.dart';
import 'package:little_loaf/domain/messaging/compose.dart';
import 'package:little_loaf/domain/orders/model.dart';
import 'package:little_loaf/domain/orders/repository.dart';
import 'package:little_loaf/ui/screens/config/reports_screen.dart';
import 'package:little_loaf/ui/screens/kitchen/kitchen_screen.dart';
import 'package:little_loaf/ui/screens/more_screen.dart';
import 'package:little_loaf/ui/screens/orders/new_order_screen.dart';
import 'package:little_loaf/ui/screens/orders/order_detail_screen.dart';
import 'package:little_loaf/ui/screens/orders/orders_screen.dart';
import 'package:little_loaf/ui/screens/stock/stock_screen.dart';
import 'package:little_loaf/ui/shell/shell.dart';

import 'support/harness.dart';

void main() {
  late AppServicesFixture f;
  late String menuId;
  late String customerId;

  final friday = dayAfter(4);
  final sunday = dayAfter(6);

  setUp(() async {
    f = await AppServicesFixture.make();
    menuId = await f.services.menu.create(name: 'Cake');
    customerId = await f.services.customers
        .findOrCreate(name: 'Asha', phoneE164: '+919876543210');
  });
  tearDown(() => f.close());

  DraftLine draft(String name,
          {required int date,
          int? time,
          Fulfilment fulfilment = Fulfilment.delivery,
          String? address = '14 Turner Rd',
          int charge = 5000,
          int price = 500}) =>
      DraftLine(
        menuItemId: menuId,
        itemName: name,
        basePrice: Money.rupees(price),
        deliveryDate: date,
        deliveryTime: time,
        fulfilment: fulfilment,
        deliveryType:
            fulfilment == Fulfilment.pickup ? null : DeliveryType.local,
        addressText: fulfilment == Fulfilment.pickup ? null : address,
        deliveryCharge:
            fulfilment == Fulfilment.pickup ? Money.zero : Money(charge),
      );

  Future<OrderView> view(String id) =>
      f.services.orders.watchOrder(id).first.then((v) => v!);

  test('FLOW: three items become two journeys, charged twice', () async {
    final id = await f.services.orders.create(
      customerId: customerId,
      lines: [
        draft('Cake', date: friday, time: 600),
        draft('Buns', date: friday, time: 600), // same trip
        draft('Focaccia', date: sunday, time: 600), // its own
      ],
      deliveryDate: friday,
    );

    final v = await view(id);
    expect(v.subOrders, hasLength(2));
    expect(v.subOrders.map((s) => s.seq), [1, 2]);
    expect(v.subOrders[0].lines, hasLength(2));
    expect(v.subOrders[1].lines, hasLength(1));
    expect(v.totals.deliveryCharge, Money.rupees(100), reason: 'two trips');
    expect(v.totals.total, Money.rupees(1500 + 100));
    expect(v.dueDate, sunday);
    expect(v.nextDate, friday);
    expect(v.status, OrderStatus.created);
  });

  test('FLOW: confirm → bake → send out → delivered', () async {
    final id = await f.services.orders.create(
      customerId: customerId,
      lines: [
        draft('Cake', date: friday, time: 600),
        draft('Buns', date: friday, time: 600),
      ],
      deliveryDate: friday,
    );

    await f.services.orders.moveTo(id, OrderStatus.confirmed);
    var v = await view(id);
    expect(v.status, OrderStatus.confirmed);
    expect(v.subOrders.single.status, SubOrderStatus.confirmed);
    expect(v.lines.every((l) => l.status == LineStatus.confirmed), isTrue);

    // kitchen bakes each item
    for (final l in v.lines) {
      await f.services.orders.moveLine(l.id!, LineStatus.inProduction);
    }
    v = await view(id);
    expect(v.subOrders.single.status, SubOrderStatus.inProduction);
    expect(v.status, OrderStatus.inProduction);

    await f.services.orders.moveLine(v.lines.first.id!, LineStatus.ready);
    v = await view(id);
    expect(v.subOrders.single.status, SubOrderStatus.inProduction,
        reason: 'one still in the oven holds the van');

    await f.services.orders.moveLine(v.lines.last.id!, LineStatus.ready);
    v = await view(id);
    expect(v.subOrders.single.status, SubOrderStatus.ready);
    expect(v.status, OrderStatus.inProduction, reason: 'no ready at order level');

    final sub = v.subOrders.single;
    await f.services.orders.moveSubOrder(sub.id, SubOrderStatus.out);
    v = await view(id);
    expect(v.subOrders.single.status, SubOrderStatus.out);

    await f.services.orders.moveSubOrder(sub.id, SubOrderStatus.delivered);
    v = await view(id);
    expect(v.status, OrderStatus.delivered);
    expect(v.lines.every((l) => l.status == LineStatus.delivered), isTrue,
        reason: 'travelled together, arrived together');
    // completing needs the money
    expect(() => f.services.orders.complete(id), throwsStateError);
    await f.services.orders.addPayment(
        orderId: id,
        amount: v.totals.balanceDue,
        kind: 'balance',
        mode: 'cash');
    await f.services.orders.complete(id);
    expect((await view(id)).status, OrderStatus.completed);
  });

  test('FLOW: a pickup skips out for delivery', () async {
    final id = await f.services.orders.create(
      customerId: customerId,
      lines: [draft('Buns', date: friday, fulfilment: Fulfilment.pickup)],
      deliveryDate: friday,
    );
    await f.services.orders.confirm(id);
    var v = await view(id);
    await f.services.orders.moveLine(v.lines.single.id!, LineStatus.inProduction);
    await f.services.orders.moveLine(v.lines.single.id!, LineStatus.ready);

    v = await view(id);
    expect(v.subOrders.single.status.nextFor(isPickup: true),
        SubOrderStatus.delivered);
    expect(v.totals.deliveryCharge, Money.zero, reason: 'nobody drives it');

    await f.services.orders
        .moveSubOrder(v.subOrders.single.id, SubOrderStatus.delivered);
    expect((await view(id)).status, OrderStatus.delivered);
  });

  test('FLOW: moving an item to another day re-groups and re-prices', () async {
    final id = await f.services.orders.create(
      customerId: customerId,
      lines: [
        draft('Cake', date: friday, time: 600),
        draft('Buns', date: friday, time: 600),
      ],
      deliveryDate: friday,
    );
    var v = await view(id);
    expect(v.subOrders, hasLength(1));
    expect(v.totals.deliveryCharge, Money.rupees(50));

    await f.services.orders
        .updateLine(v.lines.last.id!, deliveryDate: sunday);
    v = await view(id);
    expect(v.subOrders, hasLength(2), reason: 'it opened its own trip');
    expect(v.subOrders.map((s) => s.seq), [1, 2]);
    expect(v.totals.deliveryCharge, Money.rupees(100));

    // and back again — the emptied trip is pruned, its number spent
    await f.services.orders
        .updateLine(v.lines.last.id!, deliveryDate: friday, deliveryTime: 600);
    v = await view(id);
    expect(v.subOrders, hasLength(1), reason: 'the empty trip went');
    expect(v.totals.deliveryCharge, Money.rupees(50));
  });

  test('FLOW: cancelling an item, then the whole order', () async {
    final id = await f.services.orders.create(
      customerId: customerId,
      lines: [
        draft('Cake', date: friday, time: 600),
        draft('Buns', date: sunday, time: 600),
      ],
      deliveryDate: friday,
    );
    await f.services.orders.confirm(id);
    var v = await view(id);

    await f.services.orders.moveLine(
        v.subOrders.last.lines.single.id!, LineStatus.cancelled,
        reason: 'out of flour');
    v = await view(id);
    expect(v.subOrders.last.status, SubOrderStatus.cancelled);
    expect(v.totals.deliveryCharge, Money.rupees(50),
        reason: 'a cancelled trip costs nothing');
    expect(v.status, OrderStatus.confirmed);

    await f.services.orders
        .moveTo(id, OrderStatus.cancelled, reason: 'customer rang back');
    v = await view(id);
    expect(v.status, OrderStatus.cancelled);
    expect(v.lines.every((l) => !l.isLive), isTrue);
  });

  test('FLOW: the delivery message names only that journey', () async {
    final id = await f.services.orders.create(
      customerId: customerId,
      lines: [
        draft('Cake', date: friday, time: 600),
        draft('Buns', date: friday, time: 600),
        draft('Focaccia', date: sunday, time: 600),
      ],
      deliveryDate: friday,
    );
    await f.services.orders.confirm(id);
    final v = await view(id);
    final fridayTrip = v.subOrders.first;

    final msg = compose(
      MessageKind.delivery,
      MessageContext(
        customerFirstName: 'Asha',
        orderNo: v.order.orderNo,
        businessName: 'Little Loaf',
        lines: v.lines,
        dropLines: fridayTrip.lines,
        totals: v.totals,
        deliveryDateLabel: 'Fri 25 Sep',
        deliveryTimeLabel: '10:00 am',
      ),
    );

    expect(msg, contains('Cake'));
    expect(msg, contains('Buns'));
    expect(msg, contains('Focaccia'),
        reason: 'named as still to come, not as delivered');
    expect(msg, contains('Still to come'));
    expect(msg, isNot(contains('null')));
    expect(msg, isNot(contains('Instance of')));
    // The journey's own reference, e.g. LLB-0001-KPAA-1, must not appear.
    for (final sub in v.subOrders) {
      expect(msg, isNot(contains(sub.reference(v.order.orderNo))),
          reason: "the sub-order reference is the bakery's, not the customer's");
    }
  });

  testWidgets('FLOW: every screen builds without throwing', (tester) async {
    final services = await testServices(tester: tester);
    final menu = await services.menu.create(name: 'Cake');
    final cust = await services.customers
        .findOrCreate(name: 'Asha', phoneE164: '+919876543210');

    final id = await services.orders.create(
      customerId: cust,
      lines: [
        DraftLine(
            menuItemId: menu,
            itemName: 'Cake',
            basePrice: Money.rupees(500),
            deliveryDate: friday,
            deliveryTime: 600,
            fulfilment: Fulfilment.delivery,
            deliveryType: DeliveryType.local,
            addressText: '14 Turner Rd',
            deliveryCharge: Money.rupees(50)),
        DraftLine(
            menuItemId: menu,
            itemName: 'Focaccia',
            basePrice: Money.rupees(300),
            deliveryDate: sunday,
            fulfilment: Fulfilment.pickup),
      ],
      deliveryDate: friday,
    );
    await services.orders.confirm(id);
    await services.stock.createMaterial(
        name: 'Flour', category: 'raw', unit: 'kg', thresholdQty: 1);

    final screens = <String, Widget>{
      'Shell': const AppShell(),
      'Orders': const OrdersScreen(),
      'Kitchen': const KitchenScreen(),
      'Stock': const StockScreen(),
      'More': const MoreScreen(),
      'Reports': const ReportsScreen(),
      'New order': const NewOrderScreen(),
      'Order detail': OrderDetailScreen(orderId: id),
    };

    for (final e in screens.entries) {
      await tester.pumpWidget(wrapped(services, e.value));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '${e.key} threw');
    }
    await drain(tester);
  });

  testWidgets('FLOW: take an order through the UI, end to end', (tester) async {
    final services = await testServices(tester: tester);
    await services.menu.create(name: 'Cake');

    await tester.pumpWidget(wrapped(services, const NewOrderScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Name *'), 'Asha');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'WhatsApp number *'), '9876543210');
    await tester.pumpAndSettle();

    // add an item
    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'the item sheet threw');

    // the sheet must offer what an item needs, and nothing that moved off it
    expect(find.text('Item *'), findsOneWidget);
    expect(find.text('Message on the item'), findsOneWidget,
        reason: 'per item now');
    expect(find.text('Special requirements'), findsOneWidget);
    expect(find.text('Delivery charge'), findsOneWidget,
        reason: 'the field that was missing entirely');
    expect(find.text('A different date or place'), findsNothing,
        reason: 'nothing above it yet, so there is no journey to join');

    await drain(tester);
  });

  testWidgets('FLOW: a second item is offered the first one\'s journey',
      (tester) async {
    final services = await testServices(tester: tester);
    final menu = await services.menu.create(name: 'Cake');
    final cust = await services.customers
        .findOrCreate(name: 'Asha', phoneE164: '+919876543210');

    final id = await services.orders.create(
      customerId: cust,
      lines: [
        DraftLine(
            menuItemId: menu,
            itemName: 'Cake',
            basePrice: Money.rupees(500),
            deliveryDate: friday,
            deliveryTime: 600,
            fulfilment: Fulfilment.delivery,
            deliveryType: DeliveryType.local,
            addressText: '14 Turner Rd',
            deliveryCharge: Money.rupees(50)),
      ],
      deliveryDate: friday,
    );

    await tester.pumpWidget(wrapped(services, OrderDetailScreen(orderId: id)));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Add item'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Drag the sheet up until when-and-where is on screen.
    for (var i = 0; i < 10; i++) {
      if (find.text('A different date or place').evaluate().isNotEmpty) break;
      await tester.drag(
          find.byType(TextFormField).last, const Offset(0, -240),
          warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    // the existing journey is offered by name, which is what lets a later item
    // join the FIRST item's trip rather than only the one above it
    expect(find.text('A different date or place'), findsOneWidget);
    expect(find.textContaining('14 Turner Rd'), findsWidgets,
        reason: 'the journey already on this order, offered to join');

    await drain(tester);
  });

  testWidgets('FLOW: the kitchen shows a journey with its items',
      (tester) async {
    final services = await testServices(tester: tester);
    final menu = await services.menu.create(name: 'Cake');
    final cust = await services.customers
        .findOrCreate(name: 'Asha', phoneE164: '+919876543210');

    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day)
        .millisecondsSinceEpoch;

    final id = await services.orders.create(
      customerId: cust,
      lines: [
        for (final n in ['Cake', 'Buns'])
          DraftLine(
              menuItemId: menu,
              itemName: n,
              basePrice: Money.rupees(500),
              deliveryDate: day,
              deliveryTime: 600,
              fulfilment: Fulfilment.delivery,
              deliveryType: DeliveryType.local,
              addressText: '14 Turner Rd',
              deliveryCharge: Money.rupees(50)),
      ],
      deliveryDate: day,
    );
    await services.orders.confirm(id);

    await tester.pumpWidget(wrapped(services, const KitchenScreen()));
    await tester.pumpAndSettle();

    final v = await services.orders.watchOrder(id).first;
    expect(find.text(v!.subOrders.single.reference(v.order.orderNo)),
        findsOneWidget, reason: 'the kitchen calls it by name');
    expect(find.text('Cake'), findsWidgets);
    expect(find.text('Buns'), findsWidgets);
    expect(find.text('Start'), findsNWidgets(2),
        reason: 'each item is baked on its own');
    expect(tester.takeException(), isNull);
    await drain(tester);
  });
}
