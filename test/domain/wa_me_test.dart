import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/domain/messaging/compose.dart';

/// A malformed wa.me number does not error — WhatsApp opens a search that
/// spins and fails, which reads as the app being broken.
void main() {
  test('strips everything that is not a digit', () {
    expect(waMeNumber('+91 98765 43210'), '919876543210');
    expect(waMeNumber('+91-98765-43210'), '919876543210');
    expect(waMeNumber('+919876543210'), '919876543210');
  });

  test('builds a link WhatsApp can resolve', () {
    final u = waMeUri(phoneE164: '+91 98765 43210', text: 'hi');
    expect(u.toString(), startsWith('https://wa.me/919876543210?text='));
  });

  test('a number without a country code is not sendable', () {
    // works only on the owner's own phone, fails for everyone else
    expect(canMessage('9876543210'), isFalse);
    expect(canMessage('+919876543210'), isTrue);
  });

  test('rejects lengths that cannot be a real number', () {
    expect(canMessage('+9198'), isFalse);
    expect(canMessage('+9198765432101234567'), isFalse);
  });
}
