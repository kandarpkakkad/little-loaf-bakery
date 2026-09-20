import '../../common/money.dart';

/// What a single line of an order is doing (D25).
///
/// Where one journey is in its life (D29).
///
/// Derived from its items up to **ready**, then moved by a person: somebody
/// loads the van, and somebody says it arrived. A pickup skips `out` — nobody
/// takes a collection anywhere.
enum SubOrderStatus {
  created,
  confirmed,
  inProduction,
  ready,
  out,
  delivered,
  cancelled;

  static const _wire = {
    SubOrderStatus.created: 'created',
    SubOrderStatus.confirmed: 'confirmed',
    SubOrderStatus.inProduction: 'in_production',
    SubOrderStatus.ready: 'ready',
    SubOrderStatus.out: 'out',
    SubOrderStatus.delivered: 'delivered',
    SubOrderStatus.cancelled: 'cancelled',
  };

  String get wire => _wire[this]!;

  static SubOrderStatus parse(String s) => _wire.entries
      .firstWhere((e) => e.value == s,
          orElse: () => const MapEntry(SubOrderStatus.created, ''))
      .key;

  String get label => switch (this) {
        SubOrderStatus.created => 'Created',
        SubOrderStatus.confirmed => 'Confirmed',
        SubOrderStatus.inProduction => 'In production',
        SubOrderStatus.ready => 'Ready',
        SubOrderStatus.out => 'Out for delivery',
        SubOrderStatus.delivered => 'Delivered',
        SubOrderStatus.cancelled => 'Cancelled',
      };

  bool get isLive => this != SubOrderStatus.cancelled;
  bool get isDone =>
      this == SubOrderStatus.delivered || this == SubOrderStatus.cancelled;

  /// Past the point where the items decide: somebody has picked this up and
  /// moved it, so the derivation stops overwriting it.
  bool get isMoved =>
      this == SubOrderStatus.out || this == SubOrderStatus.delivered;

  /// The button a person is offered next, if any. `out` only for a delivery.
  SubOrderStatus? nextFor({required bool isPickup}) => switch (this) {
        SubOrderStatus.ready =>
          isPickup ? SubOrderStatus.delivered : SubOrderStatus.out,
        SubOrderStatus.out => SubOrderStatus.delivered,
        _ => null,
      };

  /// What the button says. A pickup is collected, not delivered.
  String actionFor({required bool isPickup}) => switch (this) {
        SubOrderStatus.out => 'Send out',
        SubOrderStatus.delivered => isPickup ? 'Collected' : 'Delivered',
        _ => label,
      };
}

/// Where one item is in its life (D29).
///
/// The kitchen moves it to **in production** and **ready**. It never goes
/// *out* — an item does not travel, its sub-order does — and it becomes
/// **delivered** when that sub-order does, not on its own.
enum LineStatus {
  created,
  confirmed,
  inProduction,
  ready,
  delivered,
  cancelled;

  static const _wire = {
    LineStatus.created: 'created',
    LineStatus.confirmed: 'confirmed',
    LineStatus.inProduction: 'in_production',
    LineStatus.ready: 'ready',
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

  /// The kitchen's two moves, and the two that arrive from elsewhere.
  ///
  /// `confirmed` comes from the order being confirmed, and `delivered` from
  /// the sub-order going out — neither is a button on the item.
  static const _allowed = {
    LineStatus.created: {LineStatus.confirmed, LineStatus.cancelled},
    LineStatus.confirmed: {LineStatus.inProduction, LineStatus.cancelled},
    LineStatus.inProduction: {LineStatus.ready, LineStatus.cancelled},
    LineStatus.ready: {LineStatus.delivered, LineStatus.cancelled},
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

/// The only moves a **person** makes on an order (D26).
///
/// Three moments, and nothing else: the conversation that confirms it, the
/// decision to close the books, and calling it off. Everything between —
/// in production, ready, out, delivered — is *derived from the items* by
/// [deriveOrderStatus], so it is not something anyone taps. Moving an item is
/// how those change.
///
/// `ready` and `out` are absent as destinations for a second reason: an order
/// has neither. Items are ready and go out; the order follows the last of them.
const Map<OrderStatus, Set<OrderStatus>> kAllowedTransitions = {
  OrderStatus.created: {OrderStatus.confirmed, OrderStatus.cancelled},
  OrderStatus.confirmed: {OrderStatus.cancelled},
  OrderStatus.inProduction: {OrderStatus.cancelled},
  OrderStatus.ready: {OrderStatus.cancelled},
  OrderStatus.out: {OrderStatus.cancelled},
  OrderStatus.delivered: {OrderStatus.completed},
  OrderStatus.completed: {},
  OrderStatus.cancelled: {},
};

/// The next statuses an order can move to.
///
/// No longer depends on how it is fulfilled: the pickup-skips-"out" rule lives
/// on the item now, where the fulfilment does.
Set<OrderStatus> allowedNext(OrderStatus from) =>
    kAllowedTransitions[from] ?? const {};

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

  /// Dart's default would be `Instance of 'Weight'`, and a list of mixed
  /// Strings and Weights joins without complaint — which is exactly how that
  /// text reached a customer-facing item list. The label is the only sensible
  /// thing this can ever be.
  @override
  String toString() => label;
}

class Addon {
  const Addon({required this.name, required this.price});
  final String name;
  final Money price;
}

/// One journey, with everything travelling on it (D28).
///
/// Maintained by the repository, never authored: items say when and where they
/// go, and the matching sub-order is found or made. It is a row rather than a
/// grouping key because a key cannot hold a status, a charge, a courier link
/// or a number the kitchen can say out loud.
class SubOrder {
  const SubOrder({
    required this.id,
    required this.seq,
    required this.status,
    required this.deliveryDate,
    required this.fulfilment,
    this.deliveryTime,
    this.deliveryType,
    this.addressText,
    this.pinLat,
    this.pinLng,
    this.pinUrl,
    this.deliveryCharge = Money.zero,
    this.trackingUrl,
    this.deliveredAt,
    this.lines = const [],
  });

  final String id;

  /// 1, 2, 3 … within its order. Spent, never reused.
  final int seq;

  final SubOrderStatus status;
  final int deliveryDate;
  final int? deliveryTime;
  final Fulfilment fulfilment;
  final DeliveryType? deliveryType;
  final String? addressText;
  final double? pinLat;
  final double? pinLng;
  final String? pinUrl;

  /// One journey, one charge, however many boxes are in it.
  final Money deliveryCharge;

  final String? trackingUrl;
  final int? deliveredAt;

  /// What is travelling on it.
  final List<OrderLine> lines;

  bool get isPickup => fulfilment == Fulfilment.pickup;
  bool get isLive => status.isLive;
  bool get hasPin => pinLat != null && pinLng != null;

  List<OrderLine> get liveLines => [for (final l in lines) if (l.isLive) l];

  /// What the kitchen calls it: `LLB-0001-67FR-2`.
  ///
  /// **Never in a customer message.** They bought one order; how the bakery
  /// filed it is not their business.
  String reference(String orderNo) => '$orderNo-$seq';

  /// The key that decides which journey an item belongs to: same day, same
  /// time, same way out, same place.
  static String keyOf({
    required int date,
    int? time,
    required Fulfilment fulfilment,
    String? addressText,
  }) =>
      [date, time ?? '-', fulfilment.name, addressText ?? '-'].join('|');

  String get key => keyOf(
        date: deliveryDate,
        time: deliveryTime,
        fulfilment: fulfilment,
        addressText: addressText,
      );
}

/// Where a journey has got to, given what is on it.
///
/// Derived up to **ready**; past that it is whatever a person moved it to,
/// because loading a van and arriving are facts nobody can infer from a cake.
SubOrderStatus deriveSubOrderStatus(
  SubOrderStatus stored,
  Iterable<OrderLine> lines, {
  required bool orderConfirmed,
}) {
  final all = lines.toList();
  final live = [for (final l in all) if (l.isLive) l];

  // Everything on it was called off, so the journey was too. Nobody cancels a
  // journey directly (D28) — they cancel what was on it.
  if (all.isNotEmpty && live.isEmpty) return SubOrderStatus.cancelled;

  if (stored.isMoved) return stored;
  if (!orderConfirmed) return SubOrderStatus.created;
  if (live.isEmpty) return SubOrderStatus.confirmed;

  if (live.every((l) => l.status == LineStatus.ready ||
      l.status == LineStatus.delivered)) {
    return SubOrderStatus.ready;
  }
  if (live.any((l) => l.status.index >= LineStatus.inProduction.index)) {
    return SubOrderStatus.inProduction;
  }
  return SubOrderStatus.confirmed;
}

class OrderLine {
  const OrderLine({
    required this.menuItemId,
    required this.itemName,
    required this.qty,
    required this.basePrice,
    this.id,
    this.subOrderId,
    this.flavour,
    this.weight,
    this.note,
    this.addons = const [],
    this.status = LineStatus.created,
    this.deliveredAt,
    this.itemMessage,
    this.requirements,
    this.dietaryFlags = 0,
  });

  /// Null for a line that has not been saved yet.
  final String? id;

  /// Which journey it is on. Null only on a draft, before the repository has
  /// found or made one.
  final String? subOrderId;

  final String menuItemId;
  final String itemName;
  final String? flavour;
  final Weight? weight;
  final int qty;
  final Money basePrice;
  final String? note;
  final List<Addon> addons;

  final LineStatus status;

  /// When this item actually went. Reporting dates a sale by this rather than
  /// by when it was promised.
  final int? deliveredAt;

  // ── what this item is for ──
  final String? itemMessage;
  final String? requirements;
  final int dietaryFlags;

  bool get isLive => status.isLive;

  /// The kitchen's moves. Going out and arriving belong to the sub-order.
  Set<LineStatus> get nextStatuses => status.next;

  /// base × qty + add-ons. Add-ons are priced **for the line**, not per unit.
  Money get total =>
      basePrice.times(qty) +
      addons.fold(Money.zero, (a, x) => a + x.price);
  /// Two rows with the same id are the same item, even when they are different
  /// objects — which they routinely are, because a screen re-reads the order
  /// after a move and then compares the result against lines it captured
  /// before it. Identity comparison quietly failed there and the customer was
  /// told that what had just been handed to them was still to come.
  ///
  /// A line with no id has not been saved, so there is nothing to match on and
  /// only the object itself will do.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderLine && id != null && other.id == id);

  @override
  int get hashCode => id?.hashCode ?? identityHashCode(this);

}

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

/// The order's status, from its journeys (D29).
///
/// In production as soon as **any** journey is; delivered when **every** live
/// one is. There is no ready and no out at order level: half a ready order is
/// not a thing, and an order does not travel — its journeys do.
///
/// `confirmed` and `completed` are the two a person sets, and they arrive here
/// as timestamps rather than as a status somebody typed.
OrderStatus deriveOrderStatus(
  Iterable<SubOrder> subs, {
  int? confirmedAt,
  int? completedAt,
}) {
  final all = subs.toList();
  final live = [for (final s in all) if (s.isLive) s];

  // Every journey called off means the order was.
  if (all.isNotEmpty && live.isEmpty) return OrderStatus.cancelled;
  if (confirmedAt == null) return OrderStatus.created;
  if (completedAt != null) return OrderStatus.completed;

  if (live.isNotEmpty &&
      live.every((s) => s.status == SubOrderStatus.delivered)) {
    return OrderStatus.delivered;
  }
  if (live.any((s) => s.status.index >= SubOrderStatus.inProduction.index)) {
    return OrderStatus.inProduction;
  }
  return OrderStatus.confirmed;
}

/// The dietary flags set on an item, in words.
List<String> dietaryLabels(int flags) => [
      for (final (flag, label) in const [
        (Dietary.eggless, 'Eggless'),
        (Dietary.nutFree, 'Nut-free'),
        (Dietary.glutenFree, 'Gluten-free'),
        (Dietary.sugarFree, 'Sugar-free'),
      ])
        if (flags & flag != 0) label,
    ];

/// The journey that finishes the order: the last one still to be handed over.
///
/// Its fulfilment decides how the final status is worded — an order whose last
/// journey is collected ends "Collected", one driven out ends "Delivered",
/// whatever the others were.
SubOrder? finishingSubOrder(Iterable<SubOrder> subs) {
  SubOrder? last;
  for (final s in subs) {
    if (!s.isLive) continue;
    if (last == null) {
      last = s;
      continue;
    }
    final a = s.deliveryDate, b = last.deliveryDate;
    if (a > b || (a == b && (s.deliveryTime ?? 0) > (last.deliveryTime ?? 0))) {
      last = s;
    }
  }
  return last;
}

/// When this order is finished: the **last** journey still outstanding.
///
/// An order with a cake on Friday and a snack box on Sunday answers Sunday —
/// it is not done until everything has gone. Null when nothing is outstanding,
/// which means it is waiting on money rather than on the kitchen, and sorts
/// last.
int? deriveDueDate(Iterable<SubOrder> subs) {
  int? latest;
  for (final s in subs) {
    if (s.status.isDone) continue;
    if (latest == null || s.deliveryDate > latest) latest = s.deliveryDate;
  }
  return latest;
}

/// The latest time on [deriveDueDate]'s day — the moment the order completes.
int? deriveDueTime(Iterable<SubOrder> subs) {
  final day = deriveDueDate(subs);
  if (day == null) return null;
  int? latest;
  for (final s in subs) {
    if (s.status.isDone || s.deliveryDate != day) continue;
    final t = s.deliveryTime;
    if (t == null) continue;
    if (latest == null || t > latest) latest = t;
  }
  return latest;
}

/// Whether a schedule has already been and gone.
///
/// A date with **no time is only past once the day is over** — "any time
/// today" is still ahead of you at nine in the evening, and rejecting it would
/// be wrong.
///
/// The comparison is to the minute, not the second: a phone whose clock is a
/// few seconds behind should not refuse an order for the time being typed.
bool isPastSchedule(int date, int? time, {DateTime? now}) {
  final at = now ?? DateTime.now();
  final today = DateTime(at.year, at.month, at.day).millisecondsSinceEpoch;
  if (date < today) return true;
  if (date > today || time == null) return false;
  return time < at.hour * 60 + at.minute;
}

/// The journey somebody has to act on next: the **earliest** still outstanding.
///
/// The counterpart of [finishingSubOrder], and what a list sorted by
/// [deriveNextDate] is actually showing. A card grouped under Friday must take
/// its time and its way out from Friday's journey, not from the one that
/// happens to finish the order — those are different trips on a two-day order,
/// and reading one under the other's heading is simply wrong.
SubOrder? nextSubOrder(Iterable<SubOrder> subs) {
  SubOrder? first;
  for (final s in subs) {
    if (s.status.isDone) continue;
    if (first == null) {
      first = s;
      continue;
    }
    final a = s.deliveryDate, b = first.deliveryDate;
    if (a < b ||
        (a == b && (s.deliveryTime ?? 0) < (first.deliveryTime ?? 0))) {
      first = s;
    }
  }
  return first;
}

/// When this order is next needed: the **earliest** journey still outstanding.
///
/// This is what every list sorts on. A cake on Friday and a box on Sunday
/// reads as due Sunday and sorts on Friday — because Friday is when somebody
/// has to do something about it.
int? deriveNextDate(Iterable<SubOrder> subs) {
  int? earliest;
  for (final s in subs) {
    if (s.status.isDone) continue;
    if (earliest == null || s.deliveryDate < earliest) earliest = s.deliveryDate;
  }
  return earliest;
}

/// The time of day of the earliest outstanding journey. Breaks ties within a
/// day; null means "any time" and sorts after the timed ones.
int? deriveNextTime(Iterable<SubOrder> subs) {
  final day = deriveNextDate(subs);
  if (day == null) return null;
  int? earliest;
  for (final s in subs) {
    if (s.status.isDone || s.deliveryDate != day) continue;
    final t = s.deliveryTime;
    if (t == null) continue;
    if (earliest == null || t < earliest) earliest = t;
  }
  return earliest;
}

/// What the whole order costs to send: **one charge per journey**.
Money deliveryTotal(Iterable<SubOrder> subs) {
  var total = 0;
  for (final s in subs) {
    if (s.isLive) total += s.deliveryCharge.paise;
  }
  return Money(total);
}

