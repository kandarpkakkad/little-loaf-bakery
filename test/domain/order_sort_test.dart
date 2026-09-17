import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/app/scope.dart';
import 'package:little_loaf/common/money.dart';
import 'package:little_loaf/domain/orders/model.dart';
import 'package:little_loaf/domain/orders/repository.dart';

import '../support/harness.dart';

/// The app's sort is delivery date, then time, then creation — with an untimed
/// order after the timed ones on its day. One direction, every list.
/// docs/02-domain/orders/schema.md
void main() {
  late AppServicesFixture f;

  setUp(() async => f = await AppServicesFixture.make());
  tearDown(() async => f.close());

  test('reads forward: date, then time, untimed last on its day', () async {
    await f.order('Sep2 17:00', 2, 1020);
    await f.order('Sep2 any', 2, null);
    await f.order('Sep1 10:00', 1, 600);
    await f.order('Sep5 10:00', 5, 600);
    await f.order('Sep2 09:00', 2, 540);

    expect(await f.labels(), [
      'Sep1 10:00',
      'Sep2 09:00',
      'Sep2 17:00',
      // "any time" sorts after the timed orders of the same day, not before
      'Sep2 any',
      'Sep5 10:00',
    ]);
  });

  test('finished orders read the same way as open ones', () async {
    // The Delivered and Cancelled tabs used to read backward. They no longer
    // do: every tab answers "what is due next", so there is one direction.
    await f.order('Sep2 17:00', 2, 1020);
    await f.order('Sep1 10:00', 1, 600);
    await f.order('Sep2 09:00', 2, 540);
    await f.order('Sep2 any', 2, null);

    expect(await f.labels(), [
      'Sep1 10:00',
      'Sep2 09:00',
      'Sep2 17:00',
      'Sep2 any',
    ]);
  });

  test('two orders at the same minute keep the order they were taken in',
      () async {
    await f.order('taken first', 3, 600);
    await f.order('taken second', 3, 600);

    expect(await f.labels(), ['taken first', 'taken second']);
  });
}

/// Small holder so each test reads as the ordering it asserts, not as setup.
class AppServicesFixture {
  AppServicesFixture(this.s, this.menuId, this.customerId);

  final AppServices s;
  final String menuId;
  final String customerId;

  static Future<AppServicesFixture> make() async {
    final s = await testServices();
    final menuId = await s.menu.create(name: 'Cake');
    final customerId = await s.customers
        .findOrCreate(name: 'Asha', phoneE164: '+919876543210');
    return AppServicesFixture(s, menuId, customerId);
  }

  Future<void> order(String label, int dayOfSept, int? minutes) =>
      s.orders.create(
        customerId: customerId,
        lines: [
          DraftLine(
            menuItemId: menuId,
            itemName: label,
            basePrice: Money.rupees(100),
          )
        ],
        fulfilment: Fulfilment.pickup,
        deliveryDate: DateTime(2026, 9, dayOfSept).millisecondsSinceEpoch,
        deliveryTime: minutes,
      );

  Future<List<String>> labels() async {
    final rows = await s.orders.watchOrders().first;
    return [for (final r in rows) r.lines.first.itemName];
  }

  Future<void> close() => s.db.close();
}
