import 'package:flutter/material.dart';

import '../../../app/scope.dart';
import '../../../common/phone.dart';
import '../../../domain/orders/model.dart';
import '../../../domain/orders/repository.dart';
import '../../theme/breakpoints.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/primitives.dart';
import '../../widgets/sync_refresh.dart';
import 'order_card.dart';
import 'order_detail_screen.dart';

/// Every order, filtered by where it is. "Open" is the default because the
/// finished ones are the ones nobody needs to look at.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const _open = {
    OrderStatus.created,
    OrderStatus.confirmed,
    OrderStatus.inProduction,
    OrderStatus.ready,
    OrderStatus.out,
  };

  String _filter = 'open';
  String _query = '';

  /// Only used when there is room for two panes. On a phone the detail screen
  /// is pushed and this stays null.
  String? _selectedId;

  Set<OrderStatus>? get _statuses => switch (_filter) {
        'open' => _open,
        'done' => {OrderStatus.delivered, OrderStatus.completed},
        'cancelled' => {OrderStatus.cancelled},
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.paper,
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.sm),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v.toLowerCase()),
                  decoration: const InputDecoration(
                    hintText: 'Search name, number or item',
                    prefixIcon: Icon(Icons.search, size: 20),
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: Space.lg),
                  children: [
                    for (final (key, label) in const [
                      ('open', 'Open'),
                      ('done', 'Delivered'),
                      ('cancelled', 'Cancelled'),
                      ('all', 'All'),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: Space.sm),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: _filter == key,
                          onSelected: (_) => setState(() => _filter = key),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SyncRefresh(
        child: StreamBuilder<List<OrderView>>(
        // Every tab reads forward — delivery date, then time, then when the
        // order was taken. The earliest deliverable order is always the one to
        // see first, and a list that changes direction with the tab is harder
        // to read than one that never does.
        stream: context.app.orders.watchOrders(statuses: _statuses),
        builder: (context, snap) {
          final all = snap.data;
          if (all == null) {
            return const Pullable(child: CircularProgressIndicator());
          }
          // Numbers are stored unspaced but shown grouped, so a search typed
          // either way has to match: both sides are reduced to digits.
          final queryDigits = Phone.digitsOf(_query);
          final orders = _query.isEmpty
              ? all
              : all.where((o) {
                  return o.customer.name.toLowerCase().contains(_query) ||
                      (queryDigits.isNotEmpty &&
                          Phone.digitsOf(o.customer.phoneE164)
                              .contains(queryDigits)) ||
                      o.order.orderNo.toLowerCase().contains(_query) ||
                      o.lines.any((l) => l.itemName.toLowerCase().contains(_query));
                }).toList();

          if (orders.isEmpty) {
            return Pullable(child: EmptyState(
              icon: Icons.receipt_long_outlined,
              message: _query.isNotEmpty
                  ? 'Nothing matches "$_query".'
                  : switch (_filter) {
                      'open' => 'No open orders.\nTap New order to take one.',
                      'done' => 'Nothing delivered yet.',
                      'cancelled' => 'No cancelled orders.',
                      _ => 'No orders yet.',
                    },
            ));
          }

          final twoPane = context.window.usesRail;

          // On a tablet the list keeps its place while an order is read
          // beside it — the common tablet motion is comparing orders, not
          // diving into one and coming back.
          if (!twoPane) {
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                  Space.lg, Space.md, Space.lg, Space.xxl * 2),
              itemCount: orders.length,
              itemBuilder: (context, i) =>
                  OrderCard(view: orders[i], showDate: true),
            );
          }

          final selected = orders.any((o) => o.order.id == _selectedId)
              ? _selectedId
              : (orders.isEmpty ? null : orders.first.order.id);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 380,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      Space.lg, Space.md, Space.md, Space.xxl),
                  itemCount: orders.length,
                  itemBuilder: (context, i) => OrderCard(
                    view: orders[i],
                    showDate: true,
                    selected: orders[i].order.id == selected,
                    onTap: () =>
                        setState(() => _selectedId = orders[i].order.id),
                  ),
                ),
              ),
              VerticalDivider(width: 1, color: c.ruleSoft),
              Expanded(
                child: selected == null
                    ? const EmptyState(
                        icon: Icons.receipt_long_outlined,
                        message: 'Pick an order to see it here.',
                      )
                    : OrderDetailScreen(
                        key: ValueKey(selected),
                        orderId: selected,
                        embedded: true,
                      ),
              ),
            ],
          );
        },
      )),
    );
  }
}
