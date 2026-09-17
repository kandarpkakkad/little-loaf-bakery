/// Reading a pin out of a Google Maps link, and building the link that opens
/// Maps in the first place.
///
/// There is no Places API here on purpose: it needs a billed API key, and the
/// bakery's flow is "open Maps, search, share the link back". Everything below
/// is offline string work.
library;

class MapsPin {
  const MapsPin({required this.lat, required this.lng, required this.url});

  final double lat;
  final double lng;

  /// The link as it was pasted — kept verbatim so tapping it later opens the
  /// same place, including a name the coordinates alone would lose.
  final String url;
}

/// Coordinates as Google writes them in the several shapes of Maps URL.
///
/// Ordered by how specific each pattern is: `!3d…!4d…` is the place's own pin
/// and beats `@…`, which is only where the camera happened to be.
final _patterns = <RegExp>[
  RegExp(r'!3d(-?\d+\.\d+)!4d(-?\d+\.\d+)'),
  RegExp(r'[?&](?:q|query|ll|center|daddr)=(-?\d+\.\d+),\s*(-?\d+\.\d+)'),
  RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)'),
  RegExp(r'^geo:(-?\d+\.\d+),(-?\d+\.\d+)'),
  // a plain "18.5204, 73.8567" pasted on its own
  RegExp(r'^\s*(-?\d+\.\d+)\s*,\s*(-?\d+\.\d+)\s*$'),
];

/// Pulls lat/lng out of [input], or null when there is nothing to pull.
///
/// Returns null for a maps.app.goo.gl short link: resolving one needs a network
/// round trip, and this stays offline. The caller keeps the URL either way, so
/// the link still works — it just has no coordinates attached.
MapsPin? parseMapsLink(String input) {
  final text = input.trim();
  if (text.isEmpty) return null;

  for (final p in _patterns) {
    final m = p.firstMatch(text);
    if (m == null) continue;
    final lat = double.tryParse(m.group(1)!);
    final lng = double.tryParse(m.group(2)!);
    if (lat == null || lng == null) continue;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) continue;
    return MapsPin(lat: lat, lng: lng, url: text);
  }
  return null;
}

/// True for something that looks like a Maps link we should keep even though
/// no coordinates could be read from it — the short-link case.
bool isMapsLink(String input) {
  final t = input.trim().toLowerCase();
  return t.startsWith('http') &&
      (t.contains('google.com/maps') ||
          t.contains('goo.gl/maps') ||
          t.contains('maps.app.goo.gl'));
}

/// The URL that opens Maps ready to search. Passing the address already typed
/// saves the user retyping it on the other side.
Uri mapsSearchUri(String? address) {
  final q = (address ?? '').trim();
  return Uri.parse(
    q.isEmpty
        ? 'https://www.google.com/maps'
        : 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(q)}',
  );
}

