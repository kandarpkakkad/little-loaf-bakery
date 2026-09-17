import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/money.dart';
import 'package:little_loaf/domain/messaging/compose.dart';
import 'package:little_loaf/domain/orders/model.dart';

final _lines = [
  OrderLine(
    menuItemId: 'm1', itemName: 'Chocolate Truffle', flavour: 'Belgian dark',
    weight: const Weight(1, 'kg'), qty: 1, basePrice: Money.rupees(1450),
    addons: [
      Addon(name: 'Message on cake', price: Money.rupees(50)),
      Addon(name: 'Candles', price: Money.rupees(30)),
    ],
  ),
  OrderLine(menuItemId: 'm2', itemName: 'Sourdough loaf', qty: 2, basePrice: Money.rupees(180)),
];

MessageContext _ctx({
  Money paid = const Money(80000),
  DiscountType? discount = DiscountType.amount,
  int discountValue = 10000,
  String? tracking,
  String? upi = 'littleloaf@okaxis',
  String? phone = '+91 98… 1102',
  bool hadBalance = true,
}) =>
    MessageContext(
      customerFirstName: 'Meera',
      orderNo: 'LLB-0148-K7QP',
      businessName: 'Little Loaf Bakery',
      lines: _lines,
      totals: OrderTotals(
        lines: _lines,
        discountType: discount,
        discountValue: discountValue,
        deliveryCharge: Money.rupees(100),
        paid: paid,
      ),
      deliveryDateLabel: 'Sat 29 Aug',
      deliveryTimeLabel: '4:00 pm',
      addressText: '14 Turner Rd, Bandra West, Mumbai 400050',
      itemMessage: 'Happy 40th Aarav',
      requirements: 'gold lettering, pastel blue rosettes, no fondant figures',
      trackingUrl: tracking,
      upiId: upi,
      paymentPhone: phone,
      hadBalance: hadBalance,
    );

void main() {
  group('which messages are offered', () {
    test('confirmation and delivery always are', () {
      expect(isOffered(MessageKind.confirmation, _ctx()), isTrue);
      expect(isOffered(MessageKind.delivery, _ctx()), isTrue);
    });

    test('on-its-way only when a tracking link exists', () {
      expect(isOffered(MessageKind.outForDelivery, _ctx()), isFalse);
      expect(isOffered(MessageKind.outForDelivery, _ctx(tracking: 'https://t.co/x')), isTrue);
    });

    test('payment received only when there was a balance', () {
      expect(isOffered(MessageKind.paymentReceived, _ctx(hadBalance: true)), isTrue);
      expect(isOffered(MessageKind.paymentReceived, _ctx(hadBalance: false)), isFalse);
    });
  });

  group('confirmation', () {
    test('carries requirements and the address', () {
      final m = compose(MessageKind.confirmation, _ctx());
      expect(m, contains('Little Loaf Bakery is confirmed'));
      expect(m, contains('LLB-0148-K7QP'));
      expect(m, contains('Chocolate Truffle · Belgian dark · 1 kg × 1'));
      expect(m, contains('Happy 40th Aarav'));
      expect(m, contains('no fondant figures'));
      expect(m, contains('14 Turner Rd'));
      expect(m, contains('Balance due ₹1,090'));
    });

    test('with no advance, says payable on delivery', () {
      final m = compose(MessageKind.confirmation, _ctx(paid: Money.zero));
      expect(m, contains('Payable on delivery ₹1,890'));
      expect(m, isNot(contains('Advance received')));
    });
  });

  group('delivery message — two shapes, one function', () {
    test('with a balance, carries the amount and how to pay', () {
      final m = compose(MessageKind.delivery, _ctx());
      expect(m, contains('*Balance due ₹1,090*'));
      expect(m, contains('Pay by UPI to littleloaf@okaxis'));
      expect(m, contains('or to +91 98… 1102'));
    });

    test('with nothing owed, the money lines are simply absent', () {
      final m = compose(MessageKind.delivery, _ctx(paid: Money.rupees(1890)));
      expect(m, isNot(contains('Balance due')));
      expect(m, isNot(contains('Pay by UPI')));
      expect(m, contains('We hope you enjoyed it'));
    });

    test('with no payment details configured, the message still reads', () {
      final m = compose(MessageKind.delivery, _ctx(upi: null, phone: null));
      expect(m, contains('Balance due'));
      expect(m, isNot(contains('Pay by UPI')));
      expect(m, contains('Thank you for ordering'));
    });

    test('with only a phone, it reads as the pay-to line', () {
      final m = compose(MessageKind.delivery, _ctx(upi: null));
      expect(m, contains('Pay by UPI to +91 98… 1102'));
      expect(m, isNot(contains('or to')));
    });
  });

  test('payment received carries no numbers at all', () {
    final m = compose(MessageKind.paymentReceived, _ctx());
    expect(m, contains('we have received your payment'));
    expect(m, isNot(contains('₹')));
    expect(m, isNot(contains('LLB-')));
  });

  test('on its way is bare — order number and link, nothing else', () {
    final m = compose(MessageKind.outForDelivery, _ctx(tracking: 'https://track.example.com/AB1'));
    expect(m, contains('https://track.example.com/AB1'));
    expect(m, isNot(contains('₹')));
    expect(m, isNot(contains('Chocolate')));
  });

  group('invoice', () {
    test('no line in the monospace block exceeds 26 characters', () {
      for (final ctx in [
        _ctx(),
        _ctx(paid: Money.zero),
        _ctx(paid: Money.rupees(1890)),
        _ctx(discount: DiscountType.percent, discountValue: 1000),
        _ctx(discount: null, discountValue: 0),
      ]) {
        final m = compose(MessageKind.invoice, ctx);
        final block = m.split('```')[1].split('\n').where((l) => l.isNotEmpty);
        for (final line in block) {
          expect(line.length, lessThanOrEqualTo(kMonoWidth),
              reason: 'too wide (${line.length}): "$line"');
        }
      }
    });

    test('a percentage discount prints its percentage', () {
      final m = compose(MessageKind.invoice,
          _ctx(discount: DiscountType.percent, discountValue: 1000));
      expect(m, contains('Discount 10%'));
    });

    test('a zero row is absent, never printed as zero', () {
      final m = compose(MessageKind.invoice, _ctx(discount: null, discountValue: 0));
      expect(m, isNot(contains('Discount')));
    });

    test('with no advance, collapses to AMOUNT DUE', () {
      final m = compose(MessageKind.invoice, _ctx(paid: Money.zero));
      expect(m, contains('AMOUNT DUE'));
      expect(m, isNot(contains('Advance paid')));
    });

    test('when fully paid, collapses to PAID and drops the UPI line', () {
      final m = compose(MessageKind.invoice, _ctx(paid: Money.rupees(1890)));
      expect(m, contains('PAID · thank you'));
      expect(m, isNot(contains('Pay by UPI')));
    });

    test('a long product name wraps without breaking the totals column', () {
      final long = [
        OrderLine(
          menuItemId: 'm', qty: 1, basePrice: Money.rupees(2500),
          itemName: 'Three-tier hand-piped celebration cake with gold leaf',
        ),
      ];
      final m = compose(
        MessageKind.invoice,
        MessageContext(
          customerFirstName: 'Meera', orderNo: 'LLB-0001-AAAA',
          businessName: 'Little Loaf Bakery', lines: long,
          totals: OrderTotals(lines: long),
        ),
      );
      final block = m.split('```')[1].split('\n').where((l) => l.isNotEmpty).toList();
      // the name is on its own line and allowed to be long; every OTHER line fits
      expect(block.where((l) => l.length > kMonoWidth), [long.first.itemName]);
    });
  });

  group('wa.me link', () {
    test('strips the plus and encodes the text', () {
      final u = waMeUri(phoneE164: '+919876543210', text: 'Hi *Meera*\nline two');
      expect(u.toString(), startsWith('https://wa.me/919876543210?text='));
      expect(u.toString(), contains('%0A')); // newline survives as %0A
      expect(u.queryParameters['text'], contains('*Meera*')); // formatting intact
    });

    test('carries emoji and Devanagari intact', () {
      final u = waMeUri(phoneE164: '+919876543210', text: '🎂 नमस्ते');
      expect(u.queryParameters['text'], '🎂 नमस्ते');
    });
  });
}
