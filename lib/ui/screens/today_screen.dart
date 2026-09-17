import 'package:flutter/material.dart';

import '../../app/scope.dart';
import '../../common/money.dart';
import '../../domain/orders/model.dart';
import '../../domain/orders/repository.dart';
import '../../domain/stock/model.dart';
import '../../domain/stock/repository.dart';
import '../shell/shell.dart';
import '../theme/breakpoints.dart';
import '../theme/format.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../widgets/forms.dart';
import '../widgets/primitives.dart';
import 'orders/order_card.dart';
import 'stock/stock_screen.dart';

/// The screen the app opens on: what is due today, what is due tomorrow, and
/// anything that needs a decision. Every number here is counted from the
/// database — nothing on this screen is a placeholder.
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final tomorrow = DateTime(now.year, now.month, now.day + 1).millisecondsSinceEpoch;
    final dayAfter = DateTime(now.year, now.month, now.day + 2).millisecondsSinceEpoch;

    return Scaffold(
      backgroundColor: context.colors.paper,
      appBar: AppBar(
        title: const Text('Today'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.sm),
              child: Text(_longDate(now),
                  style: context.text.bodySmall!.copyWith(color: Colors.white70)),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<OrderView>>(
        stream: app.orders.watchOrders(),
        builder: (context, snap) {
          final all = snap.data;
          if (all == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final live = all.where((o) => !o.isCancelled).toList();
          final dueToday = live
              .where((o) =>
                  o.order.deliveryDate >= today &&
                  o.order.deliveryDate < tomorrow &&
                  o.status != OrderStatus.completed)
              .toList();
          final dueTomorrow = live
              .where((o) =>
                  o.order.deliveryDate >= tomorrow &&
                  o.order.deliveryDate < dayAfter)
              .toList();
          final overdue = live
              .where((o) =>
                  o.order.deliveryDate < today &&
                  o.status != OrderStatus.completed &&
                  o.status != OrderStatus.delivered)
              .toList();
          final changed = live.where((o) => o.requirementsChanged).toList();
          final unconfirmed =
              live.where((o) => o.status == OrderStatus.created).toList();
          final toCollect = live
              .where((o) => o.totals.hasBalance && o.status != OrderStatus.created)
              .fold(Money.zero, (Money a, o) => a + o.totals.balanceDue);

          return ContentWidth(
            max: 900,
            child: ListView(
            padding: const EdgeInsets.fromLTRB(
                Space.lg, 0, Space.lg, Space.xxl * 2),
            children: [
              const _Strip(),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.md),
                child: Row(
                  children: [
                    Expanded(
                        child: _Kpi('Due today', '${dueToday.length}')),
                    const SizedBox(width: Space.md),
                    Expanded(
                        child: _Kpi('Tomorrow', '${dueTomorrow.length}')),
                    const SizedBox(width: Space.md),
                    Expanded(
                      child: _Kpi('To collect',
                          money(toCollect, showZero: true)!, wide: true),
                    ),
                  ],
                ),
              ),

              if (overdue.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.sm),
                  child: LoafAlert(
                    overdue.length == 1
                        ? '1 order is past its date'
                        : '${overdue.length} orders are past their date',
                    icon: Icons.error_outline,
                    tone: AlertTone.bad,
                  ),
                ),
              if (unconfirmed.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.sm),
                  child: LoafAlert(
                    unconfirmed.length == 1
                        ? '1 order not confirmed yet'
                        : '${unconfirmed.length} orders not confirmed yet',
                    icon: Icons.mark_chat_unread_outlined,
                  ),
                ),
              if (changed.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.sm),
                  child: LoafAlert(
                    changed.length == 1
                        ? '1 order changed after confirming'
                        : '${changed.length} orders changed after confirming',
                    icon: Icons.flag_outlined,
                  ),
                ),
              const _LowStockAlert(),

              if (dueToday.isEmpty && dueTomorrow.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: Space.xxl),
                  child: EmptyState(
                    icon: Icons.wb_sunny_outlined,
                    message: 'Nothing due today or tomorrow.',
                  ),
                ),

              if (dueToday.isNotEmpty) ...[
                const SectionLabel('Due today'),
                CardGrid(children: [for (final o in dueToday) OrderCard(view: o)]),
              ],
              if (dueTomorrow.isNotEmpty) ...[
                const SectionLabel('Tomorrow'),
                CardGrid(children: [for (final o in dueTomorrow) OrderCard(view: o)]),
              ],
            ],
          ),
          );
        },
      ),
    );
  }
}

/// The sync strip, driven by the real outbox count.
class _Strip extends StatelessWidget {
  const _Strip();

  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
        stream: context.app.mutations.watchPending(),
        builder: (context, snap) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: SyncStrip(pending: snap.data ?? 0),
        ),
      );
}

class _LowStockAlert extends StatelessWidget {
  const _LowStockAlert();

  @override
  Widget build(BuildContext context) => StreamBuilder<List<StockLevel>>(
        stream: context.app.stock.watchLevels(),
        builder: (context, snap) {
          final low = (snap.data ?? const <StockLevel>[])
              .where((l) => l.state == StockState.below)
              .toList();
          if (low.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: LoafAlert(
              low.length == 1
                  ? '${low.first.material.name} below threshold'
                  : '${low.length} materials below threshold',
              icon: Icons.inventory_2_outlined,
              action: '>',
              onAction: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const StockScreen())),
            ),
          );
        },
      );
}

class _Kpi extends StatelessWidget {
  const _Kpi(this.label, this.value, {this.wide = false});

  final String label;
  final String value;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Space.md, vertical: Space.lg),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Micro(label),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: (wide ? context.text.titleLarge : context.text.headlineSmall)!
                    .copyWith(color: c.accent2)),
          ),
        ],
      ),
    );
  }
}

String _longDate(DateTime d) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]}';
}
