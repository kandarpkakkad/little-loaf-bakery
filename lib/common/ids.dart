import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// UUID v7 — 48-bit millisecond timestamp, then randomness.
///
/// Time-ordered, so `ORDER BY id` is creation order, which is exactly the
/// tie-break the order list needs (docs/00-overview/decisions.md D7).
class Uuid7 {
  static final _rng = Random.secure();

  /// The last millisecond an id was made in, and how many have been made in
  /// it. Together they are RFC 9562's method 1: the 12 bits after the version
  /// nibble hold a counter instead of noise.
  ///
  /// Without this, ids made inside one millisecond sort in a **random** order,
  /// because everything after the 48-bit timestamp is random — so "uuid v7
  /// sorts by creation" was true between milliseconds and a coin flip within
  /// one. That is not an abstract worry: counting a shelf and recording the
  /// delivery that just arrived happens inside one millisecond on a quick
  /// machine, and whichever way the coin fell decided the stock level.
  static int _lastMs = 0;
  static int _counter = 0;

  static String generate([DateTime? at]) {
    final ms = (at ?? DateTime.now()).millisecondsSinceEpoch;

    if (ms == _lastMs) {
      // Wraps after 4096 in one millisecond. Nothing here writes at that rate,
      // and wrapping loses ordering rather than producing a duplicate.
      _counter = (_counter + 1) & 0x0fff;
    } else {
      _lastMs = ms;
      // Starts low so there is room to count up without wrapping, and stays
      // random so ids from two devices in the same millisecond do not collide
      // on a predictable value.
      _counter = _rng.nextInt(0x800);
    }

    final b = Uint8List(16);

    // 48-bit big-endian timestamp
    b[0] = (ms >> 40) & 0xff;
    b[1] = (ms >> 32) & 0xff;
    b[2] = (ms >> 24) & 0xff;
    b[3] = (ms >> 16) & 0xff;
    b[4] = (ms >> 8) & 0xff;
    b[5] = ms & 0xff;

    for (var i = 6; i < 16; i++) {
      b[i] = _rng.nextInt(256);
    }

    // version 7, then the counter across the remaining 12 bits of rand_a
    b[6] = 0x70 | ((_counter >> 8) & 0x0f);
    b[7] = _counter & 0xff;
    b[8] = (b[8] & 0x3f) | 0x80; // variant 10

    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}'
        '-${h.substring(16, 20)}-${h.substring(20)}';
  }

}

/// Crockford base32 — digits and letters with I, L, O and U removed.
///
/// These characters end up read aloud on the phone, and those four are the ones
/// people mishear (docs/00-overview/decisions.md D8).
const _crockford = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

/// Four Crockford characters derived from a UUID — the hash in an order number.
String hash4(String uuid) {
  final digest = sha256.convert(uuid.codeUnits).bytes;
  var v = 0;
  for (var i = 0; i < 3; i++) {
    v = (v << 8) | digest[i];
  }
  v >>= 4; // 20 bits → 4 × 5-bit characters
  final out = StringBuffer();
  for (var i = 3; i >= 0; i--) {
    out.write(_crockford[(v >> (i * 5)) & 0x1f]);
  }
  return out.toString();
}

/// `LLB-0148-K7QP` — prefix, this device's sequence, hash of the order's UUID.
String orderNumber({required String prefix, required int seq, required String uuid}) =>
    '$prefix-${seq.toString().padLeft(4, '0')}-${hash4(uuid)}';

/// `LLB/26-27/0148-K7QP` — the same shape, with the Indian financial year.
String invoiceNumber({
  required String prefix,
  required int seq,
  required String uuid,
  required DateTime issuedAt,
}) =>
    '$prefix/${financialYear(issuedAt)}/${seq.toString().padLeft(4, '0')}-${hash4(uuid)}';

/// Indian financial year: April to March. 29 Aug 2026 → `26-27`.
String financialYear(DateTime d) {
  final startYear = d.month >= 4 ? d.year : d.year - 1;
  final a = (startYear % 100).toString().padLeft(2, '0');
  final b = ((startYear + 1) % 100).toString().padLeft(2, '0');
  return '$a-$b';
}
