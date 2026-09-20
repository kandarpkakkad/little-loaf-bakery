import 'package:drift/drift.dart';

import '../../common/ids.dart';
import '../../common/money.dart';
import '../../platform/storage/database.dart';
import '../../platform/sync/mutations.dart';
import '../../platform/sync/op.dart';
import '../invoicing/repository.dart';
import 'model.dart';

/// An order with everything the list and the detail screen need, assembled
/// once. Totals are computed here and stored nowhere.
class OrderView {
  const OrderView({
    required this.order,
    required this.customer,
    required this.lines,
    required this.paid,
  });

  final Order order;
  final Customer customer;
  final List<OrderLine> lines;
  final Money paid;

  /// Derived from the lines, never read from the row (D26). `orders.status`
  /// still exists because a v9 peer writes it and the migration reads it, but
  /// nothing in this build treats it as the truth.
  OrderStatus get status => deriveOrderStatus(
        lines,
        confirmedAt: order.confirmedAt,
        completedAt: order.completedAt,
      );

  bool get isCancelled => status == OrderStatus.cancelled;

  /// The lines still to make or hand over.
  List<OrderLine> get liveLines => [for (final l in lines) if (l.isLive) l];

  /// When this order is finished — its last outstanding line.
  int? get dueDate => deriveDueDate(lines);
  int? get dueTime => deriveDueTime(lines);

  /// The handovers this order breaks into: lines sharing a day, a time and a
  /// destination travel together and are told about together (D25).
  List<Drop> get drops => dropsOf(lines.where((l) => l.isLive));

  /// The outstanding lines falling in `[from, to)`.
  ///
  /// The question every day-based screen actually asks. Reading the order's own
  /// date instead would hide a two-day order on the first of its days, because
  /// that date is the *last* line (D25) — and the first line is the one someone
  /// has to bake.
  Iterable<OrderLine> linesDueBetween(int from, int to) => lines.where((l) =>
      !l.status.isDone &&
      l.deliveryDate != null &&
      l.deliveryDate! >= from &&
      l.deliveryDate! < to);

  bool hasLineDueBetween(int from, int to) =>
      linesDueBetween(from, to).isNotEmpty;

  /// An outstanding line whose day has already passed.
  bool hasLineOverdueBefore(int day) => lines.any((l) =>
      !l.status.isDone && l.deliveryDate != null && l.deliveryDate! < day);

  /// What it needs *next*, which on a multi-day order is a different date.
  /// This is what the lists sort by.
  int? get nextLineDate => deriveNextLineDate(lines);
  int? get nextLineTime => deriveNextLineTime(lines);

  /// True when every line is collected rather than delivered — the wording
  /// case. A mixed order is described as a delivery, because part of it is.
  bool get isPickup => liveLines.isNotEmpty &&
      liveLines.every((l) => l.fulfilment == Fulfilment.pickup);

  /// Status wording that follows how this order is fulfilled: nothing is
  /// delivered to someone who comes and collects it.
  String get statusLabel => status.labelFor(isPickup: isPickup);

  OrderTotals get totals => OrderTotals(
        lines: lines,
        discountType: order.discountType == null
            ? null
            : (order.discountType == 'percent'
                ? DiscountType.percent
                : DiscountType.amount),
        discountValue: order.discountValue ?? 0,
        // Computed from the items, not read off the order. The column is a
        // cache — one charge per journey — and a view that read it back would
        // show a stale figure for the moment between an item moving and the
        // cache catching up.
        deliveryCharge: deliveryTotal(lines),
        paid: paid,
      );

  PaymentStatus get paymentStatus =>
      paymentStatusOf(totals, cancelled: isCancelled);

  /// Changed after the customer confirmed, and not yet acknowledged — the flag
  /// the Today screen counts.
  bool get requirementsChanged =>
      order.requirementsChangedAt != null &&
      (order.requirementsAckAt == null ||
          order.requirementsAckAt! < order.requirementsChangedAt!);
}

/// A draft line, before it has an id. What the order form builds.
/// Distinguishes "clear this field" from "do not touch it". A plain null
/// cannot: both arrive as null.
///
/// Public because callers sometimes need to say "leave this alone" explicitly —
/// a form that renders a field conditionally still has to pass *something*.
const Object kUnchanged = Object();

class DraftLine {
  DraftLine({
    required this.menuItemId,
    required this.itemName,
    this.flavour,
    this.weight,
    this.qty = 1,
    this.basePrice = Money.zero,
    this.note,
    this.addons = const [],
    this.deliveryDate,
    this.deliveryTime,
    this.fulfilment,
    this.deliveryType,
    this.addressText,
    this.pinLat,
    this.pinLng,
    this.pinUrl,
    this.itemMessage,
    this.requirements,
    this.dietaryFlags = 0,
    this.deliveryCharge,
  });

  String menuItemId;
  String itemName;
  String? flavour;
  Weight? weight;
  int qty;
  Money basePrice;
  String? note;
  List<Addon> addons;

  // ── the line's own schedule (D25) ──
  int? deliveryDate;
  int? deliveryTime;
  Fulfilment? fulfilment;
  DeliveryType? deliveryType;
  String? addressText;
  double? pinLat;
  double? pinLng;
  String? pinUrl;

  // ── what this item is for (D25 finished) ──
  String? itemMessage;
  String? requirements;
  int dietaryFlags;

  /// Null means "work it out": a line opening a new journey takes the default
  /// for its delivery type, and one joining an existing journey takes that
  /// journey's charge and adds nothing.
  Money? deliveryCharge;

  /// "Same as the item above" — a copy, not a link, so editing the first line
  /// afterwards leaves this one alone.
  void copyScheduleFrom(DraftLine other) {
    deliveryDate = other.deliveryDate;
    deliveryTime = other.deliveryTime;
    fulfilment = other.fulfilment;
    deliveryType = other.deliveryType;
    addressText = other.addressText;
    pinLat = other.pinLat;
    pinLng = other.pinLng;
    // Same journey, so the same charge — and the order counts it once.
    deliveryCharge = other.deliveryCharge;
    pinUrl = other.pinUrl;
  }

  OrderLine toLine() => OrderLine(
        menuItemId: menuItemId,
        itemName: itemName,
        flavour: flavour,
        weight: weight,
        deliveryDate: deliveryDate,
        deliveryTime: deliveryTime,
        fulfilment: fulfilment,
        deliveryType: deliveryType,
        addressText: addressText,
        pinLat: pinLat,
        pinLng: pinLng,
        pinUrl: pinUrl,
        qty: qty,
        basePrice: basePrice,
        note: note,
        addons: addons,
      );
}

class OrderRepository {
  OrderRepository(this.db, this.mutations);

  final AppDatabase db;
  final Mutations mutations;

  // ── reads ──────────────────────────────────────────────────────────────

  /// Always earliest deliverable first: delivery date, then time, then when the
  /// order was taken. An untimed order sorts after the timed ones on its day.
  ///
  /// There is deliberately no direction switch. Every list in the app reads the
  /// same way, including the finished ones — the question is always "what is
  /// due next", never "what happened most recently".
  Stream<List<OrderView>> watchOrders({
    Set<OrderStatus>? statuses,
    int? onDate,
  }) {
    final q = db.select(db.orders).join([
      innerJoin(db.customers, db.customers.id.equalsExp(db.orders.customerId)),
    ])
      ..where(db.orders.deletedAt.isNull());

    if (statuses != null && statuses.isNotEmpty) {
      q.where(db.orders.status.isIn(statuses.map((s) => s.wire).toList()));
    }
    if (onDate != null) q.where(db.orders.deliveryDate.equals(onDate));

    // Only a stable tie-break here. The real ordering is by the earliest
    // outstanding *line*, which SQL cannot see from this table any more — see
    // the sort below.
    q.orderBy([OrderingTerm.asc(db.orders.createdAt)]);

    // Same reason as watchOrder: the list shows totals, and totals come from
    // tables this query does not name.
    return _onOrderData().asyncMap((_) => q.get()).asyncMap((rows) async {
      final result = <OrderView>[];
      for (final row in rows) {
        final o = row.readTable(db.orders);
        result.add(OrderView(
          order: o,
          customer: row.readTable(db.customers),
          lines: await _linesOf(o.id),
          paid: await _paidOf(o.id),
        ));
      }
      result.sort(_byNextLine);
      return result;
    });
  }

  /// Earliest outstanding **line** first.
  ///
  /// Deliberately not the order's due date, which is its *last* line: a cake on
  /// Friday and a box on Sunday is due Sunday, but it has to appear on Friday
  /// or nobody bakes the cake. Sorting by what is needed next and showing when
  /// the order finishes are two different questions, and this is the first.
  ///
  /// Sorted here rather than in SQL because the key lives in the lines, and
  /// doing it in Dart means the sort and the screen share one derivation
  /// instead of two that can drift apart.
  static int _byNextLine(OrderView a, OrderView b) {
    // Nothing outstanding sorts last: it is waiting on money, not on the
    // kitchen.
    final da = a.nextLineDate, dbb = b.nextLineDate;
    if (da != dbb) {
      if (da == null) return 1;
      if (dbb == null) return -1;
      return da.compareTo(dbb);
    }
    final ta = a.nextLineTime, tb = b.nextLineTime;
    if (ta != tb) {
      // "any time" falls after the timed lines of that day
      if (ta == null) return 1;
      if (tb == null) return -1;
      return ta.compareTo(tb);
    }
    return a.order.createdAt.compareTo(b.order.createdAt);
  }

  Stream<OrderView?> watchOrder(String id) => _onOrderData().asyncMap((_) async {
        final row = await (db.select(db.orders).join([
          innerJoin(
              db.customers, db.customers.id.equalsExp(db.orders.customerId)),
        ])
              ..where(db.orders.id.equals(id)))
            .getSingleOrNull();
        if (row == null) return null;
        final o = row.readTable(db.orders);
        return OrderView(
          order: o,
          customer: row.readTable(db.customers),
          lines: await _linesOf(o.id),
          paid: await _paidOf(o.id),
        );
      });

  /// Fires whenever anything an [OrderView] is built from changes.
  ///
  /// A plain `.watch()` on the orders query would not do: drift re-runs a query
  /// only when a table *named in it* changes, and the totals are assembled
  /// afterwards from `payments`, `order_items` and `order_item_addons`. Taking a
  /// payment therefore left the screen showing the old balance until something
  /// else happened to touch `orders` — the money was recorded, and invisible.
  Stream<void> _onOrderData() async* {
    yield null; // the first read, before anything has changed
    yield* db.tableUpdates(TableUpdateQuery.onAllTables([
      db.orders,
      db.customers,
      db.payments,
      db.orderItems,
      db.orderItemAddons,
    ]));
  }

  Future<List<OrderLine>> _linesOf(String orderId) async {
    final items = await (db.select(db.orderItems)
          ..where((t) => t.orderId.equals(orderId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
    if (items.isEmpty) return const [];

    final addons = await (db.select(db.orderItemAddons)
          ..where((t) =>
              t.orderItemId.isIn(items.map((i) => i.id).toList()) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();

    return [
      for (final i in items)
        OrderLine(
          id: i.id,
          menuItemId: i.menuItemId,
          itemName: i.itemNameSnapshot,
          flavour: i.flavour,
          weight: Weight.maybe(i.weightValue, i.weightUnit),
          status: LineStatus.parse(i.status),
          deliveryDate: i.deliveryDate,
          deliveryTime: i.deliveryTime,
          fulfilment:
              i.fulfilment == null ? null : Fulfilment.values.firstWhere(
                  (f) => f.name == i.fulfilment,
                  orElse: () => Fulfilment.delivery),
          deliveryType: i.deliveryType == null
              ? null
              : DeliveryType.values.firstWhere((d) => d.wire == i.deliveryType,
                  orElse: () => DeliveryType.local),
          addressText: i.addressText,
          pinLat: i.pinLat,
          pinLng: i.pinLng,
          pinUrl: i.pinUrl,
          trackingUrl: i.trackingUrl,
          deliveredAt: i.deliveredAt,
          itemMessage: i.itemMessage,
          requirements: i.requirements,
          dietaryFlags: i.dietaryFlags,
          deliveryCharge: Money(i.deliveryCharge),
          qty: i.qty,
          basePrice: Money(i.basePrice),
          note: i.note,
          addons: [
            for (final a in addons.where((a) => a.orderItemId == i.id))
              Addon(name: a.name, price: Money(a.price)),
          ],
        ),
    ];
  }

  Future<Money> _paidOf(String orderId) async {
    final sum = db.payments.amount.sum();
    final row = await (db.selectOnly(db.payments)
          ..addColumns([sum])
          ..where(db.payments.orderId.equals(orderId) &
              db.payments.deletedAt.isNull()))
        .getSingle();
    return Money(row.read(sum) ?? 0);
  }

  // ── writes ─────────────────────────────────────────────────────────────

  /// Takes the next order number **from this device's own sequence**. Two
  /// devices offline at once can land on the same sequence, which is exactly
  /// why the number carries a hash of the order's UUID — the pair never
  /// collides. docs/00-overview/decisions.md D8.
  Future<String> _nextOrderNo(String orderUuid) async {
    final s = await db.select(db.settings).getSingle();
    final seq = s.orderSeq + 1;
    await db.update(db.settings).write(SettingsCompanion(orderSeq: Value(seq)));
    return orderNumber(prefix: s.invoicePrefix, seq: seq, uuid: orderUuid);
  }

  /// Creates an order from its items.
  ///
  /// There is no order-level fulfilment, address, message or requirements to
  /// pass any more: each item carries its own (D25), and what the order shows
  /// is derived from them by [_refreshOrderCache]. Passing them here as well
  /// was asking twice and letting the two answers disagree.
  Future<String> create({
    required String customerId,
    required List<DraftLine> lines,
    /// Only a **fallback** for lines that carry no date of their own. The
    /// order's own `delivery_date` is never this value — it is recomputed from
    /// the lines below, because the order is due when its last item is (D25).
    int? deliveryDate,
    int? deliveryTime,
    DiscountType? discountType,
    int discountValue = 0,
    Money advance = Money.zero,
    String advanceMode = 'upi',
  }) async {
    final id = Uuid7.generate();
    final now = DateTime.now().millisecondsSinceEpoch;
    final hlc = mutations.lastHlc.toString();

    await db.transaction(() async {
      final orderNo = await _nextOrderNo(id);

      await db.into(db.orders).insert(OrdersCompanion.insert(
            id: id,
            deviceId: mutations.deviceId,
            createdAt: now,
            updatedAtHlc: hlc,
            orderNo: orderNo,
            customerId: customerId,
            status: OrderStatus.created.wire,
            // Placeholders for two NOT NULL columns that are really caches of
            // the items. _refreshOrderCache rewrites both once the lines are
            // in, a few statements below.
            fulfilment: Fulfilment.pickup.name,
            deliveryDate: deliveryDate ??
                lines
                    .map((l) => l.deliveryDate)
                    .whereType<int>()
                    .fold<int>(0, (a, b) => b > a ? b : a),
            deliveryTime: Value(deliveryTime),
            discountType: Value(discountType?.name),
            discountValue: Value(discountType == null ? null : discountValue),
          ));

      await mutations.record('orders', id, OpKind.upsert, {
        'order_no': orderNo,
        'customer_id': customerId,
        'status': OrderStatus.created.wire,
        'delivery_date': deliveryDate,
        'delivery_time': deliveryTime,
      });

      for (var i = 0; i < lines.length; i++) {
        // A line with no date of its own falls back to the order's, so a
        // caller that knows nothing about per-line scheduling still produces
        // lines that are properly dated — which is what keeps every list
        // sorting. Everything else about how a line goes out is the line's
        // own business now.
        final l = lines[i];
        l.deliveryDate ??= deliveryDate;
        l.deliveryTime ??= deliveryTime;
        l.fulfilment ??= Fulfilment.delivery;
        if (l.fulfilment == Fulfilment.pickup) l.deliveryType = null;
        await _insertLine(id, l, i, now, hlc);
      }
      // The order is due when its last item is. Stored rather than left to the
      // reader because the column is NOT NULL and a v9 peer still reads it —
      // but it is a copy of the derivation, never something a person typed.
      await _refreshOrderCache(id, hlc);

      await _insertStatusEvent(id, null, OrderStatus.created, now, hlc);

      if (advance.paise > 0) {
        await _insertPayment(id, advance, 'advance', advanceMode, now, hlc);
      }
    });
    return id;
  }

  /// Returns the new line's id, which [addLine] hands back to the caller.
  Future<String> _insertLine(
      String orderId, DraftLine l, int position, int now, String hlc) async {
    final itemId = Uuid7.generate();
    await db.into(db.orderItems).insert(OrderItemsCompanion.insert(
          id: itemId,
          deviceId: mutations.deviceId,
          createdAt: now,
          updatedAtHlc: hlc,
          orderId: orderId,
          menuItemId: l.menuItemId,
          itemNameSnapshot: l.itemName,
          flavour: Value(l.flavour),
          weightValue: Value(l.weight?.value),
          weightUnit: Value(l.weight?.unit),
          qty: Value(l.qty),
          basePrice: l.basePrice.paise,
          note: Value(l.note),
          position: position,
          // the line's own schedule (D25)
          deliveryDate: Value(l.deliveryDate),
          deliveryTime: Value(l.deliveryTime),
          fulfilment: Value(l.fulfilment?.name),
          deliveryType: Value(
              l.fulfilment == Fulfilment.pickup ? null : l.deliveryType?.wire),
          addressText: Value(l.addressText),
          pinLat: Value(l.pinLat),
          pinLng: Value(l.pinLng),
          pinUrl: Value(l.pinUrl),
          itemMessage: Value(l.itemMessage),
          requirements: Value(l.requirements),
          dietaryFlags: Value(l.dietaryFlags),
          deliveryCharge: Value(l.deliveryCharge?.paise ?? 0),
        ));
    await mutations.record('order_items', itemId, OpKind.upsert, {
      'order_id': orderId,
      'menu_item_id': l.menuItemId,
      'item_name_snapshot': l.itemName,
      'flavour': l.flavour,
      'status': LineStatus.created.wire,
      'delivery_date': l.deliveryDate,
      'delivery_time': l.deliveryTime,
      'fulfilment': l.fulfilment?.name,
      'delivery_type':
          l.fulfilment == Fulfilment.pickup ? null : l.deliveryType?.wire,
      'address_text': l.addressText,
      'pin_lat': l.pinLat,
      'pin_lng': l.pinLng,
      'pin_url': l.pinUrl,
      'item_message': l.itemMessage,
      'requirements': l.requirements,
      'dietary_flags': l.dietaryFlags,
      'delivery_charge': l.deliveryCharge?.paise ?? 0,
      // primitives only — the payload is JSON on the wire
      'weight_value': l.weight?.value,
      'weight_unit': l.weight?.unit,
      'qty': l.qty,
      'base_price': l.basePrice.paise,
      'note': l.note,
      'position': position,
    });

    for (var j = 0; j < l.addons.length; j++) {
      final a = l.addons[j];
      final addonId = Uuid7.generate();
      await db.into(db.orderItemAddons).insert(OrderItemAddonsCompanion.insert(
            id: addonId,
            deviceId: mutations.deviceId,
            createdAt: now,
            updatedAtHlc: hlc,
            orderItemId: itemId,
            name: a.name,
            price: a.price.paise,
            position: j,
          ));
      await mutations.record('order_item_addons', addonId, OpKind.upsert, {
        'order_item_id': itemId,
        'name': a.name,
        'price': a.price.paise,
        'position': j,
      });
    }
    return itemId;
  }

  /// The app offers a move; a person takes it. An illegal move throws rather
  /// than silently doing nothing — a status that changed without anyone
  /// choosing it is the one bug this design exists to prevent.
  ///
  /// **This dispatches; it does not write a status.** The order's status is
  /// derived from its items (D26), so the three moves a person can make are
  /// the three moments the order records: confirmed, completed, cancelled.
  /// Writing a status column here instead was how confirming an order came to
  /// do nothing at all — the column said confirmed, the items stayed created,
  /// and every screen reads the items.
  Future<void> moveTo(String orderId, OrderStatus to, {String? reason}) async {
    // Checked against the **derived** status, which is what the screen used to
    // decide what to offer. Reading the stored column here meant the guard and
    // the buttons could disagree, and a legal-looking tap threw.
    final from = await _derivedStatus(orderId);
    if (!allowedNext(from).contains(to)) {
      throw StateError('${from.label} cannot become ${to.label}');
    }

    switch (to) {
      case OrderStatus.confirmed:
        return confirm(orderId);
      case OrderStatus.completed:
        return complete(orderId);
      case OrderStatus.cancelled:
        return _cancel(orderId, reason);
      default:
        // Unreachable through allowedNext, and worth saying why rather than
        // failing obscurely if someone widens the table again.
        throw StateError(
            '${to.label} is derived from the items — move the items instead');
    }
  }

  /// The order's status as everything that displays it computes it.
  Future<OrderStatus> _derivedStatus(String orderId) async {
    final o = await (db.select(db.orders)..where((t) => t.id.equals(orderId)))
        .getSingle();
    return deriveOrderStatus(
      await _linesOf(orderId),
      confirmedAt: o.confirmedAt,
      completedAt: o.completedAt,
    );
  }

  /// Calling the whole order off. Cancels every live item, so the derived
  /// status follows and the kitchen stops on all of them at once.
  Future<void> _cancel(String orderId, String? reason) async {
    if (reason == null || reason.trim().isEmpty) {
      throw StateError('Cancelling an order needs a reason');
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final hlc = mutations.lastHlc.toString();

    await db.transaction(() async {
      final from = await _derivedStatus(orderId);
      for (final l in await _linesOf(orderId)) {
        if (l.status.isLive) {
          await _writeLineStatus(
              l.id!, l.status, LineStatus.cancelled, now, hlc, reason: reason);
        }
      }
      await (db.update(db.orders)..where((t) => t.id.equals(orderId)))
          .write(OrdersCompanion(
        cancelReason: Value(reason.trim()),
        updatedAtHlc: Value(hlc),
      ));
      await mutations.record('orders', orderId, OpKind.upsert, {
        'cancel_reason': reason.trim(),
      });
      await _insertStatusEvent(
          orderId, from, OrderStatus.cancelled, now, hlc, reason: reason);
      await _refreshOrderCache(orderId, hlc);
    });
  }

  // ───────────────────── line-level moves (D25, D26) ─────────────────────

  /// Move one line. The order's own status is derived, so there is nothing to
  /// write on it — which is the whole point of D26.
  Future<void> moveLine(String lineId, LineStatus to, {String? reason}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final hlc = mutations.lastHlc.toString();

    await db.transaction(() async {
      final i = await (db.select(db.orderItems)
            ..where((t) => t.id.equals(lineId)))
          .getSingle();
      final from = LineStatus.parse(i.status);

      if (!from.canGoTo(to)) {
        throw StateError('${from.label} cannot become ${to.label}');
      }
      if (to == LineStatus.out && i.fulfilment == Fulfilment.pickup.name) {
        throw StateError('A pickup never goes out for delivery');
      }
      if (to == LineStatus.cancelled && (reason == null || reason.isEmpty)) {
        throw StateError('Cancelling a line needs a reason');
      }

      await _writeLineStatus(lineId, from, to, now, hlc, reason: reason);
      // Delivering or cancelling changes which lines are still outstanding,
      // and so which of them the order is due on.
      await _refreshOrderCache(i.orderId, hlc);

      // The bill covers the order, so it is issued once — when the last live
      // item has gone, not as each one does.
      if (to == LineStatus.delivered) {
        final after = await _linesOf(i.orderId);
        final live = after.where((l) => l.isLive);
        if (live.isNotEmpty && live.every((l) => l.status == LineStatus.delivered)) {
          await _issueInvoice(i.orderId, after);
        }
      }
    });
  }

  /// Re-derives `orders.delivery_date` / `delivery_time` from the lines.
  ///
  /// The order's delivery date is **never edited** — it is the last date among
  /// its outstanding items, and it moves when they do. The column exists
  /// because it is NOT NULL and a v9 peer still reads it; this keeps the copy
  /// honest after anything that can change a line.
  /// Rewrites everything on the order that is really a **copy of its items**.
  ///
  /// The date, the time and the status are all derived. They live on the order
  /// as columns because they are NOT NULL and a v9 peer still reads them — so
  /// they are kept as a cache, written from the items after anything that can
  /// move them, and never read back as truth by this build.
  /// Makes every item in a journey carry the same charge.
  ///
  /// A drop is derived from an item's date, time, fulfilment and address, so
  /// changing any of those moves it between journeys: it may join one that is
  /// already priced, or open a new one that is not. Run after anything that
  /// can move an item, so the stored figures match what is actually charged.
  ///
  /// The journey's price is [dropCharge] — the highest any of its items names.
  /// A newcomer therefore inherits rather than resets, and an item that leaves
  /// takes nothing away from the journey it left.
  Future<void> _normaliseDropCharges(String orderId, String hlc) async {
    for (final drop in dropsOf((await _linesOf(orderId)).where((l) => l.isLive))) {
      // Pickup is never charged: nobody is taking it anywhere.
      final agreed = drop.fulfilment == Fulfilment.pickup
          ? Money.zero
          : dropCharge(drop);

      for (final l in drop.lines) {
        if (l.deliveryCharge == agreed) continue;
        await (db.update(db.orderItems)..where((t) => t.id.equals(l.id!)))
            .write(OrderItemsCompanion(
          deliveryCharge: Value(agreed.paise),
          updatedAtHlc: Value(hlc),
        ));
        await mutations.record('order_items', l.id!, OpKind.upsert, {
          'delivery_charge': agreed.paise,
        });
      }
    }
  }

  Future<void> _refreshOrderCache(String orderId, String hlc) async {
    await _normaliseDropCharges(orderId, hlc);
    final lines = await _linesOf(orderId);
    final o = await (db.select(db.orders)..where((t) => t.id.equals(orderId)))
        .getSingle();
    final status = deriveOrderStatus(lines,
        confirmedAt: o.confirmedAt, completedAt: o.completedAt);

    // One charge per journey, not per item — see deliveryTotal.
    final delivery = deliveryTotal(lines);
    final finishing = finishingLine(lines);

    // The order's fulfilment is whichever way the *last* item goes, which is
    // what decides the wording of the message that closes the order.
    final how = finishing?.fulfilment ?? Fulfilment.pickup;
    final isPickup = how == Fulfilment.pickup;

    await (db.update(db.orders)..where((t) => t.id.equals(orderId))).write(
      OrdersCompanion(
        status: Value(status.wire),
        deliveryCharge: Value(delivery.paise),
        fulfilment: Value(how.name),
        // Cleared together with the fulfilment, or the schema's own rule is
        // broken: a pickup may carry neither a delivery type nor a courier
        // link, and leaving yesterday's behind fails the CHECK.
        deliveryType: isPickup
            ? const Value(null)
            : Value(finishing?.deliveryType?.wire),
        addressText: isPickup
            ? const Value(null)
            : Value(finishing?.addressText),
        trackingUrl:
            isPickup ? const Value(null) : Value(finishing?.trackingUrl),
        updatedAtHlc: Value(hlc),
      ),
    );
    await mutations.record('orders', orderId, OpKind.upsert, {
      'status': status.wire,
      'delivery_charge': delivery.paise,
      'fulfilment': how.name,
      'delivery_type': isPickup ? null : finishing?.deliveryType?.wire,
      'address_text': isPickup ? null : finishing?.addressText,
      'tracking_url': isPickup ? null : finishing?.trackingUrl,
    });

    // Fall back to every line once nothing is outstanding, so a fully
    // delivered order keeps the date it actually happened on rather than
    // reverting to nothing.
    final date = deriveDueDate(lines) ??
        lines
            .map((l) => l.deliveryDate)
            .whereType<int>()
            .fold<int?>(null, (a, b) => a == null || b > a ? b : a);
    if (date == null) return;
    final time = deriveDueTime(lines);

    await (db.update(db.orders)..where((t) => t.id.equals(orderId))).write(
      OrdersCompanion(
        deliveryDate: Value(date),
        deliveryTime: Value(time),
        updatedAtHlc: Value(hlc),
      ),
    );
    await mutations.record('orders', orderId, OpKind.upsert, {
      'delivery_date': date,
      'delivery_time': time,
    });
  }

  /// Change what a line is, or when and where it goes.
  ///
  /// The order's due date and status are derived, so nothing needs updating
  /// alongside this: moving a line to a later day moves the order's due date
  /// by itself, on the next read.
  Future<void> updateLine(
    String lineId, {
    Object? flavour = kUnchanged,
    Object? weight = kUnchanged,
    int? qty,
    Money? basePrice,
    Object? note = kUnchanged,
    int? deliveryDate,
    Object? deliveryTime = kUnchanged,
    Fulfilment? fulfilment,
    Object? deliveryType = kUnchanged,
    Object? addressText = kUnchanged,
    Object? pinLat = kUnchanged,
    Object? pinLng = kUnchanged,
    Object? pinUrl = kUnchanged,
    Object? itemMessage = kUnchanged,
    Object? requirements = kUnchanged,
    int? dietaryFlags,
    Money? deliveryCharge,
  }) async {
    final fields = <String, Object?>{};
    final now = DateTime.now().millisecondsSinceEpoch;
    final hlc = mutations.lastHlc.toString();

    await db.transaction(() async {
      final i = await (db.select(db.orderItems)
            ..where((t) => t.id.equals(lineId)))
          .getSingle();

      final status = LineStatus.parse(i.status);

      // A delivered or cancelled line is history. Editing what was handed over
      // would rewrite the record of what actually happened.
      if (status.isDone) {
        throw StateError('A ${status.label.toLowerCase()} item cannot be edited');
      }

      // Once the baker has started, what the item *is* stops being editable:
      // the flavour has been read and the tin weighed, so changing them now
      // changes something already half-made. When and where it goes stays
      // editable — a van can be redirected, a cake cannot be un-baked.
      final changesWhatItIs = flavour != kUnchanged ||
          weight != kUnchanged ||
          qty != null ||
          basePrice != null;
      if (status.hasStarted && changesWhatItIs) {
        throw StateError(
          'This item is already ${status.label.toLowerCase()}. Its date, time '
          'and address can still change, but not what it is.',
        );
      }

      final w = weight == kUnchanged ? null : weight as Weight?;
      final effectiveFulfilment = fulfilment ??
          (i.fulfilment == Fulfilment.pickup.name
              ? Fulfilment.pickup
              : Fulfilment.delivery);
      // A pickup goes nowhere, so it drops the two columns a delivery needs.
      final clearsDelivery = effectiveFulfilment == Fulfilment.pickup;

      await (db.update(db.orderItems)..where((t) => t.id.equals(lineId))).write(
        OrderItemsCompanion(
          flavour: flavour == kUnchanged
              ? const Value.absent()
              : Value(flavour as String?),
          weightValue:
              weight == kUnchanged ? const Value.absent() : Value(w?.value),
          weightUnit:
              weight == kUnchanged ? const Value.absent() : Value(w?.unit),
          qty: qty == null ? const Value.absent() : Value(qty),
          basePrice:
              basePrice == null ? const Value.absent() : Value(basePrice.paise),
          note: note == kUnchanged ? const Value.absent() : Value(note as String?),
          deliveryDate:
              deliveryDate == null ? const Value.absent() : Value(deliveryDate),
          deliveryTime: deliveryTime == kUnchanged
              ? const Value.absent()
              : Value(deliveryTime as int?),
          fulfilment: fulfilment == null
              ? const Value.absent()
              : Value(fulfilment.name),
          deliveryType: clearsDelivery
              ? const Value(null)
              : (deliveryType == kUnchanged
                  ? const Value.absent()
                  : Value((deliveryType as DeliveryType?)?.wire)),
          trackingUrl: clearsDelivery ? const Value(null) : const Value.absent(),
          addressText: addressText == kUnchanged
              ? const Value.absent()
              : Value(addressText as String?),
          pinLat: pinLat == kUnchanged
              ? const Value.absent()
              : Value(pinLat as double?),
          pinLng: pinLng == kUnchanged
              ? const Value.absent()
              : Value(pinLng as double?),
          pinUrl: pinUrl == kUnchanged
              ? const Value.absent()
              : Value(pinUrl as String?),
          itemMessage: itemMessage == kUnchanged
              ? const Value.absent()
              : Value(itemMessage as String?),
          requirements: requirements == kUnchanged
              ? const Value.absent()
              : Value(requirements as String?),
          dietaryFlags: dietaryFlags == null
              ? const Value.absent()
              : Value(dietaryFlags),
          deliveryCharge: deliveryCharge == null
              ? const Value.absent()
              : Value(deliveryCharge.paise),
          updatedAtHlc: Value(hlc),
        ),
      );

      if (flavour != kUnchanged) fields['flavour'] = flavour;
      if (weight != kUnchanged) {
        fields['weight_value'] = w?.value;
        fields['weight_unit'] = w?.unit;
      }
      if (qty != null) fields['qty'] = qty;
      if (basePrice != null) fields['base_price'] = basePrice.paise;
      if (note != kUnchanged) fields['note'] = note;
      if (deliveryDate != null) fields['delivery_date'] = deliveryDate;
      if (deliveryTime != kUnchanged) fields['delivery_time'] = deliveryTime;
      if (fulfilment != null) fields['fulfilment'] = fulfilment.name;
      if (clearsDelivery) {
        fields['delivery_type'] = null;
        fields['tracking_url'] = null;
      } else if (deliveryType != kUnchanged) {
        fields['delivery_type'] = (deliveryType as DeliveryType?)?.wire;
      }
      if (addressText != kUnchanged) fields['address_text'] = addressText;
      if (pinLat != kUnchanged) fields['pin_lat'] = pinLat;
      if (pinLng != kUnchanged) fields['pin_lng'] = pinLng;
      if (pinUrl != kUnchanged) fields['pin_url'] = pinUrl;
      if (itemMessage != kUnchanged) fields['item_message'] = itemMessage;
      if (requirements != kUnchanged) fields['requirements'] = requirements;
      if (dietaryFlags != null) fields['dietary_flags'] = dietaryFlags;
      if (deliveryCharge != null) {
        fields['delivery_charge'] = deliveryCharge.paise;
      }

      if (fields.isNotEmpty) {
        await mutations.record('order_items', lineId, OpKind.upsert, fields);
      }
      // Touch the order so a list watching it redraws, and so the edit has an
      // HLC of its own for the merge.
      await (db.update(db.orders)..where((t) => t.id.equals(i.orderId)))
          .write(OrdersCompanion(updatedAtHlc: Value(hlc)));

      // Moving an item can move it between journeys — a different day, a
      // different address — so the charges and everything the order caches
      // from its items are worked out again.
      await _refreshOrderCache(i.orderId, hlc);
      if (fields.isNotEmpty) {
        await _insertStatusEvent(i.orderId, null, OrderStatus.inProduction, now,
            hlc, reason: 'item edited');
      }
      if (deliveryDate != null || deliveryTime != kUnchanged) {
        await _refreshOrderCache(i.orderId, hlc);
      }
    });
  }

  /// Add a line to an order that already exists.
  Future<String> addLine(String orderId, DraftLine line) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final hlc = mutations.lastHlc.toString();
    late String id;
    await db.transaction(() async {
      final existing = await (db.select(db.orderItems)
            ..where((t) => t.orderId.equals(orderId) & t.deletedAt.isNull()))
          .get();
      final position = existing.fold<int>(-1, (a, i) => i.position > a ? i.position : a) + 1;
      id = await _insertLine(orderId, line, position, now, hlc);

      // An item added to an order already agreed with the customer is agreed
      // too — it arrived through the same conversation. Leaving it at `created`
      // would make the order look unconfirmed again.
      final o = await (db.select(db.orders)..where((t) => t.id.equals(orderId)))
          .getSingle();
      if (o.confirmedAt != null) {
        await _writeLineStatus(
            id, LineStatus.created, LineStatus.confirmed, now, hlc);
      }
      await _refreshOrderCache(orderId, hlc);
    });
    return id;
  }

  /// Catch every line up to [to] in one gesture.
  ///
  /// Deriving the order status costs the one-tap "the whole order is ready"
  /// move; this is it, expressed over lines. Lines that cannot legally reach
  /// [to] are skipped in silence — the intent is "catch everything up", and
  /// refusing the batch because one line is already delivered would be a worse
  /// reading of it.
  Future<int> moveAllLines(String orderId, LineStatus to) async {
    final lines = await (db.select(db.orderItems)
          ..where((t) => t.orderId.equals(orderId) & t.deletedAt.isNull()))
        .get();
    var moved = 0;
    for (final i in lines) {
      final from = LineStatus.parse(i.status);
      if (!from.canGoTo(to)) continue;
      if (to == LineStatus.out && i.fulfilment == Fulfilment.pickup.name) {
        continue;
      }
      await moveLine(i.id, to);
      moved++;
    }
    return moved;
  }

  /// The order-level moments a person writes, because neither is a fact about
  /// lines (D26).
  Future<void> confirm(String orderId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final hlc = mutations.lastHlc.toString();
    await db.transaction(() async {
      final lines = await _linesOf(orderId);
      if (lines.isEmpty) throw StateError('An order needs at least one item');
      if (lines.any((l) => l.deliveryDate == null)) {
        throw StateError('Every item needs a delivery date');
      }
      await (db.update(db.orders)..where((t) => t.id.equals(orderId))).write(
        OrdersCompanion(confirmedAt: Value(now), updatedAtHlc: Value(hlc)),
      );
      await mutations.record('orders', orderId, OpKind.upsert, {
        'confirmed_at': now,
      });
      // An item is confirmed when its order is — that step belongs to the
      // conversation with the customer, not to the kitchen. After this each
      // item moves on its own.
      for (final l in lines) {
        if (l.status == LineStatus.created) {
          await _writeLineStatus(l.id!, LineStatus.created, LineStatus.confirmed,
              now, hlc);
        }
      }
      await _insertStatusEvent(
          orderId, OrderStatus.created, OrderStatus.confirmed, now, hlc);
      await _refreshOrderCache(orderId, hlc);
    });
  }

  /// Closing the books. Refused while money is owed **in either direction**:
  /// an order in credit owes a refund, and "completed" would bury it.
  Future<void> complete(String orderId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final hlc = mutations.lastHlc.toString();
    await db.transaction(() async {
      final o = await (db.select(db.orders)..where((t) => t.id.equals(orderId)))
          .getSingle();
      final totals = OrderTotals(
        lines: await _linesOf(orderId),
        discountType: o.discountType == null
            ? null
            : DiscountType.values.byName(o.discountType!),
        discountValue: o.discountValue ?? 0,
        deliveryCharge: Money(o.deliveryCharge),
        paid: await _paidOf(orderId),
      );
      if (totals.hasBalance) {
        throw StateError('Cannot complete: '
            '₹${(totals.balanceDue.paise / 100).toStringAsFixed(2)} still due');
      }
      if (totals.inCredit) {
        throw StateError('Cannot complete: '
            '₹${(totals.creditDue.paise / 100).toStringAsFixed(2)} to refund');
      }
      await (db.update(db.orders)..where((t) => t.id.equals(orderId)))
          .write(OrdersCompanion(
        completedAt: Value(now),
        updatedAtHlc: Value(hlc),
      ));
      await mutations.record('orders', orderId, OpKind.upsert, {
        'completed_at': now,
      });
      await _insertStatusEvent(
          orderId, OrderStatus.delivered, OrderStatus.completed, now, hlc);
      await _refreshOrderCache(orderId, hlc);
    });
  }

  /// The one place a line's status is written, so confirming an order and
  /// moving a single item cannot drift apart.
  Future<void> _writeLineStatus(
    String lineId,
    LineStatus from,
    LineStatus to,
    int now,
    String hlc, {
    String? reason,
  }) async {
    await (db.update(db.orderItems)..where((t) => t.id.equals(lineId))).write(
      OrderItemsCompanion(
        status: Value(to.wire),
        updatedAtHlc: Value(hlc),
        deliveredAt:
            to == LineStatus.delivered ? Value(now) : const Value.absent(),
        cancelReason:
            to == LineStatus.cancelled ? Value(reason) : const Value.absent(),
      ),
    );
    await mutations.record('order_items', lineId, OpKind.upsert, {
      'status': to.wire,
      if (to == LineStatus.delivered) 'delivered_at': now,
      if (to == LineStatus.cancelled) 'cancel_reason': reason,
    });
    await _insertLineEvent(lineId, from, to, now, hlc, reason: reason);
  }

  /// Issued here rather than by the UI so a peer's op, a bulk move and a tap
  /// all produce exactly one invoice. [InvoiceRepository.issue] is idempotent,
  /// which is what makes that safe.
  Future<void> _issueInvoice(String orderId, List<OrderLine> lines) async {
    final o = await (db.select(db.orders)..where((t) => t.id.equals(orderId)))
        .getSingle();
    await InvoiceRepository(db, mutations).issue(
      orderId: orderId,
      lines: lines,
      totals: OrderTotals(
        lines: lines,
        discountType: o.discountType == null
            ? null
            : DiscountType.values.byName(o.discountType!),
        discountValue: o.discountValue ?? 0,
        deliveryCharge: Money(o.deliveryCharge),
        paid: await _paidOf(orderId),
      ),
    );
  }

  Future<void> _insertLineEvent(
    String lineId,
    LineStatus from,
    LineStatus to,
    int at,
    String hlc, {
    String? reason,
  }) async {
    final id = Uuid7.generate();
    await db.into(db.orderItemStatusEvents).insert(
          OrderItemStatusEventsCompanion.insert(
            id: id,
            deviceId: mutations.deviceId,
            createdAt: at,
            updatedAtHlc: hlc,
            orderItemId: lineId,
            fromStatus: Value(from.wire),
            toStatus: to.wire,
            reason: Value(reason),
            at: at,
          ),
        );
    await mutations.record('order_item_status_events', id, OpKind.upsert, {
      'order_item_id': lineId,
      'from_status': from.wire,
      'to_status': to.wire,
      'reason': reason,
      'at': at,
    });
  }

  Future<void> _insertStatusEvent(
    String orderId,
    OrderStatus? from,
    OrderStatus to,
    int now,
    String hlc, {
    String? reason,
  }) async {
    final id = Uuid7.generate();
    await db.into(db.orderStatusEvents).insert(OrderStatusEventsCompanion.insert(
          id: id,
          deviceId: mutations.deviceId,
          createdAt: now,
          updatedAtHlc: hlc,
          orderId: orderId,
          fromStatus: Value(from?.wire),
          toStatus: to.wire,
          reason: Value(reason),
          at: now,
        ));
    await mutations.record('order_status_events', id, OpKind.upsert, {
      'order_id': orderId,
      'from_status': from?.wire,
      'to_status': to.wire,
      'reason': reason,
      'at': now,
    });
  }

  /// The delivery charge is the one number that legitimately changes after the
  /// order is taken — it is often known only when someone actually goes.
  /// Change an order after it was taken.
  ///
  /// Everything here is a detail *about* the order. The items and the special
  /// requirements are not: the kitchen has read them and may have acted on
  /// them, so they move through their own flows.
  ///
  /// The message on the item sits between the two — it can still change while
  /// the item is being made, which is why the caller decides whether to pass
  /// it rather than this refusing outright. See [canEditItemMessage].
  ///
  /// One op for the whole edit, not one per field: the fields changed together
  /// and a peer applying them together is what keeps a half-moved order from
  /// ever existing.
  Future<void> updateDetails(
    String orderId, {
    Fulfilment? fulfilment,
    // No deliveryDate or deliveryTime. The order's are derived from its items
    // and are not a thing anyone edits (D25) — editing them here would write a
    // value the next line change silently overwrote.
    DeliveryType? deliveryType,
    Object? addressText = kUnchanged,
    Object? pinLat = kUnchanged,
    Object? pinLng = kUnchanged,
    Object? pinUrl = kUnchanged,
    Object? discountType = kUnchanged,
    int? discountValue,

    int? dietaryFlags,
    Object? notes = kUnchanged,
    Object? itemMessage = kUnchanged,
  }) async {
    // A pickup carries neither a delivery type nor a tracking link — the schema
    // has a CHECK for it, so clear them here rather than failing the write.
    final becomingPickup = fulfilment == Fulfilment.pickup;

    final fields = <String, Object?>{
      if (fulfilment != null) 'fulfilment': fulfilment.name,
      if (becomingPickup)
        'delivery_type': null
      else if (deliveryType != null)
        'delivery_type': deliveryType.wire,
      if (becomingPickup) 'tracking_url': null,
      if (addressText != kUnchanged) 'address_text': addressText,
      if (pinLat != kUnchanged) 'pin_lat': pinLat,
      if (pinLng != kUnchanged) 'pin_lng': pinLng,
      if (pinUrl != kUnchanged) 'pin_url': pinUrl,
      if (discountType != kUnchanged)
        'discount_type': (discountType as DiscountType?)?.name,
      if (discountValue != null) 'discount_value': discountValue,
      if (dietaryFlags != null) 'dietary_flags': dietaryFlags,
      if (notes != kUnchanged) 'notes': notes,
      if (itemMessage != kUnchanged) 'item_message': itemMessage,
    };
    if (fields.isEmpty) return;

    await db.transaction(() async {
      await (db.update(db.orders)..where((t) => t.id.equals(orderId))).write(
        OrdersCompanion(
          fulfilment:
              fulfilment == null ? const Value.absent() : Value(fulfilment.name),
          deliveryType: becomingPickup
              ? const Value(null)
              : (deliveryType == null
                  ? const Value.absent()
                  : Value(deliveryType.wire)),
          trackingUrl: becomingPickup ? const Value(null) : const Value.absent(),
          addressText: addressText == kUnchanged
              ? const Value.absent()
              : Value(addressText as String?),
          pinLat:
              pinLat == kUnchanged ? const Value.absent() : Value(pinLat as double?),
          pinLng:
              pinLng == kUnchanged ? const Value.absent() : Value(pinLng as double?),
          pinUrl:
              pinUrl == kUnchanged ? const Value.absent() : Value(pinUrl as String?),
          discountType: discountType == kUnchanged
              ? const Value.absent()
              : Value((discountType as DiscountType?)?.name),
          discountValue: discountValue == null
              ? const Value.absent()
              : Value(discountValue),
          dietaryFlags:
              dietaryFlags == null ? const Value.absent() : Value(dietaryFlags),
          notes: notes == kUnchanged ? const Value.absent() : Value(notes as String?),
          itemMessage: itemMessage == kUnchanged
              ? const Value.absent()
              : Value(itemMessage as String?),
          updatedAtHlc: Value(mutations.lastHlc.toString()),
        ),
      );
      await mutations.record('orders', orderId, OpKind.upsert, fields);
    });
  }

  Future<void> setDeliveryCharge(String orderId, Money amount) async {
    await db.transaction(() async {
      await (db.update(db.orders)..where((t) => t.id.equals(orderId))).write(
        OrdersCompanion(
          deliveryCharge: Value(amount.paise),
          updatedAtHlc: Value(mutations.lastHlc.toString()),
        ),
      );
      await mutations.record(
          'orders', orderId, OpKind.upsert, {'delivery_charge': amount.paise});
    });
  }

  Future<void> setTrackingUrl(String orderId, String url) async {
    await db.transaction(() async {
      await (db.update(db.orders)..where((t) => t.id.equals(orderId))).write(
        OrdersCompanion(
          trackingUrl: Value(url),
          updatedAtHlc: Value(mutations.lastHlc.toString()),
        ),
      );
      await mutations
          .record('orders', orderId, OpKind.upsert, {'tracking_url': url});
    });
  }

  Future<void> acknowledgeRequirements(String orderId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await (db.update(db.orders)..where((t) => t.id.equals(orderId))).write(
        OrdersCompanion(
          requirementsAckAt: Value(now),
          updatedAtHlc: Value(mutations.lastHlc.toString()),
        ),
      );
      await mutations.record(
          'orders', orderId, OpKind.upsert, {'requirements_ack_at': now});
    });
  }

  Future<void> addPayment({
    required String orderId,
    required Money amount,
    required String kind,
    required String mode,
    String? reference,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await _insertPayment(
          orderId, amount, kind, mode, now, mutations.lastHlc.toString(),
          reference: reference);
    });
  }

  Future<void> _insertPayment(
    String orderId,
    Money amount,
    String kind,
    String mode,
    int now,
    String hlc, {
    String? reference,
  }) async {
    final id = Uuid7.generate();
    await db.into(db.payments).insert(PaymentsCompanion.insert(
          id: id,
          deviceId: mutations.deviceId,
          createdAt: now,
          updatedAtHlc: hlc,
          orderId: orderId,
          amount: amount.paise,
          kind: kind,
          mode: mode,
          reference: Value(reference),
          paidAt: now,
        ));
    await mutations.record('payments', id, OpKind.upsert, {
      'order_id': orderId,
      'amount': amount.paise,
      'kind': kind,
      'mode': mode,
      'reference': reference,
      'paid_at': now,
    });
  }

  /// Records that a message was composed and the share sheet launched. The app
  /// cannot know it was actually sent — only that it was handed to WhatsApp.
  Future<void> logShare(String orderId, String kind, {bool launched = true}) async {
    final id = Uuid7.generate();
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await db.into(db.shareLog).insert(ShareLogCompanion.insert(
            id: id,
            deviceId: mutations.deviceId,
            createdAt: now,
            updatedAtHlc: mutations.lastHlc.toString(),
            orderId: orderId,
            kind: kind,
            composedAt: now,
            sharedAt: Value(launched ? now : null),
          ));
      await mutations.record('share_log', id, OpKind.upsert, {
        'order_id': orderId,
        'kind': kind,
        'composed_at': now,
        'shared_at': launched ? now : null,
      });
    });
  }

}
