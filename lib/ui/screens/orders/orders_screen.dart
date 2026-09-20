import 'package:flutter/material.dart';

import '../../../app/scope.dart';
import '../../../platform/sync/sync_service.dart';
import '../../theme/format.dart';
import '../../widgets/forms.dart';
import '../config/sync_screen.dart';
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

          // The alerts Today used to carry. They are things to act on, and
          // this is where acting on them happens — a screen that only counted
          // them was a second place to keep agreeing about one number.
          final live = all
              .where((o) =>
                  !o.isCancelled &&
                  o.status != OrderStatus.completed &&
                  o.status != OrderStatus.delivered)
              .toList();
          final unconfirmed =
              live.where((o) => o.status == OrderStatus.created).length;
          final changed = live.where((o) => o.requirementsChanged).length;

          final alerts = <Widget>[
            if (context.app.sync.status.blocker == SyncBlocker.notConnected)
              LoafAlert(
                'Not backed up. Connect Google Drive to share with your other '
                'device and keep a copy.',
                icon: Icons.cloud_off_outlined,
                action: 'Connect',
                onAction: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SyncScreen())),
              ),
            if (unconfirmed > 0)
              LoafAlert(
                unconfirmed == 1
                    ? '1 order not confirmed yet'
                    : '$unconfirmed orders not confirmed yet',
                icon: Icons.mark_chat_unread_outlined,
              ),
            if (changed > 0)
              LoafAlert(
                changed == 1
                    ? '1 order changed after confirming'
                    : '$changed orders changed after confirming',
                icon: Icons.flag_outlined,
              ),
          ];

          // Grouped by the day each order is next needed, which is the order
          // the list is already sorted in (D25) — so a heading can never
          // disagree with the rows beneath it.
          final rows = _group(orders);
          final twoPane = context.window.usesRail;

          // On a tablet the list keeps its place while an order is read
          // beside it — the common tablet motion is comparing orders, not
          // diving into one and coming back.
          if (!twoPane) {
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                  Space.lg, Space.md, Space.lg, Space.xxl * 2),
              itemCount: rows.length + alerts.length,
              itemBuilder: (context, i) {
                if (i < alerts.length) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: Space.sm),
                    child: alerts[i],
                  );
                }
                return _RowTile(row: rows[i - alerts.length]);
              },
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
                  itemCount: rows.length + alerts.length,
                  itemBuilder: (context, i) {
                    if (i < alerts.length) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: Space.sm),
                        child: alerts[i],
                      );
                    }
                    final row = rows[i - alerts.length];
                    return _RowTile(
                      row: row,
                      selected: row.order?.order.id == selected,
                      onTap: row.order == null
                          ? null
                          : () => setState(
                              () => _selectedId = row.order!.order.id),
                    );
                  },
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

/// One line of the list: either a day, or an order due on it.
class _Row {
  const _Row.day(this.date) : order = null;
  const _Row.order(this.order) : date = null;

  final int? date;
  final OrderView? order;
}

/// Walks the sorted list and starts a group whenever the day changes.
///
/// It relies on the list already being sorted by the same number it groups on
/// — the earliest outstanding item (D25). That is deliberate: deriving the
/// heading from the sort key rather than re-sorting means the two cannot
/// disagree, and an order due Sunday with an item on Friday appears under
/// Friday, which is when somebody has to do something about it.
List<_Row> _group(List<OrderView> orders) {
  final rows = <_Row>[];
  int? current;
  var started = false;

  for (final o in orders) {
    final day = o.nextDate ?? o.dueDate;
    if (!started || day != current) {
      rows.add(_Row.day(day));
      current = day;
      started = true;
    }
    rows.add(_Row.order(o));
  }
  return rows;
}

class _RowTile extends StatelessWidget {
  const _RowTile({required this.row, this.selected = false, this.onTap});

  final _Row row;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final o = row.order;
    if (o != null) {
      return OrderCard(view: o, selected: selected, onTap: onTap);
    }
    return Padding(
      padding: const EdgeInsets.only(top: Space.md, bottom: Space.xs),
      child: SectionLabel(
          row.date == null ? 'No date' : dayLabel(row.date!)),
    );
  }
}
