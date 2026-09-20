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
    this.id = '',
    this.amount,
  });

  /// The transaction's id, used only to break a tie on [at].
  ///
  /// Two movements recorded in the same millisecond — a count and the purchase
  /// that follows it, which is a normal thing to do — otherwise sort in an
  /// arbitrary order, and a count is a reset point, so the order decides the
  /// answer. Ids are UUID v7, which sort by the moment they were made.
  final String id;

  final StockKind kind;

  /// A **delta** for in/consume/waste. The **absolute counted level** for
  /// `count` — which is what makes a count a reset point rather than another
  /// guess. docs/02-domain/stock/schema.md
  final double qty;

  final int at;
  final Money? amount; // only on stockIn, and optional
}

/// Movements oldest first, ties broken by id.
///
/// The tie is not hypothetical: counting the shelf and then recording the
/// delivery that just arrived happens inside one millisecond easily enough,
/// and until this was ordered properly the purchase was silently dropped.
int _byWhen(StockMovement a, StockMovement b) {
  final t = a.at.compareTo(b.at);
  return t != 0 ? t : a.id.compareTo(b.id);
}

/// Current level: everything since the most recent count, on top of that count.
double levelOf(List<StockMovement> movements) {
  final sorted = [...movements]..sort(_byWhen);

  // Found by position rather than by timestamp. Asking "is this movement
  // later than the count?" cannot answer for one recorded in the same
  // millisecond, and answering "no" throws the purchase away.
  var lastCount = -1;
  for (var i = 0; i < sorted.length; i++) {
    if (sorted[i].kind == StockKind.count) lastCount = i;
  }

  var level = lastCount < 0 ? 0.0 : sorted[lastCount].qty;
  for (var i = lastCount + 1; i < sorted.length; i++) {
    final m = sorted[i];
    level += m.kind == StockKind.stockIn ? m.qty : -m.qty;
  }
  return level;
}

/// The level immediately **after** the most recent stock-in — the bar's full
/// mark. Nothing to configure: the bar answers "how much of what I last bought
/// is left?" docs/00-overview/decisions.md D18.
double referenceOf(List<StockMovement> movements) {
  final sorted = [...movements]..sort(_byWhen);

  var lastIn = -1;
  for (var i = 0; i < sorted.length; i++) {
    if (sorted[i].kind == StockKind.stockIn) lastIn = i;
  }
  if (lastIn < 0) return 0; // never stocked in

  // Sliced by position, for the same reason as above: a count sharing the
  // stock-in's millisecond must not be dragged in or left out by luck.
  return levelOf(sorted.sublist(0, lastIn + 1));
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
