import 'package:drift/drift.dart';

import '../../common/money.dart';
import '../../platform/storage/database.dart';
import '../orders/model.dart';
import '../orders/repository.dart';

/// One month of trade.
class MonthOfSales {
  const MonthOfSales({
    required this.month,
    required this.orders,
    required this.revenue,
    required this.collected,
  });

  /// Local midnight on the first of the month, so it sorts and formats like
  /// every other date in the app.
  final int month;
  final int orders;

  /// What was billed. [collected] is what actually arrived — the two differ
  /// whenever someone is still to pay, which is the number worth seeing.
  final Money revenue;
  final Money collected;

  Money get outstanding => Money(revenue.paise - collected.paise);
}

class ProductSales {
  const ProductSales({
    required this.menuItemId,
    required this.name,
    required this.qty,
    required this.revenue,
  });

  final String menuItemId;
  final String name;
  final int qty;
  final Money revenue;
}

class StockValue {
  const StockValue({required this.name, required this.onHand, required this.value});

  final String name;
  final double onHand;

  /// Null when the material has never been bought at a known price — the app
  /// says it does not know rather than valuing it at zero.
  final Money? value;
}

/// The handful of questions the owner actually asks.
///
/// Computed in Dart over [OrderTotals] rather than in SQL. The design called
/// for a `v_order_totals` view as "the single definition of a total", but the
/// app has one already — `OrderTotals` — and every screen uses it. A SQL copy
/// would be a *second* definition, and the two would drift the first time a
/// rule changed: cancelled items leaving the total, credit, a discount
/// resolved at invoice. At a bakery's volumes the cost of doing it in Dart is
/// nothing, and the cost of two definitions is a report that disagrees with
/// the screen.
///
/// docs/02-domain/reporting/lld.md
class ReportRepository {
  ReportRepository(this.db, this.orders);

  final AppDatabase db;
  final OrderRepository orders;

  /// Revenue counts an order once it is **delivered**, and drops it again if
  /// its invoice was voided — a voided bill is a sale that did not happen.
  Future<List<MonthOfSales>> salesByMonth({int months = 12}) async {
    final views = await _billableOrders();
    final byMonth = <int, List<OrderView>>{};

    for (final v in views) {
      final d = DateTime.fromMillisecondsSinceEpoch(v.soldOn);
      final key = DateTime(d.year, d.month).millisecondsSinceEpoch;
      byMonth.putIfAbsent(key, () => []).add(v);
    }

    final out = [
      for (final e in byMonth.entries)
        MonthOfSales(
          month: e.key,
          orders: e.value.length,
          revenue: e.value.fold(Money.zero, (a, v) => a + v.totals.total),
          collected: e.value.fold(Money.zero, (a, v) => a + v.totals.paid),
        ),
    ]..sort((a, b) => b.month.compareTo(a.month));

    return out.take(months).toList();
  }

  /// Grouped by `menu_item_id`, never by name, so renaming an item does not
  /// split its own history in two (D16).
  Future<List<ProductSales>> byProduct({int? from, int? to}) async {
    final views = await _billableOrders();
    final qty = <String, int>{};
    final revenue = <String, Money>{};
    final names = <String, String>{};

    for (final v in views) {
      final on = v.soldOn;
      if (from != null && on < from) continue;
      if (to != null && on >= to) continue;
      for (final l in v.lines) {
        if (!l.isLive) continue;
        qty[l.menuItemId] = (qty[l.menuItemId] ?? 0) + l.qty;
        revenue[l.menuItemId] = (revenue[l.menuItemId] ?? Money.zero) + l.total;
        // The most recent snapshot wins the label, so a report reads in
        // today's words while still grouping on yesterday's id.
        names[l.menuItemId] = l.itemName;
      }
    }

    return [
      for (final id in qty.keys)
        ProductSales(
          menuItemId: id,
          name: names[id] ?? id,
          qty: qty[id]!,
          revenue: revenue[id] ?? Money.zero,
        ),
    ]..sort((a, b) => b.revenue.paise.compareTo(a.revenue.paise));
  }

  /// Every order that landed in one month, newest first.
  ///
  /// Dated by [OrderView.soldOn] — when the last item actually went, falling
  /// back to the order's own date for anything still outstanding. The same
  /// rule the chart, the top-items list and the card's own date label use.
  ///
  /// It used to read `order.deliveryDate`, which is a cache of the *promised*
  /// date, so the list and the chart above it could disagree about which
  /// orders September contained.
  ///
  /// Includes orders that have not gone out yet — for the current month that
  /// is most of them — and excludes cancelled ones, which were never trade.
  Future<List<OrderView>> ordersIn(int year, int month) async {
    final from = DateTime(year, month).millisecondsSinceEpoch;
    final to = DateTime(year, month + 1).millisecondsSinceEpoch;

    final all = await orders.watchOrders().first;
    return [
      for (final v in all)
        if (!v.isCancelled && v.soldOn >= from && v.soldOn < to) v,
    ]..sort((a, b) => b.soldOn.compareTo(a.soldOn));
  }

  /// The month of the earliest order there is, so a picker knows how far back
  /// it can go rather than offering empty years.
  Future<DateTime?> firstMonth() async {
    final all = await orders.watchOrders().first;
    if (all.isEmpty) return null;
    final earliest = all.map((v) => v.soldOn).reduce((a, b) => a < b ? a : b);
    final d = DateTime.fromMillisecondsSinceEpoch(earliest);
    return DateTime(d.year, d.month);
  }

  /// Money owed across every order that is not yet settled.
  Future<Money> outstanding() async {
    final all = await orders.watchOrders().first;
    var owed = Money.zero;
    for (final v in all) {
      if (!v.isCancelled && v.totals.hasBalance) owed += v.totals.balanceDue;
    }
    return owed;
  }

  /// What is owed *back* — an order that was paid and then had an item
  /// cancelled. Small, and invisible unless something looks for it.
  Future<Money> credit() async {
    final all = await orders.watchOrders().first;
    var owed = Money.zero;
    for (final v in all) {
      if (!v.isCancelled && v.totals.inCredit) owed += v.totals.creditDue;
    }
    return owed;
  }

  /// What the shelf is worth, at the last price each material was bought for.
  Future<List<StockValue>> stockValue() async {
    final rows = await db.customSelect('''
      SELECT m.id, m.name, m.unit,
             COALESCE((
               SELECT CASE WHEN t.kind = 'count'
                           THEN t.qty
                           ELSE NULL END
                 FROM stock_transactions t
                WHERE t.material_id = m.id AND t.deleted_at IS NULL
                  AND t.kind = 'count'
             ORDER BY t.at DESC LIMIT 1), 0) AS last_count
        FROM materials m
       WHERE m.deleted_at IS NULL AND m.active = 1
       ORDER BY m.name
    ''').get();

    final out = <StockValue>[];
    for (final r in rows) {
      final id = r.read<String>('id');
      final level = await _levelOf(id);
      final rate = await _lastRateOf(id);
      out.add(StockValue(
        name: r.read<String>('name'),
        onHand: level,
        value: rate == null ? null : Money((rate.paise * level).round()),
      ));
    }
    return out;
  }

  // ── the parts every report shares ────────────────────────────────────────

  /// Orders that count as trade: delivered or completed, not cancelled, and
  /// not carrying a voided invoice.
  Future<List<OrderView>> _billableOrders() async {
    final all = await orders.watchOrders().first;
    final voided = await _voidedOrderIds();
    return [
      for (final v in all)
        if (!v.isCancelled &&
            (v.status == OrderStatus.delivered ||
                v.status == OrderStatus.completed) &&
            !voided.contains(v.order.id))
          v,
    ];
  }

  Future<Set<String>> _voidedOrderIds() async {
    final rows = await (db.select(db.invoices)
          ..where((t) => t.voidedAt.isNotNull() & t.deletedAt.isNull()))
        .get();
    return {for (final r in rows) r.orderId};
  }

  Future<double> _levelOf(String materialId) async {
    final rows = await (db.select(db.stockTransactions)
          ..where((t) => t.materialId.equals(materialId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.at)]))
        .get();
    var level = 0.0;
    for (final t in rows) {
      switch (t.kind) {
        case 'count':
          level = t.qty; // absolute, not a delta
        case 'in':
          level += t.qty;
        case 'consume' || 'waste':
          level -= t.qty;
      }
    }
    return level;
  }

  Future<Money?> _lastRateOf(String materialId) async {
    final rows = await (db.select(db.stockTransactions)
          ..where((t) =>
              t.materialId.equals(materialId) &
              t.kind.equals('in') &
              t.amount.isNotNull() &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.at)])
          ..limit(1))
        .getSingleOrNull();
    if (rows == null || rows.qty <= 0) return null;
    return Money((rows.amount! / rows.qty).round());
  }
}
