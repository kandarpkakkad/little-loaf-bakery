import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/money.dart';
import 'package:little_loaf/domain/orders/model.dart';
import 'package:little_loaf/domain/orders/repository.dart';
import 'package:little_loaf/ui/screens/orders/order_detail_screen.dart';

import '../support/harness.dart';

/// Advancing an item from the screen.
///
/// Baking is per item; handing over is per drop. The button says which it is
/// about to do, because "Delivered (2)" and "Delivered" are different promises.
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

  DraftLine draft(String name,
          {required int date,
          int? time,
          Fulfilment fulfilment = Fulfilment.delivery,
          String? address = '14 Turner Rd'}) =>
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

  Future<void> pump(WidgetTester tester, String id) async {
    await tester.pumpWidget(wrapped(f.services, OrderDetailScreen(orderId: id)));
    await tester.pumpAndSettle();
  }

  testWidgets('the button offers exactly the next step', (tester) async {
    final id = await order([draft('Cake', date: 1000)]);
    await f.services.orders.confirm(id);
    await pump(tester, id);

    expect(find.text('Start'), findsOneWidget,
        reason: 'confirmed, so the next thing is a baker picking it up');

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.text('Mark ready'), findsOneWidget);

    await tester.tap(find.text('Mark ready'));
    await tester.pumpAndSettle();
    expect(find.text('Send out'), findsOneWidget);

    expect(tester.takeException(), isNull);
    await drain(tester);
  });

  testWidgets('a pickup is collected, never sent out', (tester) async {
    final id = await order([
      draft('Buns', date: 1000, fulfilment: Fulfilment.pickup, address: null),
    ]);
    await f.services.orders.confirm(id);
    var v = await view(id);
    await f.services.orders.moveLine(v.lines.first.id!, LineStatus.inProduction);
    await f.services.orders.moveLine(v.lines.first.id!, LineStatus.ready);

    await pump(tester, id);
    expect(find.text('Mark collected'), findsOneWidget);
    expect(find.text('Send out'), findsNothing);
    await drain(tester);
  });

  testWidgets('items travelling together are handed over together',
      (tester) async {
    // same day, same time, same address — one van, one doorbell
    final id = await order([
      draft('Cake', date: 1000, time: 540),
      draft('Cookies', date: 1000, time: 540),
    ]);
    await f.services.orders.confirm(id);
    for (final l in (await view(id)).lines) {
      await f.services.orders.moveLine(l.id!, LineStatus.inProduction);
      await f.services.orders.moveLine(l.id!, LineStatus.ready);
    }

    await pump(tester, id);
    // the count warns that this button moves both
    expect(find.text('Send out (2)'), findsWidgets);
    await drain(tester);
  });

  testWidgets('items going to different places move separately',
      (tester) async {
    final id = await order([
      draft('Cake', date: 1000, time: 540, address: '14 Turner Rd'),
      draft('Cookies', date: 1000, time: 540, address: 'The office'),
    ]);
    await f.services.orders.confirm(id);
    for (final l in (await view(id)).lines) {
      await f.services.orders.moveLine(l.id!, LineStatus.inProduction);
      await f.services.orders.moveLine(l.id!, LineStatus.ready);
    }

    await pump(tester, id);
    expect(find.text('Send out'), findsNWidgets(2),
        reason: 'two destinations are two journeys, so neither is clubbed');
    expect(find.text('Send out (2)'), findsNothing);
    await drain(tester);
  });

  testWidgets('a delivered item offers nothing further', (tester) async {
    final id = await order([draft('Cake', date: 1000)]);
    await f.services.orders.confirm(id);
    final v = await view(id);
    for (final st in [
      LineStatus.inProduction,
      LineStatus.ready,
      LineStatus.out,
      LineStatus.delivered,
    ]) {
      await f.services.orders.moveLine(v.lines.first.id!, st);
    }

    await pump(tester, id);
    for (final label in [
      'Start',
      'Mark ready',
      'Send out',
      'Mark delivered',
    ]) {
      expect(find.text(label), findsNothing, reason: '$label after handover');
    }
    await drain(tester);
  });

  testWidgets('an unconfirmed order is not advanced item by item',
      (tester) async {
    final id = await order([draft('Cake', date: 1000)]);
    await pump(tester, id);

    expect(find.text('Confirm'), findsNothing,
        reason: 'confirming is a whole-order act, from the order own action');
    expect(find.text('Start'), findsNothing);
    await drain(tester);
  });
}
