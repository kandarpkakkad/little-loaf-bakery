import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/phone.dart';

/// One country is supported today; the shape allows a second without unpicking
/// assumptions. Storage is always canonical, display is always grouped.
void main() {
  test('stores canonically, with no spaces', () {
    expect(const Phone('9876543210').e164, '+919876543210');
  });

  test('shows the number the way it is read aloud', () {
    expect(const Phone('9876543210').pretty, '+91 98765 43210');
  });

  test('accepts a real Indian mobile', () {
    for (final n in ['9876543210', '6123456789', '7000000000', '8999999999']) {
      expect(Phone(n).isValid, isTrue, reason: '$n should be valid');
    }
  });

  test('explains what is wrong rather than just refusing', () {
    expect(const Phone('').problem, 'Required');
    expect(const Phone('98765').problem, 'Needs 10 digits');
    // landlines and 0-5 prefixes cannot receive WhatsApp
    expect(const Phone('1234567890').problem, contains('start with'));
    expect(const Phone('5876543210').isValid, isFalse);
  });

  test('parses whatever older rows might hold', () {
    for (final stored in [
      '+919876543210',
      '+91 98765 43210',
      '91-98765-43210',
      '09876543210',
      '9876543210',
    ]) {
      expect(Phone.parse(stored).e164, '+919876543210',
          reason: '$stored did not normalise');
    }
  });

  test('a round trip through storage never changes the number', () {
    const p = Phone('9876543210');
    expect(Phone.parse(p.e164), p);
  });

  test('the person typing never enters spaces; display adds them', () {
    // the field strips non-digits, so this is what a controller holds
    const typed = Phone('9876543210');
    expect(typed.e164, '+919876543210', reason: 'stored unspaced');
    expect(typed.pretty, '+91 98765 43210', reason: 'shown grouped');
  });

  test('a number pasted with spaces still stores unspaced', () {
    expect(Phone(Phone.digitsOf('98765 43210')).e164, '+919876543210');
  });

  test('the country list is the single place to extend', () {
    expect(kSupportedCountries, hasLength(1));
    expect(kDefaultCountry, kIndia);
    expect(kIndia.code, '+91');
    expect(kIndia.nationalLength, 10);
  });
}
