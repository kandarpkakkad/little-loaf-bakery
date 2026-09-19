import '../../common/money.dart';

/// What a single line of an order is doing (D25).
///
/// A line is what gets made and handed over, so the line has the status. The
/// order's is derived from these — see [deriveOrderStatus].
enum LineStatus {
  created,
  confirmed,
  inProduction,
  ready,
  out,
  delivered,
  cancelled;

  static const _wire = {
    LineStatus.created: 'created',
    LineStatus.confirmed: 'confirmed',
    LineStatus.inProduction: 'in_production',
    LineStatus.ready: 'ready',
    LineStatus.out: 'out',
    LineStatus.delivered: 'delivered',
    LineStatus.cancelled: 'cancelled',
  };

  String get wire => _wire[this]!;

  /// Unknown values come from a newer build and are treated as not-started
  /// rather than throwing: a line this device cannot interpret is still a line
  /// somebody has to bake.
  static LineStatus parse(String s) => _wire.entries
      .firstWhere((e) => e.value == s,
          orElse: () => const MapEntry(LineStatus.created, ''))
      .key;

  bool get isLive => this != LineStatus.cancelled;
  bool get isDone => this == LineStatus.delivered || this == LineStatus.cancelled;

  /// Work has begun. What the item **is** stops being editable here: the baker
  /// has read the flavour and weighed the tin, so changing them now changes
  /// something already half-made.
  bool get hasStarted => index >= LineStatus.inProduction.index && isLive;

  /// Still only an intention — nothing has been made, so everything about it
  /// can still change.
  bool get isEditable =>
      this == LineStatus.created || this == LineStatus.confirmed;

  /// `ready → delivered` skipping `out` is the **pickup** path: nothing goes
  /// out for delivery when the customer collects it.
  static const _allowed = {
    // created and confirmed follow the ORDER: an item is confirmed when the
    // order is, not by itself.
    LineStatus.created: {LineStatus.confirmed, LineStatus.cancelled},
    LineStatus.confirmed: {LineStatus.inProduction, LineStatus.cancelled},
    LineStatus.inProduction: {LineStatus.ready, LineStatus.cancelled},
    LineStatus.ready: {LineStatus.out, LineStatus.delivered, LineStatus.cancelled},
    LineStatus.out: {LineStatus.delivered, LineStatus.cancelled},
    LineStatus.delivered: <LineStatus>{},   // no cancel after handover
    LineStatus.cancelled: <LineStatus>{},
  };

  Set<LineStatus> get next => _allowed[this]!;
  bool canGoTo(LineStatus to) => _allowed[this]!.contains(to);

  String get label => switch (this) {
        LineStatus.created => 'Created',
        LineStatus.confirmed => 'Confirmed',
        LineStatus.inProduction => 'In production',
        LineStatus.ready => 'Ready',
        LineStatus.out => 'Out for delivery',
        LineStatus.delivered => 'Delivered',
        LineStatus.cancelled => 'Cancelled',
      };
}

/// docs/02-domain/orders/hld.md — every transition is taken by a person.
enum OrderStatus {
  created,
  confirmed,
  inProduction,
  ready,
  out,
  delivered,
  completed,
  cancelled;

  static const _wire = {
    OrderStatus.created: 'created',
    OrderStatus.confirmed: 'confirmed',
    OrderStatus.inProduction: 'in_production',
    OrderStatus.ready: 'ready',
    OrderStatus.out: 'out',
    OrderStatus.delivered: 'delivered',
    OrderStatus.completed: 'completed',
    OrderStatus.cancelled: 'cancelled',
  };

  String get wire => _wire[this]!;
  static OrderStatus parse(String s) =>
      _wire.entries.firstWhere((e) => e.value == s).key;

  String get label => switch (this) {
        OrderStatus.created => 'Created',
        OrderStatus.confirmed => 'Confirmed',
        OrderStatus.inProduction => 'In production',
        OrderStatus.ready => 'Ready',
        OrderStatus.out => 'Out for delivery',
        OrderStatus.delivered => 'Delivered',
        OrderStatus.completed => 'Completed',
        OrderStatus.cancelled => 'Cancelled',
      };

  /// The same status, said the way it happens for this order.
  ///
  /// Nothing is delivered to someone who comes and collects it, and "Ready"
  /// means two different things depending on who is travelling. The wire value
  /// is untouched — this is wording, not state, so a pickup and a delivery
  /// still sync as the same status.
  String labelFor({required bool isPickup}) => switch (this) {
        OrderStatus.ready => isPickup ? 'Ready to collect' : 'Ready',
        OrderStatus.delivered => isPickup ? 'Collected' : 'Delivered',
        _ => label,
      };

  /// The button that moves an order *into* this status.
  String actionFor({required bool isPickup}) => switch (this) {
        OrderStatus.delivered => isPickup ? 'Collected' : 'Delivered',
        _ => label,
      };
}

/// The only legal moves. Cancelled is reachable from anything before Delivered;
/// there is no way back once a cake has been handed over.
const Map<OrderStatus, Set<OrderStatus>> kAllowedTransitions = {
  OrderStatus.created: {OrderStatus.confirmed, OrderStatus.cancelled},
  OrderStatus.confirmed: {OrderStatus.inProduction, OrderStatus.cancelled},
  OrderStatus.inProduction: {OrderStatus.ready, OrderStatus.cancelled},
  OrderStatus.ready: {OrderStatus.out, OrderStatus.cancelled},
  OrderStatus.out: {OrderStatus.delivered, OrderStatus.cancelled},
  OrderStatus.delivered: {OrderStatus.completed},
  OrderStatus.completed: {},
  OrderStatus.cancelled: {},
};

/// The next statuses an order can move to, given how it is being fulfilled.
///
/// A pickup never goes "out for delivery" — nobody is taking it anywhere, the
/// customer comes to it. Leaving that step in the flow meant tapping through a
/// status that never happened, so for pickup it is skipped: ready goes straight
/// to handed over.
Set<OrderStatus> allowedNext(OrderStatus from, {required bool isPickup}) {
  if (isPickup && from == OrderStatus.ready) {
    return const {OrderStatus.delivered, OrderStatus.cancelled};
  }
  return kAllowedTransitions[from] ?? const {};
}

/// Whether the order's details may still be changed.
///
/// Once it is out with a courier the address, date and charges are facts about
/// something already in motion — editing them would describe a delivery that is
/// not the one happening.
bool canEditOrder(OrderStatus s) => switch (s) {
      OrderStatus.created ||
      OrderStatus.confirmed ||
      OrderStatus.inProduction ||
      OrderStatus.ready =>
        true,
      _ => false,
    };

/// Whether the message piped on the item may still change.
///
/// Stops one step earlier than the rest: once the order is ready the item has
/// been decorated, and changing the message then would only mislead whoever
/// reads it next.
bool canEditItemMessage(OrderStatus s) => switch (s) {
      OrderStatus.created ||
      OrderStatus.confirmed ||
      OrderStatus.inProduction =>
        true,
      _ => false,
    };

enum Fulfilment { delivery, pickup }

enum DeliveryType {
  local,
  outstation;

  String get wire => this == local ? 'local' : 'outstation';
  String get label => this == local ? 'Inside city' : 'Out of city';
}

enum DiscountType { percent, amount }

/// Bitmask — docs/02-domain/orders/schema.md
class Dietary {
  static const eggless = 1;
  static const nutFree = 2;
  static const glutenFree = 4;
  static const sugarFree = 8;

  static List<String> labels(int flags) => [
        if (flags & eggless != 0) 'Eggless',
        if (flags & nutFree != 0) 'Nut-free',
        if (flags & glutenFree != 0) 'Gluten-free',
        if (flags & sugarFree != 0) 'Sugar-free',
      ];
}

/// A weight is a number and a unit, never a typed string — so a bake sheet can
/// total it and two orders can be compared. `pcs` and `dozen` are here because
/// cookies and brownies are counted, not weighed.
class Weight {
  const Weight(this.value, this.unit);

  final double value;
  final String unit;

  static const units = ['g', 'kg', 'pcs', 'dozen'];

  /// Null unless both halves are present — the schema enforces the same pairing.
  static Weight? maybe(double? value, String? unit) =>
      (value == null || unit == null) ? null : Weight(value, unit);

  /// A trailing `.0` is noise on a label: 1.0 kg reads as "1 kg".
  String get label {
    final n = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
    return '$n $unit';
  }
}

class Addon {
  const Addon({required this.name, required this.price});
  final String name;
  final Money price;
}

class OrderLine {
  const OrderLine({
    required this.menuItemId,
    required this.itemName,
    required this.qty,
    required this.basePrice,
    this.id,
    this.flavour,
    this.weight,
    this.note,
    this.addons = const [],
    this.status = LineStatus.inProduction,
    this.deliveryDate,
    this.deliveryTime,
    this.fulfilment,
    this.deliveryType,
    this.addressText,
    this.pinLat,
    this.pinLng,
    this.pinUrl,
    this.trackingUrl,
    this.deliveredAt,
  });

  /// Null for a line that has not been saved yet.
  final String? id;
  final String menuItemId;
  final String itemName;
  final String? flavour;
  final Weight? weight;
  final int qty;
  final Money basePrice;
  final String? note;
  final List<Addon> addons;

  // ── the line's own schedule (D25) ──
  final LineStatus status;
  final int? deliveryDate;
  final int? deliveryTime;
  final Fulfilment? fulfilment;
  final DeliveryType? deliveryType;
  final String? addressText;
  final double? pinLat;
  final double? pinLng;
  final String? pinUrl;
  final String? trackingUrl;

  /// When this item actually went. Reporting dates a sale by this rather
  /// than by when it was promised.
  final int? deliveredAt;

  bool get isLive => status.isLive;
  bool get hasPin => pinLat != null && pinLng != null;

  /// A pickup never goes out for delivery, so that step is not offered.
  Set<LineStatus> get nextStatuses => fulfilment == Fulfilment.pickup
      ? status.next.where((s) => s != LineStatus.out).toSet()
      : status.next;

  /// base × qty + add-ons. Add-ons are priced **for the line**, not per unit.
  Money get total =>
      basePrice.times(qty) +
      addons.fold(Money.zero, (a, x) => a + x.price);
}

/// Everything needed to compute an order's money. Deliberately not the drift
/// row: totals are derived, never stored, so two devices cannot disagree about
/// a number neither one holds.
class OrderTotals {
  const OrderTotals({
    required this.lines,
    this.discountType,
    this.discountValue = 0,
    this.deliveryCharge = Money.zero,
    this.paid = Money.zero,
  });

  final List<OrderLine> lines;
  final DiscountType? discountType;

  /// Basis points when [discountType] is percent, paise when it is amount.
  final int discountValue;
  final Money deliveryCharge;
  final Money paid;

  /// Cancelled lines leave the total entirely (D27). This is what can put a
  /// paid-up order into credit.
  Money get subtotal =>
      lines.where((l) => l.isLive).fold(Money.zero, (a, l) => a + l.total);

  /// A percentage applies to the subtotal, **never to delivery** — nobody
  /// intends "10% off" to discount the courier. Clamped so a total can never
  /// go negative.
  Money get discount => switch (discountType) {
        null => Money.zero,
        DiscountType.amount => Money(discountValue) > subtotal ? subtotal : Money(discountValue),
        DiscountType.percent => subtotal.percent(discountValue),
      };

  Money get total => subtotal - discount + deliveryCharge;
  Money get balanceDue => total - paid;

  bool get hasBalance => balanceDue.paise > 0;

  /// A negative balance is not a balance. Cancelling a line after payment
  /// leaves money owed *to* the customer, and calling that "-₹500 due" reads as
  /// a mistake rather than as a refund waiting to be made.
  bool get inCredit => balanceDue.paise < 0;
  Money get creditDue => inCredit ? Money(-balanceDue.paise) : Money.zero;
}

/// Derived, never typed. Unpaid is a legitimate confirmed state — nothing in
/// the UI should treat it as a warning.
enum PaymentStatus { unpaid, advancePaid, paid, refunded }

PaymentStatus paymentStatusOf(OrderTotals t, {required bool cancelled}) {
  if (cancelled && t.paid.paise <= 0) return PaymentStatus.refunded;
  if (t.paid.isZero) return PaymentStatus.unpaid;
  if (t.paid >= t.total) return PaymentStatus.paid;
  return PaymentStatus.advancePaid;
}

// ─────────────────────── derived from the lines (D26) ───────────────────────

/// The order's status, computed from its lines.
///
/// Nothing writes this. Two hand-maintained statuses disagree eventually, and
/// the disagreement is invisible until someone reads an order marked delivered
/// while a cake is still in the oven — so there is only one.
///
/// [confirmedAt] and [completedAt] are the two moments a person does write,
/// because neither is a fact about lines: confirming is a conversation with the
/// customer, and completing is deliberate.
OrderStatus deriveOrderStatus(
  Iterable<OrderLine> lines, {
  int? confirmedAt,
  int? completedAt,
}) {
  final live = lines.where((l) => l.isLive).toList();

  // Every line cancelled means the order is cancelled, however it got there.
  if (lines.isNotEmpty && live.isEmpty) return OrderStatus.cancelled;
  if (confirmedAt == null) return OrderStatus.created;

  // Delivered when the LAST live line lands, whichever way it went out.
  if (live.isNotEmpty && live.every((l) => l.status == LineStatus.delivered)) {
    return completedAt != null ? OrderStatus.completed : OrderStatus.delivered;
  }
  // In production the moment ANY line starts. The order has no `ready` or
  // `out` of its own — those are facts about a single item, and an order whose
  // cake is ready while its cookies are still mixing is neither.
  if (live.any((l) => l.status.hasStarted)) return OrderStatus.inProduction;
  return OrderStatus.confirmed;
}

/// The line that finishes the order: the last one still to be handed over.
///
/// Its fulfilment decides how the final status is worded — an order whose last
/// item is collected ends "Collected", one whose last item is driven out ends
/// "Delivered", whatever the others were.
OrderLine? finishingLine(Iterable<OrderLine> lines) {
  OrderLine? last;
  for (final l in lines) {
    if (!l.isLive) continue;
    if (last == null) {
      last = l;
      continue;
    }
    final a = l.deliveryDate ?? 0, b = last.deliveryDate ?? 0;
    if (a > b || (a == b && (l.deliveryTime ?? 0) > (last.deliveryTime ?? 0))) {
      last = l;
    }
  }
  return last;
}

/// When this order is finished: the **last** line still outstanding.
///
/// An order with a cake on Friday and a snack box on Sunday answers Sunday —
/// the order is not done until everything has gone. Null when nothing is
/// outstanding, which means it is waiting on money rather than on the kitchen,
/// and sorts last.
///
/// This is the order's own deadline, not its next task. Work that is due
/// sooner lives on the lines, and the Kitchen reads those directly — see
/// [deriveNextLineDate].
int? deriveDueDate(Iterable<OrderLine> lines) {
  int? latest;
  for (final l in lines) {
    if (l.status.isDone) continue;
    final d = l.deliveryDate;
    if (d == null) continue;
    if (latest == null || d > latest) latest = d;
  }
  return latest;
}

/// The latest time on [deriveDueDate]'s day — the moment the order completes.
/// Null means "any time", which sorts after the timed ones.
int? deriveDueTime(Iterable<OrderLine> lines) {
  final day = deriveDueDate(lines);
  if (day == null) return null;
  int? latest;
  for (final l in lines) {
    if (l.status.isDone || l.deliveryDate != day) continue;
    final t = l.deliveryTime;
    if (t == null) continue;
    if (latest == null || t > latest) latest = t;
  }
  return latest;
}

/// The time of day of the earliest outstanding line on [deriveNextLineDate]'s
/// day. Breaks ties within a day; null means "any time" and sorts after the
/// timed ones.
int? deriveNextLineTime(Iterable<OrderLine> lines) {
  final day = deriveNextLineDate(lines);
  if (day == null) return null;
  int? earliest;
  for (final l in lines) {
    if (l.status.isDone || l.deliveryDate != day) continue;
    final t = l.deliveryTime;
    if (t == null) continue;
    if (earliest == null || t < earliest) earliest = t;
  }
  return earliest;
}

/// The **earliest** outstanding line: what this order needs next.
///
/// Kept apart from [deriveDueDate] because the two answer different questions,
/// and an order spanning two days needs both. A cake on Friday and a snack box
/// on Sunday is due Sunday, but it needs somebody on Friday — and anything
/// asking "what is coming up" has to use this one or it will miss the cake.
int? deriveNextLineDate(Iterable<OrderLine> lines) {
  int? earliest;
  for (final l in lines) {
    if (l.status.isDone) continue;
    final d = l.deliveryDate;
    if (d == null) continue;
    if (earliest == null || d < earliest) earliest = d;
  }
  return earliest;
}

// ─────────────────────────── drops (D25) ───────────────────────────────────

/// Lines that travel together: same day, same time, same destination.
///
/// One van run is one message. Two cakes going to the same house at 4pm on
/// Friday are a single handover, and telling the customer twice is noise —
/// but a box going somewhere else on Sunday is a different event entirely.
class Drop {
  const Drop({required this.key, required this.lines});

  final String key;
  final List<OrderLine> lines;

  int? get deliveryDate => lines.first.deliveryDate;
  int? get deliveryTime => lines.first.deliveryTime;
  Fulfilment? get fulfilment => lines.first.fulfilment;
  String? get addressText => lines.first.addressText;
  String? get trackingUrl =>
      lines.map((l) => l.trackingUrl).whereType<String>().firstOrNull;
}

/// Groups [lines] into the handovers they actually represent.
///
/// Keyed on day, time **and** address: same day and time but two addresses is
/// two journeys, and the address is what makes it so.
List<Drop> dropsOf(Iterable<OrderLine> lines) {
  final byKey = <String, List<OrderLine>>{};
  for (final l in lines) {
    final key = [
      l.deliveryDate ?? '-',
      l.deliveryTime ?? 'any',
      l.fulfilment?.name ?? '-',
      l.addressText ?? '-',
    ].join('|');
    byKey.putIfAbsent(key, () => []).add(l);
  }

  final drops = [
    for (final e in byKey.entries) Drop(key: e.key, lines: e.value),
  ];
  // Soonest first, so "what goes out next" is the top of the list.
  drops.sort((a, b) {
    final d = (a.deliveryDate ?? 0).compareTo(b.deliveryDate ?? 0);
    if (d != 0) return d;
    return (a.deliveryTime ?? 1 << 30).compareTo(b.deliveryTime ?? 1 << 30);
  });
  return drops;
}

/// The drop a given line belongs to.
Drop dropFor(OrderLine line, Iterable<OrderLine> all) =>
    dropsOf(all).firstWhere((d) => d.lines.any((l) => l.id == line.id));
