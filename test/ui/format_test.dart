import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/money.dart';
import 'package:little_loaf/ui/theme/format.dart';

void main() {
  test('zero never shows', () {
    expect(money(Money.zero), isNull);
    expect(money(Money.zero, showZero: true), '₹0');
  });

  test('Indian digit grouping', () {
    expect(money(Money.rupees(1890)), '₹1,890');
    expect(money(Money.rupees(120000)), '₹1,20,000');
    expect(money(Money.rupees(10000000)), '₹1,00,00,000');
    expect(money(Money.rupees(999)), '₹999');
  });

  test('decimals only when there are paise', () {
    expect(money(const Money(189050)), '₹1,890.50');
    expect(money(const Money(189000)), '₹1,890');
  });

  test('a discount uses a minus sign, not brackets', () {
    expect(money(Money.rupees(-100)), '−₹100');
  });

  test('the monospace block carries no rupee symbol', () {
    expect(moneyPlain(Money.rupees(1890)), '1,890');
    expect(moneyPlain(Money.rupees(-189)), '-189');
  });

  test('an unset delivery time reads as Any time', () {
    expect(timeLabel(null), 'Any time');
    expect(timeLabel(16 * 60), '4:00 pm');
    expect(timeLabel(0), '12:00 am');
    expect(timeLabel(12 * 60), '12:00 pm');
    expect(timeLabel(9 * 60 + 30), '9:30 am');
  });
}
