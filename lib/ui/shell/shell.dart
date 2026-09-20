import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/scope.dart';

import '../screens/kitchen/kitchen_screen.dart';
import '../screens/more_screen.dart';
import '../screens/orders/new_order_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/stock/stock_screen.dart';
import '../screens/today_screen.dart';
import '../theme/breakpoints.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';

/// One shell, five tabs, identical on every device — no roles, so no variants.
/// The FAB is New order, on every tab: the most common action is never more
/// than one tap away. docs/03-frontend/navigation.md
///
/// On a tablet the tabs move to a rail on the leading edge. The destinations
/// and their order do not change, so muscle memory carries between the phone
/// and the counter tablet.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  /// Sync on open, on resume, and on a slow timer while the app is in front.
  ///
  /// The background worker is the safety net; these are the moments that
  /// actually keep a device current. It covers the real flow — pick up the
  /// tablet, it pulls what the phone did — and every run is a no-op when
  /// Drive is not connected.
  Timer? _syncTimer;
  bool _syncStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_syncStarted) return;
    _syncStarted = true;
    final sync = context.app.sync;
    // restore() and syncNow() are silent by contract — they read the
    // remembered account and never prompt. offerOnFirstRun() is the one place
    // that deliberately does, and only on an install that has never been
    // asked: sync is what makes this a bakery's app rather than one phone's,
    // and leaving it three taps into Settings meant it simply never happened.
    sync.restore().then((_) async {
      await sync.syncNow();
      if (mounted) await sync.offerOnFirstRun();
    });
    _syncTimer = Timer.periodic(
        const Duration(minutes: 5), (_) => context.app.sync.syncNow());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.app.sync.syncNow();
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  int _tab = 0;

  static const _tabs = [
    (icon: Icons.today_outlined, selected: Icons.today, label: 'Today'),
    (icon: Icons.receipt_long_outlined, selected: Icons.receipt_long, label: 'Orders'),
    (icon: Icons.bakery_dining_outlined, selected: Icons.bakery_dining, label: 'Kitchen'),
    (icon: Icons.inventory_2_outlined, selected: Icons.inventory_2, label: 'Stock'),
    (icon: Icons.more_horiz, selected: Icons.more_horiz, label: 'More'),
  ];

  // IndexedStack rather than a switch: each tab keeps its scroll position
  // and its filters when you come back to it.
  static const _screens = [
    TodayScreen(),
    OrdersScreen(),
    KitchenScreen(),
    StockScreen(),
    MoreScreen(),
  ];

  void _newOrder() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const NewOrderScreen()));

  @override
  Widget build(BuildContext context) {
    final rail = context.window.usesRail;
    final body = IndexedStack(index: _tab, children: _screens);

    if (rail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _tab,
              onDestinationSelected: (i) => setState(() => _tab = i),
              labelType: NavigationRailLabelType.all,
              backgroundColor: context.colors.surface,
              indicatorColor: context.colors.accentSoft,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.lg),
                child: FloatingActionButton(
                  onPressed: _newOrder,
                  backgroundColor: context.colors.brand,
                  foregroundColor: Colors.white,
                  tooltip: 'New order',
                  child: const Icon(Icons.add),
                ),
              ),
              destinations: [
                for (final t in _tabs)
                  NavigationRailDestination(
                    icon: Icon(t.icon, size: 22),
                    selectedIcon:
                        Icon(t.selected, size: 22, color: context.colors.accent),
                    label: Text(t.label),
                  ),
              ],
            ),
            VerticalDivider(width: 1, color: context.colors.ruleSoft),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newOrder,
        backgroundColor: context.colors.brand,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New order'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(
              icon: Icon(t.icon, size: 22),
              selectedIcon: Icon(t.selected, size: 22, color: context.colors.accent),
              label: t.label,
            ),
        ],
      ),
    );
  }
}

/// Appears only when it has something to say: syncing, offline with N pending,
/// or last synced over 24 hours ago. It never occupies space silently.
class SyncStrip extends StatelessWidget {
  const SyncStrip({super.key, this.pending = 0, this.staleHours = 0, this.syncing = false});

  final int pending;
  final int staleHours;
  final bool syncing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (text, fg, bg) = switch (0) {
      _ when syncing => ('Syncing…', c.accent2, c.accentSoft),
      _ when pending > 0 => ('Offline · $pending waiting to upload', c.warn, c.warnSoft),
      _ when staleHours >= 24 => ('Not synced for ${staleHours}h', c.warn, c.warnSoft),
      _ => (null, c.ink, c.paper),
    };
    if (text == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: 6),
      child: Text(text, style: context.text.bodySmall!.copyWith(color: fg)),
    );
  }
}
