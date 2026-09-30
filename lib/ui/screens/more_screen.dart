import 'package:flutter/material.dart';

import '../../app/scope.dart';
import '../../domain/orders/repository.dart';
import '../theme/format.dart';
import 'config/reports_screen.dart';
import 'config/sync_screen.dart';
import '../theme/breakpoints.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../../common/money.dart';
import '../widgets/forms.dart';
import '../widgets/primitives.dart';
import 'config/business_config_screen.dart';
import 'config/materials_config_screen.dart';
import 'config/menu_config_screen.dart';
import 'customers_screen.dart';
import '../../domain/messaging/compose.dart';
import 'orders/order_detail_screen.dart';

/// Everything that is not a daily action: the lists behind the app, and the
/// month's numbers.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.paper,
      appBar: AppBar(title: const Text('More')),
      body: ContentWidth(
        max: 720,
        child: ListView(
        padding: const EdgeInsets.fromLTRB(
            Space.lg, Space.sm, Space.lg, Space.xxl * 2),
        children: [
          const SectionLabel('This month'),
          const _MonthSummary(),
          const SectionLabel('Lists'),
          LoafCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Link(
                  icon: Icons.people_outline,
                  title: 'Customers',
                  subtitle: 'Everyone who has ordered',
                  screen: const CustomersScreen(),
                ),
                Divider(height: 1, color: c.ruleSoft),
                _Link(
                  icon: Icons.bakery_dining_outlined,
                  title: 'Menu items',
                  subtitle: 'What the bakery makes',
                  screen: const MenuConfigScreen(),
                ),
                Divider(height: 1, color: c.ruleSoft),
                _Link(
                  icon: Icons.inventory_2_outlined,
                  title: 'Materials',
                  subtitle: 'What you buy and track',
                  screen: const MaterialsConfigScreen(),
                ),
              ],
            ),
          ),
          const SectionLabel('Setup'),
          LoafCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Link(
                  icon: Icons.storefront_outlined,
                  title: 'Business',
                  subtitle: 'Name, UPI, delivery charges, this device',
                  screen: const BusinessConfigScreen(),
                ),
                Divider(height: 1, color: context.colors.ruleSoft),
                _Link(
                  icon: Icons.insights_outlined,
                  title: 'Reports',
                  subtitle: 'What came in, what sells, what is owed',
                  screen: const ReportsScreen(),
                ),
                Divider(height: 1, color: context.colors.ruleSoft),
                _Link(
                  icon: Icons.cloud_outlined,
                  title: 'Google Drive sync',
                  subtitle: 'Share with your other device, and back up',
                  screen: const SyncScreen(),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.screen,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget screen;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: context.colors.accent2),
        title: Text(title),
        subtitle: Text(subtitle,
            style: context.text.bodySmall!.copyWith(color: context.colors.ink3)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => screen)),
      );
}

/// Orders taken and money collected this calendar month. Cancelled orders are
/// excluded from both — an order nobody is making is not revenue.
class _MonthSummary extends StatelessWidget {
  const _MonthSummary();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month).millisecondsSinceEpoch;

    return StreamBuilder<List<OrderView>>(
      stream: context.app.orders.watchOrders(),
      builder: (context, snap) {
        final all = snap.data ?? const <OrderView>[];
        final month = all
            .where((o) => o.order.deliveryDate >= from && !o.isCancelled)
            .toList();
        final billed = month.fold(
            Money.zero, (Money a, o) => a + o.totals.total);
        final collected =
            month.fold(Money.zero, (Money a, o) => a + o.totals.paid);
        // Owed across EVERY month, and summed only over the orders that
        // actually owe. `billed - collected` for the month was wrong twice
        // over: August's debt vanished in September, and one over-paid order
        // quietly cancelled out another customer's unpaid balance.
        // Same definition as ReportRepository.outstanding().
        final unpaid = [
          for (final o in all)
            if (!o.isCancelled && o.totals.hasBalance) o,
        ]..sort((a, b) => a.soldOn.compareTo(b.soldOn));
        final outstanding = unpaid.fold(
            Money.zero, (Money a, o) => a + o.totals.balanceDue);

        return LoafCard(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Micro('Orders'),
                        Text('${month.length}',
                            style: context.text.headlineSmall),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Micro('Billed'),
                        Text(money(billed, showZero: true)!,
                            style: context.text.headlineSmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.md),
              MoneyRow('Collected', collected),
              if (outstanding.paise > 0)
                // Deliberately not inside the month: the two figures above
                // are this month's trading, this one is everything still
                // owed. The label says so, and the list behind it names who.
                Row(
                  children: [
                    Expanded(
                      child: MoneyRow('Owed to you · all months', outstanding,
                          strong: true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline, size: 20),
                      tooltip: 'Who owes',
                      onPressed: () => loafSheet(
                        context,
                        builder: (_) => _UnpaidSheet(orders: unpaid),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Everyone who still owes, oldest first.
///
/// Oldest first because this is a collection list, not a history: the debt
/// that has been waiting longest is the one worth a message this morning.
class _UnpaidSheet extends StatelessWidget {
  const _UnpaidSheet({required this.orders});

  final List<OrderView> orders;

  @override
  Widget build(BuildContext context) {
    final total = orders.fold(
        Money.zero, (Money a, o) => a + o.totals.balanceDue);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.lg, Space.lg, Space.lg, 0),
          child: Row(
            children: [
              Expanded(
                child: Text('Unpaid orders', style: context.text.titleMedium),
              ),
              Text(money(total, showZero: true)!,
                  style: context.text.titleMedium),
            ],
          ),
        ),
        const SizedBox(height: Space.sm),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: Space.lg),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final o = orders[i];
              final days = DateTime.now()
                  .difference(DateTime.fromMillisecondsSinceEpoch(o.soldOn))
                  .inDays;
              return ListTile(
                title: Text(o.customer.name),
                subtitle: Text(
                  '${o.order.orderNo} · ${days == 0 ? 'today' : '$days days'}',
                  style: context.text.bodySmall!
                      .copyWith(color: context.colors.ink3),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      money(o.totals.balanceDue)!,
                      style: context.text.titleSmall!
                          .copyWith(color: context.colors.warn),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_outlined, size: 18),
                      tooltip: 'Send a reminder',
                      // The same path the order screen uses, so there is one
                      // set of rules about what may be sent and when.
                      onPressed: () => offerMessage(
                          context, o, MessageKind.paymentReminder),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          OrderDetailScreen(orderId: o.order.id)));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
