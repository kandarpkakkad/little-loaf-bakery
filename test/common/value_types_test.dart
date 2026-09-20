import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/hlc.dart';
import 'package:little_loaf/common/ids.dart';
import 'package:little_loaf/common/money.dart';

void main() {
  group('Money', () {
    test('arithmetic stays in paise', () {
      expect((Money.rupees(1450) + Money.rupees(50)).paise, 150000);
      expect(Money.rupees(180).times(2).paise, 36000);
      expect(Money.zero.isZero, isTrue);
    });

    test('percent rounds half-up to the nearest rupee', () {
      // the worked example: 10% of ₹1,890 = ₹189 exactly
      expect(Money.rupees(1890).percent(1000).paise, 18900);
      // ₹1,005 at 10% = ₹100.50 → rounds up to ₹101, never leaves stray paise
      expect(Money.rupees(1005).percent(1000).paise, 10100);
      expect(Money.rupees(1004).percent(1000).paise, 10000);
      // whatever the input, the result is always whole rupees
      for (var r = 1; r < 500; r++) {
        expect(Money.rupees(r).percent(1750).paise % 100, 0,
            reason: '₹$r at 17.5% left stray paise');
      }
    });

    test('clampAtZero keeps a total from going negative', () {
      expect(Money.rupees(-50).clampAtZero(), Money.zero);
      expect(Money.rupees(50).clampAtZero().paise, 5000);
    });
  });

  group('Hlc', () {
    test('is monotonic when the clock stands still', () {
      var h = const Hlc(1000, 0, 'a');
      for (var i = 0; i < 10000; i++) {
        final next = Hlc.issue(nowMs: 1000, last: h, deviceId: 'a');
        expect(next > h, isTrue);
        h = next;
      }
      expect(h.counter, 10000);
    });

    test('is monotonic when the clock moves backwards', () {
      final h = const Hlc(5000, 3, 'a');
      final next = Hlc.issue(nowMs: 4000, last: h, deviceId: 'a'); // NTP correction
      expect(next > h, isTrue);
      expect(next.wallMs, 5000);
    });

    test('observing a peer never lags it', () {
      final local = const Hlc(1000, 0, 'a');
      final remote = const Hlc(9000, 5, 'b');
      final next = Hlc.observe(nowMs: 1001, last: local, remote: remote, deviceId: 'a');
      expect(next > remote, isTrue);
    });

    test('device id breaks ties, so every device agrees', () {
      expect(const Hlc(1, 0, 'a') < const Hlc(1, 0, 'b'), isTrue);
    });

    test('round-trips through its string form', () {
      const h = Hlc(1756300812345, 7, '0192f3-a41c');
      expect(Hlc.parse(h.toString()), h);
    });
  });

  group('ids', () {
    test('uuid v7 sorts by creation', () {
      final a = Uuid7.generate(DateTime(2026, 1, 1));
      final b = Uuid7.generate(DateTime(2026, 6, 1));
      expect(a.compareTo(b) < 0, isTrue);
    });

    test('uuid v7 sorts by creation WITHIN one millisecond too', () {
      // The half of this property that was missing. Everything after the
      // 48-bit timestamp used to be random, so ids made in the same
      // millisecond sorted by a coin flip — and the stock level, which breaks
      // ties on id, came out wrong roughly half the time on a quick machine.
      for (var trial = 0; trial < 50; trial++) {
        final made = [for (var i = 0; i < 64; i++) Uuid7.generate()];
        expect(made, orderedEquals([...made]..sort()),
            reason: 'made in order, so they must sort in order');
        expect(made.toSet(), hasLength(made.length), reason: 'and be distinct');
      }
    });

    test('an explicit timestamp still counts from its own millisecond', () {
      final at = DateTime(2026, 3, 3);
      final made = [for (var i = 0; i < 8; i++) Uuid7.generate(at)];
      expect(made, orderedEquals([...made]..sort()));
    });

    test('uuid v7 carries version and variant bits', () {
      final u = Uuid7.generate();
      expect(u[14], '7');
      expect('89ab'.contains(u[19]), isTrue);
    });

    test('hash4 avoids the characters people mishear', () {
      for (var i = 0; i < 2000; i++) {
        final h = hash4(Uuid7.generate());
        expect(h.length, 4);
        expect(RegExp(r'^[0-9A-HJKMNP-TV-Z]{4}$').hasMatch(h), isTrue,
            reason: '$h contains I, L, O or U');
      }
    });

    test('hash4 is deterministic', () {
      const u = '0192f4a0-1111-7222-8333-444444444444';
      expect(hash4(u), hash4(u));
    });

    test('order and invoice numbers take the documented shape', () {
      const u = '0192f4a0-1111-7222-8333-444444444444';
      expect(orderNumber(prefix: 'LLB', seq: 148, uuid: u),
          matches(r'^LLB-0148-[0-9A-HJKMNP-TV-Z]{4}$'));
      expect(
          invoiceNumber(prefix: 'LLB', seq: 148, uuid: u, issuedAt: DateTime(2026, 8, 29)),
          matches(r'^LLB/26-27/0148-[0-9A-HJKMNP-TV-Z]{4}$'));
    });

    test('financial year runs April to March', () {
      expect(financialYear(DateTime(2026, 8, 29)), '26-27');
      expect(financialYear(DateTime(2026, 3, 31)), '25-26');
      expect(financialYear(DateTime(2026, 4, 1)), '26-27');
    });
  });
}
