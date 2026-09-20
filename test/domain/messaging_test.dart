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
    // On the cake, not on the order: the loaf below is neither piped nor
    // fussy about fondant.
    itemMessage: 'Happy 40th Aarav',
    requirements: 'gold lettering, pastel blue rosettes, no fondant figures',
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
  Money? lastPayment,
  bool isUpdate = false,
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
      trackingUrl: tracking,
      upiId: upi,
      paymentPhone: phone,
      lastPayment: lastPayment,
      isUpdate: isUpdate,
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

    test('payment received is offered after every payment', () {
      // It used to be offered only when a balance existed, which meant a
      // partial payment never produced one at all — the order sits at the same
      // status before and after, so nothing status-driven ever fired. The
      // `hadBalance` flag that encoded that rule is gone; nothing reads the
      // payment history to decide any more.
      expect(isOffered(MessageKind.paymentReceived, _ctx()), isTrue);
      expect(
          isOffered(MessageKind.paymentReceived,
              _ctx(lastPayment: Money.rupees(100))),
          isTrue);
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

  group('payment received', () {
    test('names the amount just paid and what is still owed', () {
      final m = compose(
        MessageKind.paymentReceived,
        _ctx(paid: Money.rupees(500), lastPayment: Money.rupees(500)),
      );
      expect(m, contains('we have received ₹500'));
      expect(m, contains('LLB-0148-K7QP'));
      expect(m, contains('Still to pay:'),
          reason: 'a part payment is when the customer is least sure');
    });

    test('says so when that settles it', () {
      // paid exactly the total, whatever the fixture's arithmetic works out to
      final owedInFull = _ctx().totals.total;
      final m = compose(
        MessageKind.paymentReceived,
        _ctx(paid: owedInFull, lastPayment: Money.rupees(500)),
      );
      expect(m, contains('paid in full'));
      expect(m, isNot(contains('Still to pay')));
    });

    test('offers a refund when the order is in credit', () {
      final m = compose(
        MessageKind.paymentReceived,
        _ctx(paid: Money.rupees(999999), lastPayment: Money.rupees(500)),
      );
      expect(m, contains('to refund to you'));
    });

    test('still reads sensibly when the amount is unknown', () {
      final m = compose(MessageKind.paymentReceived, _ctx());
      expect(m, contains('we have received your payment'));
    });
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

  test('an updated order opens as an update, not as a first confirmation', () {
    final first = compose(MessageKind.confirmation, _ctx());
    final again = compose(MessageKind.confirmation, _ctx(isUpdate: true));

    expect(first, contains('is confirmed'));
    expect(again, contains('has been updated'));
    expect(again, isNot(contains('is confirmed')),
        reason: 'they already had a confirmation; this is what changed');
    // and it is still the whole order, so nothing looks dropped
    expect(again, contains('Chocolate Truffle'));
    expect(again, contains('Sourdough loaf'));
  });
}
