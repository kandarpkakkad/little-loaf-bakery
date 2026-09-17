import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/common/maps_link.dart';

void main() {
  group('parseMapsLink', () {
    test('reads the place pin from a full place URL', () {
      final pin = parseMapsLink(
          'https://www.google.com/maps/place/Little+Loaf/@18.5104,73.8100,17z'
          '/data=!3m1!4b1!4m6!3m5!1s0x3bc2c0!8m2!3d18.5204!4d73.8567');
      // !3d/!4d is the place itself; @ is only the camera
      expect(pin!.lat, 18.5204);
      expect(pin.lng, 73.8567);
    });

    test('falls back to the @ camera position', () {
      final pin = parseMapsLink('https://www.google.com/maps/@18.5204,73.8567,15z');
      expect(pin!.lat, 18.5204);
      expect(pin.lng, 73.8567);
    });

    test('reads the api=1 share format', () {
      final pin = parseMapsLink(
          'https://www.google.com/maps/search/?api=1&query=18.5204,73.8567');
      expect(pin!.lat, 18.5204);
      expect(pin.lng, 73.8567);
    });

    test('reads ?q= and geo:', () {
      expect(parseMapsLink('https://maps.google.com/?q=18.5204,73.8567')!.lat, 18.5204);
      expect(parseMapsLink('geo:18.5204,73.8567')!.lng, 73.8567);
    });

    test('reads a bare coordinate pair', () {
      final pin = parseMapsLink('  18.5204, 73.8567 ');
      expect(pin!.lat, 18.5204);
      expect(pin.lng, 73.8567);
    });

    test('keeps the url verbatim so the link still opens the named place', () {
      const url = 'https://www.google.com/maps/@18.5204,73.8567,15z';
      expect(parseMapsLink(url)!.url, url);
    });

    test('returns null for a short link, which needs a network hop', () {
      expect(parseMapsLink('https://maps.app.goo.gl/abc123'), isNull);
      // still recognisably a maps link, so the caller keeps it
      expect(isMapsLink('https://maps.app.goo.gl/abc123'), isTrue);
    });

    test('returns null for junk and for out-of-range numbers', () {
      expect(parseMapsLink(''), isNull);
      expect(parseMapsLink('14 Turner Rd, Bandra West'), isNull);
      expect(parseMapsLink('geo:99.5,73.8'), isNull);
      expect(parseMapsLink('https://maps.google.com/?q=18.5,200.1'), isNull);
    });
  });

  group('mapsSearchUri', () {
    test('carries the typed address across so it is not retyped', () {
      final u = mapsSearchUri('14 Turner Rd, Bandra West');
      expect(u.queryParameters['query'], '14 Turner Rd, Bandra West');
      expect(u.queryParameters['api'], '1');
    });

    test('opens plain Maps when there is nothing to search for', () {
      expect(mapsSearchUri('  ').toString(), 'https://www.google.com/maps');
      expect(mapsSearchUri(null).toString(), 'https://www.google.com/maps');
    });
  });
}
