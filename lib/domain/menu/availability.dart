import '../../platform/storage/database.dart';

/// Whether a menu item can be ordered on a given day.
///
/// Two gates, and they mean different things. `active` is a switch somebody
/// flips — "we have stopped making this". A season is a fact about the year —
/// "plum cake runs November to January" — and needs no attention once set.
///
/// docs/02-domain/menu/lld.md §2
bool availableOn(MenuItem m, DateTime day) {
  if (!m.active || m.deletedAt != null) return false;
  if (m.seasonFrom == null || m.seasonTo == null) return true;

  final md = monthDay(day);
  return m.seasonFrom! <= m.seasonTo!
      // Mar–Aug: an ordinary window inside one year.
      ? md >= m.seasonFrom! && md <= m.seasonTo!
      // Nov–Jan: the window wraps the year end, so the test inverts. This is
      // the case that matters, and the one a naive range check gets wrong.
      : md >= m.seasonFrom! || md <= m.seasonTo!;
}

/// MMDD, the form a season is stored in. Comparable as an integer, and free of
/// the year — which is the point: a season repeats.
int monthDay(DateTime d) => d.month * 100 + d.day;

/// Why an item cannot be ordered, in words, or null when it can.
///
/// Said rather than implied: an item that has simply vanished from the picker
/// makes someone wonder whether they imagined it.
String? unavailableReason(MenuItem m, DateTime day) {
  if (m.deletedAt != null) return 'Removed';
  if (!m.active) return 'Not being made';
  if (availableOn(m, day)) return null;
  return 'Out of season until ${_monthName(m.seasonFrom!)}';
}

String _monthName(int monthDay) {
  const names = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final month = monthDay ~/ 100;
  return month >= 1 && month <= 12 ? names[month - 1] : '?';
}

/// The season as a person would read it — "Nov to Jan".
String? seasonLabel(MenuItem m) {
  if (m.seasonFrom == null || m.seasonTo == null) return null;
  return '${_monthName(m.seasonFrom!)} to ${_monthName(m.seasonTo!)}';
}
