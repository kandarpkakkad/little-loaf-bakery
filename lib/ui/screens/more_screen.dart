import 'package:flutter/material.dart';

import '../../app/scope.dart';
import '../../domain/orders/repository.dart';
import '../theme/format.dart';
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
        final outstanding = billed - collected;

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
                MoneyRow('Outstanding', outstanding, strong: true),
            ],
          ),
        );
      },
    );
  }
}
            
