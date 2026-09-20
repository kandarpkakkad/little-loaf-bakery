import '../../common/money.dart';

/// ₹1,890 · ₹1,890.50 · −₹100 · and **nothing at all when zero**.
///
/// "Zero never shows" is one rule applied everywhere: a ₹0 row is absent from
/// the invoice, the messages, order detail, totals and cards — never printed as
/// a zero. docs/00-overview/decisions.md D10.
String? money(Money m, {bool showZero = false}) {
  if (m.isZero && !showZero) return null;
  final neg = m.isNegative;
  final paise = m.abs.paise;
  final rupees = paise ~/ 100;
  final fraction = paise % 100;
  final body = _indianGroup(rupees) +
      (fraction == 0 ? '' : '.${fraction.toString().padLeft(2, '0')}');
  return '${neg ? '−' : ''}₹$body';
}

/// Bare digits for the invoice's monospace block — no ₹, right-aligned there.
String moneyPlain(Money m) {
  final paise = m.abs.paise;
  final body = _indianGroup(paise ~/ 100);
  final f = paise % 100;
  return '${m.isNegative ? '-' : ''}$body${f == 0 ? '' : '.${f.toString().padLeft(2, '0')}'}';
}

/// 1,20,000 — last three digits, then pairs.
String _indianGroup(int n) {
  final s = n.toString();
  if (s.length <= 3) return s;
  final last3 = s.substring(s.length - 3);
  var rest = s.substring(0, s.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '${parts.join(',')},$last3';
}

/// "Any time" is a real answer, not a missing value.
String timeLabel(int? minutesFromMidnight) {
  if (minutesFromMidnight == null) return 'Any time';
  final h24 = minutesFromMidnight ~/ 60;
  final m = minutesFromMidnight % 60;
  final period = h24 < 12 ? 'am' : 'pm';
  final h = h24 % 12 == 0 ? 12 : h24 % 12;
  return '$h:${m.toString().padLeft(2, '0')} $period';
}

/// "Today", "Tomorrow", "Fri 21 Sep" — a day as somebody would say it.
///
/// Near days are named rather than dated because that is how a bakery talks
/// about them, and the year is absent because an order more than a few months
/// out is not a thing that happens here.
String dayLabel(int ms, {DateTime? now}) {
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  final today = now ?? DateTime.now();

  bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  if (sameDay(d, today)) return 'Today';
  if (sameDay(d, today.add(const Duration(days: 1)))) return 'Tomorrow';
  if (sameDay(d, today.subtract(const Duration(days: 1)))) return 'Yesterday';

  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final label = '${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]}';
  return d.year == today.year ? label : '$label ${d.year}';
}
