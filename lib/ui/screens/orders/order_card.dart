import 'package:flutter/material.dart';

import '../../../domain/orders/model.dart';
import '../../../domain/orders/repository.dart';
import '../../theme/format.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import 'order_detail_screen.dart';

/// One order, small enough to scan a list of them and complete enough that
/// opening it is a choice rather than a necessity.
class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.view,
    this.showDate = false,
    this.onTap,
    this.selected = false,
  });

  final OrderView view;
  final bool showDate;

  /// Null on a phone, where tapping pushes the detail screen. Supplied by the
  /// two-pane layout, where tapping selects into the pane instead.
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final o = view.order;
    final t = view.totals;
    final shown = view.shownJourney;

    return InkWell(
      onTap: onTap ??
          () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: o.id))),
      borderRadius: BorderRadius.circular(Radii.md),
      child: Container(
        margin: const EdgeInsets.only(bottom: Space.md),
        padding: const EdgeInsets.all(Space.lg),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(
            color: selected ? c.accent : c.ruleSoft,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    view.customer.name,
                    style: context.text.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(money(t.total, showZero: true)!, style: context.text.titleSmall),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              // The time comes from the journey this card is being shown
              // for, never from the order's caches — those hold the FINISHING
              // journey, so a two-day order filed under Friday read Sunday's
              // time on the same row. The handover covers all of them, because
              // one label cannot honestly stand for a pickup and a delivery.
              //
              // The date is the report's: when the sale was filed, which is
              // when it actually went.
              [
                if (showDate)
                  _dateLabel(DateTime.fromMillisecondsSinceEpoch(view.soldOn)),
                timeLabel(shown?.deliveryTime),
                _handover(view),
              ].join(' · '),
              style: context.text.bodySmall!.copyWith(color: c.ink2),
            ),
            const SizedBox(height: 2),
            Text(
              _items(view),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall!.copyWith(color: c.ink2),
            ),
            const SizedBox(height: Space.sm),
            Wrap(
              spacing: Space.sm,
              runSpacing: Space.xs,
              children: [
                _Chip(view.statusLabel, _statusColors(context, view.status)),
                if (t.hasBalance)
                  _Chip('Balance ${money(t.balanceDue)}', (c.warn, c.warnSoft)),
                if (view.paymentStatus == PaymentStatus.paid)
                  _Chip('Paid', (c.good, c.goodSoft)),
                if (view.requirementsChanged)
                  _Chip('Changed', (c.warn, c.warnSoft)),
                for (final d in Dietary.labels(o.dietaryFlags))
                  _Chip(d, (c.ink2, c.surface2)),
              ],
            ),
            Text(o.orderNo,
                style: context.text.labelSmall!.copyWith(color: c.ink3)),
          ],
        ),
      ),
    );
  }

  (Color, Color) _statusColors(BuildContext context, OrderStatus s) {
    final c = context.colors;
    return switch (s) {
      OrderStatus.created => (c.warn, c.warnSoft),
      OrderStatus.cancelled => (c.bad, c.badSoft),
      OrderStatus.completed || OrderStatus.delivered => (c.good, c.goodSoft),
      _ => (c.accent2, c.accentSoft),
    };
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.colors);

  final String label;
  final (Color, Color) colors;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: colors.$2,
          borderRadius: BorderRadius.circular(Radii.pill),
        ),
        child: Text(label,
            style: context.text.labelSmall!
                .copyWith(color: colors.$1, fontWeight: FontWeight.w600)),
      );
}

/// The items, grouped by name and counted.
///
/// One row per order item read "Croissant, Croissant ×2" when the same thing
/// was both collected and delivered — which looks like a mistake rather than
/// two handovers. Live only: the amount beside this line excludes cancelled
/// items, so naming them here would make the two disagree.
String _items(OrderView view) {
  final counts = <String, int>{};
  for (final l in view.lines) {
    if (!l.isLive) continue;
    counts[l.itemName] = (counts[l.itemName] ?? 0) + l.qty;
  }
  return counts.entries
      .map((e) => e.value > 1 ? '${e.key} ×${e.value}' : e.key)
      .join(', ');
}

/// How this order is handed over, across **all** its journeys.
///
/// `orders.fulfilment` is a cache of the finishing journey, so a card built
/// from it said "Delivery" for an order half of which the customer collected.
String _handover(OrderView view) {
  final live = [for (final s in view.subOrders) if (s.isLive) s];
  if (live.isEmpty) return 'Delivery';
  final pickups = live.where((s) => s.isPickup).length;
  final deliveries = live.length - pickups;
  if (pickups > 0 && deliveries > 0) return 'Delivery + pickup';
  if (live.length == 1) return pickups == 1 ? 'Pickup' : 'Delivery';
  return pickups > 0 ? '$pickups pickups' : '$deliveries deliveries';
}

String _dateLabel(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final today = DateTime.now();
  bool same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  if (same(d, today)) return 'Today';
  if (same(d, today.add(const Duration(days: 1)))) return 'Tomorrow';
  return '${d.day} ${months[d.month - 1]}';
}
