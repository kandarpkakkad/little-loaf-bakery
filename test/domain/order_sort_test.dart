import 'package:drift/drift.dart' show Variable;
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

  test('a multi-day order sorts by its earliest item, not its due date', () async {
    // The whole point: this order is due Sep 9, but it needs a baker on Sep 1,
    // so it must sort ahead of an order due Sep 5.
    await f.spanning('spans Sep1 to Sep9', first: 1, last: 9);
    await f.order('single Sep5', 5, 600);

    expect(await f.labels(), ['spans Sep1 to Sep9', 'single Sep5']);
  });

  test('once the early item is delivered it sorts by what is left', () async {
    final id = await f.spanning('spans', first: 1, last: 9);
    await f.order('single Sep5', 5, 600);
    expect(await f.labels(), ['spans', 'single Sep5']);

    await f.deliverEarliest(id);

    expect(await f.labels(), ['single Sep5', 'spans'],
        reason: 'only the Sep 9 item is left, so it falls behind Sep 5');
  });

  test('an order with nothing outstanding sorts last', () async {
    final done = await f.order('all delivered', 1, 600);
    await f.order('still to do', 8, 600);
    await f.deliverEverything(done);

    expect(await f.labels(), ['still to do', 'all delivered'],
        reason: 'it is waiting on money, not on the kitchen');
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

  Future<String> order(String label, int dayOfSept, int? minutes) =>
      s.orders.create(
        customerId: customerId,
        lines: [
          DraftLine(
            menuItemId: menuId,
            itemName: label,
            basePrice: Money.rupees(100),
          )
        ],
        deliveryDate: DateTime(2026, 9, dayOfSept).millisecondsSinceEpoch,
        deliveryTime: minutes,
      );

  Future<List<String>> labels() async {
    final rows = await s.orders.watchOrders().first;
    return [for (final r in rows) r.lines.first.itemName];
  }


  /// An order whose items straddle two days: one on [first], one on [last].
  Future<String> spanning(String label, {required int first, required int last}) =>
      s.orders.create(
        customerId: customerId,
        lines: [
          DraftLine(
            menuItemId: menuId,
            itemName: label,
            basePrice: Money.rupees(100),
            deliveryDate: DateTime(2026, 9, first).millisecondsSinceEpoch,
          ),
          DraftLine(
            menuItemId: menuId,
            itemName: '$label (second)',
            basePrice: Money.rupees(100),
            deliveryDate: DateTime(2026, 9, last).millisecondsSinceEpoch,
          ),
        ],
        deliveryDate: DateTime(2026, 9, first).millisecondsSinceEpoch,
      );

  /// Walks a line all the way to delivered, one legal step at a time.
  Future<void> _deliver(String lineId) async {
    for (final step in const [
      LineStatus.confirmed,
      LineStatus.inProduction,
      LineStatus.ready,
      LineStatus.delivered,   // pickup goes straight here from ready
    ]) {
      final rows = await s.db
          .customSelect('SELECT status FROM order_items WHERE id = ?',
              variables: [Variable.withString(lineId)])
          .getSingle();
      final now = LineStatus.parse(rows.read<String>('status'));
      if (now.canGoTo(step)) await s.orders.moveLine(lineId, step);
    }
  }

  Future<void> deliverEarliest(String orderId) async {
    final v = await s.orders.watchOrder(orderId).first;
    final live = v!.liveLines.where((l) => !l.status.isDone).toList()
      ..sort((a, b) => a.deliveryDate!.compareTo(b.deliveryDate!));
    await _deliver(live.first.id!);
  }

  Future<void> deliverEverything(String orderId) async {
    final v = await s.orders.watchOrder(orderId).first;
    for (final l in v!.liveLines) {
      await _deliver(l.id!);
    }
  }

  Future<void> close() => s.db.close();
}
