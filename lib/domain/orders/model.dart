import '../../common/money.dart';

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
    this.flavour,
    this.weight,
    this.note,
    this.addons = const [],
  });

  final String menuItemId;
  final String itemName;
  final String? flavour;
  final Weight? weight;
  final int qty;
  final Money basePrice;
  final String? note;
  final List<Addon> addons;

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

  Money get subtotal => lines.fold(Money.zero, (a, l) => a + l.total);

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
