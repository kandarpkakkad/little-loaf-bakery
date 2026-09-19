import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/money.dart';
import 'package:little_loaf/domain/messaging/compose.dart';
import 'package:little_loaf/domain/orders/model.dart';

/// Lines that travel together are one handover, and one message (D25).
void main() {
  var n = 0;
  OrderLine line(
    String name, {
    int? date,
    int? time,
    String? address = '14 Turner Rd',
    Fulfilment fulfilment = Fulfilment.delivery,
  }) =>
      OrderLine(
        id: 'l${n++}',
        menuItemId: 'm1',
        itemName: name,
        qty: 1,
        basePrice: Money.rupees(500),
        deliveryDate: date,
        deliveryTime: time,
        addressText: address,
        fulfilment: fulfilment,
      );

  setUp(() => n = 0);

  group('grouping', () {
    test('same day, time and place is one drop', () {
      final drops = dropsOf([
        line('Cake', date: 100, time: 540),
        line('Cookies', date: 100, time: 540),
      ]);
      expect(drops, hasLength(1));
      expect(drops.single.lines.map((l) => l.itemName), ['Cake', 'Cookies']);
    });

    test('different days are different drops', () {
      final drops = dropsOf([
        line('Cake', date: 100, time: 540),
        line('Box', date: 500, time: 540),
      ]);
      expect(drops, hasLength(2));
    });

    test('same day but different times are different drops', () {
      final drops = dropsOf([
        line('Cake', date: 100, time: 540),
        line('Box', date: 100, time: 1020),
      ]);
      expect(drops, hasLength(2), reason: 'two journeys, two messages');
    });

    test('same day and time but two addresses are two journeys', () {
      final drops = dropsOf([
        line('Cake', date: 100, time: 540, address: '14 Turner Rd'),
        line('Box', date: 100, time: 540, address: 'The office'),
      ]);
      expect(drops, hasLength(2));
    });

    test('a pickup is not the same event as a delivery', () {
      final drops = dropsOf([
        line('Cake', date: 100, time: 540),
        line('Buns', date: 100, time: 540, fulfilment: Fulfilment.pickup),
      ]);
      expect(drops, hasLength(2));
    });

    test('drops come back soonest first', () {
      final drops = dropsOf([
        line('Late', date: 900, time: 540),
        line('Early', date: 100, time: 540),
        line('Middle', date: 100, time: 1020),
      ]);
      expect(drops.map((d) => d.lines.single.itemName),
          ['Early', 'Middle', 'Late']);
    });

    test('an untimed line sorts after the timed ones of its day', () {
      final drops = dropsOf([
        line('Any time', date: 100),
        line('Nine', date: 100, time: 540),
      ]);
      expect(drops.first.lines.single.itemName, 'Nine');
    });

    test('dropFor finds the drop a line belongs to', () {
      final all = [
        line('Cake', date: 100, time: 540),
        line('Cookies', date: 100, time: 540),
        line('Box', date: 500, time: 540),
      ];
      final d = dropFor(all[1], all);
      expect(d.lines, hasLength(2));
      expect(d.deliveryDate, 100);
    });
  });

  group('what the message says', () {
    MessageContext ctx(List<OrderLine> all, List<OrderLine> dropped) =>
        MessageContext(
          customerFirstName: 'Asha',
          orderNo: 'LLB-0001',
          totals: OrderTotals(lines: all, paid: Money.zero),
          lines: all,
          businessName: 'Little Loaf Bakery',
          dropLines: dropped,
        );

    test('a partial drop says part, and names what is still coming', () {
      final all = [
        line('Cake', date: 100, time: 540),
        line('Box', date: 500, time: 540),
      ];
      final m = compose(MessageKind.delivery, ctx(all, [all.first]));

      expect(m, contains('part of your order has arrived'));
      expect(m, contains('Cake'));
      expect(m, contains('Still to come: Box'));
      expect(m, isNot(contains('Balance due')),
          reason: 'asking for money while a box is still to come reads as a '
              'demand for something undelivered');
    });

    test('the final drop is the whole-order message', () {
      final all = [
        line('Cake', date: 100, time: 540),
        line('Box', date: 500, time: 540),
      ];
      final m = compose(MessageKind.delivery, ctx(all, all));
      expect(m, contains('your order has been delivered'));
      expect(m, isNot(contains('Still to come')));
    });

    test('a clubbed drop names every item in it, once', () {
      final all = [
        line('Cake', date: 100, time: 540),
        line('Cookies', date: 100, time: 540),
      ];
      final m = compose(MessageKind.delivery, ctx(all, all));
      expect(m, contains('Cake'));
      expect(m, contains('Cookies'));
      expect('your order has been delivered'.allMatches(m).length, 1);
    });

    test('a single-drop order is unchanged', () {
      final all = [line('Cake', date: 100, time: 540)];
      final m = compose(MessageKind.delivery, ctx(all, const []));
      expect(m, contains('your order has been delivered'));
      expect(m, isNot(contains('Still to come')));
    });
  });
}
