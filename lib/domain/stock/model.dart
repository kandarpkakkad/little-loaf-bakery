import '../../common/money.dart';

enum StockKind {
  stockIn,
  consume,
  waste,
  count;

  static const _wire = {
    StockKind.stockIn: 'in',
    StockKind.consume: 'consume',
    StockKind.waste: 'waste',
    StockKind.count: 'count',
  };
  String get wire => _wire[this]!;
  static StockKind parse(String s) => _wire.entries.firstWhere((e) => e.value == s).key;
}

class StockMovement {
  const StockMovement({
    required this.kind,
    required this.qty,
    required this.at,
    this.amount,
  });

  final StockKind kind;

  /// A **delta** for in/consume/waste. The **absolute counted level** for
  /// `count` — which is what makes a count a reset point rather than another
  /// guess. docs/02-domain/stock/schema.md
  final double qty;

  final int at;
  final Money? amount; // only on stockIn, and optional
}

/// Current level: everything since the most recent count, on top of that count.
double levelOf(List<StockMovement> movements) {
  final sorted = [...movements]..sort((a, b) => a.at.compareTo(b.at));
  var base = 0.0;
  var baseAt = -1;

  for (final m in sorted) {
    if (m.kind == StockKind.count) {
      base = m.qty;
      baseAt = m.at;
    }
  }

  var level = base;
  for (final m in sorted) {
    if (m.kind == StockKind.count || m.at <= baseAt) continue;
    level += m.kind == StockKind.stockIn ? m.qty : -m.qty;
  }
  return level;
}

/// The level immediately **after** the most recent stock-in — the bar's full
/// mark. Nothing to configure: the bar answers "how much of what I last bought
/// is left?" docs/00-overview/decisions.md D18.
double referenceOf(List<StockMovement> movements) {
  final sorted = [...movements]..sort((a, b) => a.at.compareTo(b.at));
  final lastIn = sorted.lastWhere(
    (m) => m.kind == StockKind.stockIn,
    orElse: () => const StockMovement(kind: StockKind.count, qty: -1, at: -1),
  );
  if (lastIn.at < 0) return 0; // never stocked in
  return levelOf(sorted.where((m) => m.at <= lastIn.at).toList());
}

/// What the bar is drawn against.
///
/// Normally the reference. When the last restock fell short of the threshold,
/// the threshold instead — so the notch sits hard at the right edge and reads,
/// correctly, as *that restock didn't get you there*.
double barScale({required double reference, required double threshold}) =>
    reference > threshold ? reference : threshold;

enum StockState { below, near, ok }

StockState stockStateOf({required double level, required double threshold}) =>
    level < threshold
        ? StockState.below
        : level < threshold * 1.15
            ? StockState.near
            : StockState.ok;

/// Paise per unit from the most recent stock-in that recorded an amount.
///
/// Stock-ins with no amount are excluded, so an honest gap stays a gap rather
/// than becoming a zero.
Money? lastRateOf(List<StockMovement> movements) {
  final withAmount = movements
      .where((m) => m.kind == StockKind.stockIn && m.amount != null && m.qty > 0)
      .toList()
    ..sort((a, b) => a.at.compareTo(b.at));
  if (withAmount.isEmpty) return null;
  final m = withAmount.last;
  return Money((m.amount!.paise / m.qty).round());
}

/// "Use last price" — takes the last rate, multiplies by the quantity just
/// entered, and shows its working. A checkbox rather than a default, because
/// prices move and a screen that quietly assumes last month's rate is how a
/// stock system starts lying about what things cost.
Money? suggestedAmount({required List<StockMovement> movements, required double qty}) {
  final rate = lastRateOf(movements);
  return rate == null ? null : Money((rate.paise * qty).round());
}
