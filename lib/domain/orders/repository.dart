import 'package:drift/drift.dart';

import '../../common/ids.dart';
import '../../common/money.dart';
import '../../platform/storage/database.dart';
import '../../platform/sync/mutations.dart';
import '../../platform/sync/op.dart';
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

  OrderStatus get status => OrderStatus.parse(order.status);
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get isPickup => order.fulfilment == 'pickup';

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
        deliveryCharge: Money(order.deliveryCharge),
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
  });

  String menuItemId;
  String itemName;
  String? flavour;
  Weight? weight;
  int qty;
  Money basePrice;
  String? note;
  List<Addon> addons;

  OrderLine toLine() => OrderLine(
        menuItemId: menuItemId,
        itemName: itemName,
        flavour: flavour,
        weight: weight,
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

    q.orderBy([
      OrderingTerm.asc(db.orders.deliveryDate),
      // NULLs last so "any time" falls after the timed orders of that day
      OrderingTerm(
        expression: db.orders.deliveryTime,
        mode: OrderingMode.asc,
        nulls: NullsOrder.last,
      ),
      OrderingTerm.asc(db.orders.createdAt),
    ]);

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
      return result;
    });
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
          menuItemId: i.menuItemId,
          itemName: i.itemNameSnapshot,
          flavour: i.flavour,
          weight: Weight.maybe(i.weightValue, i.weightUnit),
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

  Future<String> create({
    required String customerId,
    required List<DraftLine> lines,
    required Fulfilment fulfilment,
    required int deliveryDate,
    int? deliveryTime,
    DeliveryType? deliveryType,
    String? addressText,
    double? pinLat,
    double? pinLng,
    String? pinUrl,
    DiscountType? discountType,
    int discountValue = 0,
    Money deliveryCharge = Money.zero,
    String? requirements,
    String? itemMessage,
    int dietaryFlags = 0,
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
            fulfilment: fulfilment.name,
            deliveryDate: deliveryDate,
            deliveryTime: Value(deliveryTime),
            deliveryType:
                Value(fulfilment == Fulfilment.delivery ? deliveryType?.wire : null),
            addressText: Value(addressText),
            pinLat: Value(pinLat),
            pinLng: Value(pinLng),
            pinUrl: Value(pinUrl),
            discountType: Value(discountType?.name),
            discountValue: Value(discountType == null ? null : discountValue),
            deliveryCharge: Value(deliveryCharge.paise),
            requirements: Value(requirements),
            itemMessage: Value(itemMessage),
            dietaryFlags: Value(dietaryFlags),
          ));

      await mutations.record('orders', id, OpKind.upsert, {
        'order_no': orderNo,
        'customer_id': customerId,
        'status': OrderStatus.created.wire,
        'fulfilment': fulfilment.name,
        'delivery_date': deliveryDate,
        'delivery_time': deliveryTime,
        'delivery_charge': deliveryCharge.paise,
      });

      for (var i = 0; i < lines.length; i++) {
        await _insertLine(id, lines[i], i, now, hlc);
      }

      await _insertStatusEvent(id, null, OrderStatus.created, now, hlc);

      if (advance.paise > 0) {
        await _insertPayment(id, advance, 'advance', advanceMode, now, hlc);
      }
    });
    return id;
  }

  Future<void> _insertLine(
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
        ));
    await mutations.record('order_items', itemId, OpKind.upsert, {
      'order_id': orderId,
      'menu_item_id': l.menuItemId,
      'item_name_snapshot': l.itemName,
      'flavour': l.flavour,
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
  }

  /// The app offers a move; a person takes it. An illegal move throws rather
  /// than silently doing nothing — a status that changed without anyone
  /// choosing it is the one bug this design exists to prevent.
  Future<void> moveTo(String orderId, OrderStatus to, {String? reason}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final hlc = mutations.lastHlc.toString();
    await db.transaction(() async {
      final o = await (db.select(db.orders)..where((t) => t.id.equals(orderId)))
          .getSingle();
      final from = OrderStatus.parse(o.status);
      // Pickup skips "out for delivery", so what is legal depends on the order.
      final isPickup = o.fulfilment == 'pickup';
      if (!allowedNext(from, isPickup: isPickup).contains(to)) {
        throw StateError('${from.label} cannot become ${to.label}');
      }

      // Completing is the act of closing the books on an order, so it cannot
      // happen while money is still owed. Enforced here rather than only in the
      // UI: a stale screen, or a peer's op, must not be able to close an order
      // that is still short.
      if (to == OrderStatus.completed) {
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
      }
      await (db.update(db.orders)..where((t) => t.id.equals(orderId))).write(
        OrdersCompanion(
          status: Value(to.wire),
          updatedAtHlc: Value(hlc),
          cancelReason: to == OrderStatus.cancelled ? Value(reason) : const Value.absent(),
          deliveredAt:
              to == OrderStatus.delivered ? Value(now) : const Value.absent(),
        ),
      );
      await mutations.record('orders', orderId, OpKind.upsert, {
        'status': to.wire,
        if (to == OrderStatus.cancelled) 'cancel_reason': reason,
        if (to == OrderStatus.delivered) 'delivered_at': now,
      });
      await _insertStatusEvent(orderId, from, to, now, hlc, reason: reason);
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
    int? deliveryDate,
    Object? deliveryTime = kUnchanged,
    DeliveryType? deliveryType,
    Object? addressText = kUnchanged,
    Object? pinLat = kUnchanged,
    Object? pinLng = kUnchanged,
    Object? pinUrl = kUnchanged,
    Object? discountType = kUnchanged,
    int? discountValue,
    Money? deliveryCharge,
    int? dietaryFlags,
    Object? notes = kUnchanged,
    Object? itemMessage = kUnchanged,
  }) async {
    // A pickup carries neither a delivery type nor a tracking link — the schema
    // has a CHECK for it, so clear them here rather than failing the write.
    final becomingPickup = fulfilment == Fulfilment.pickup;

    final fields = <String, Object?>{
      if (fulfilment != null) 'fulfilment': fulfilment.name,
      if (deliveryDate != null) 'delivery_date': deliveryDate,
      if (deliveryTime != kUnchanged) 'delivery_time': deliveryTime,
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
      if (deliveryCharge != null) 'delivery_charge': deliveryCharge.paise,
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
          deliveryDate:
              deliveryDate == null ? const Value.absent() : Value(deliveryDate),
          deliveryTime: deliveryTime == kUnchanged
              ? const Value.absent()
              : Value(deliveryTime as int?),
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
          deliveryCharge: deliveryCharge == null
              ? const Value.absent()
              : Value(deliveryCharge.paise),
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
