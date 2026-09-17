import 'package:flutter/material.dart';

import '../../../app/scope.dart';
import '../../../domain/orders/model.dart';
import '../../../domain/orders/repository.dart';
import '../../theme/breakpoints.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/forms.dart';
import '../../widgets/primitives.dart';
import '../orders/order_card.dart';

/// Two ways of reading the same orders: as a board of what to make next, and as
/// a sheet of what to bake in total. The sheet is the one that gets held while
/// weighing, so it is quantities and nothing else.
class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  int _view = 0;
  int _days = 1;

  static const _active = {
    OrderStatus.confirmed,
    OrderStatus.inProduction,
    OrderStatus.ready,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final now = DateTime.now();
    final horizon = DateTime(now.year, now.month, now.day)
        .add(Duration(days: _days))
        .millisecondsSinceEpoch;

    return Scaffold(
      backgroundColor: c.paper,
      appBar: AppBar(
        title: const Text('Kitchen'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.sm),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Board')),
                      ButtonSegment(value: 1, label: Text('Bake sheet')),
                    ],
                    selected: {_view},
                    onSelectionChanged: (s) => setState(() => _view = s.first),
                  ),
                ),
                const SizedBox(width: Space.md),
                DropdownButton<int>(
                  value: _days,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Today')),
                    DropdownMenuItem(value: 2, child: Text('2 days')),
                    DropdownMenuItem(value: 7, child: Text('Week')),
                  ],
                  onChanged: (v) => setState(() => _days = v ?? 1),
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<OrderView>>(
        stream: context.app.orders.watchOrders(statuses: _active),
        builder: (context, snap) {
          final all = snap.data;
          if (all == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final due =
              all.where((o) => o.order.deliveryDate < horizon).toList();

          if (due.isEmpty) {
            return EmptyState(
              icon: Icons.bakery_dining_outlined,
              message: _days == 1
                  ? 'Nothing to bake today.'
                  : 'Nothing to bake in the next $_days days.',
            );
          }
          return _view == 0 ? _Board(orders: due) : _BakeSheet(orders: due);
        },
      ),
    );
  }
}

/// Grouped by status, so the board reads left to right as work moving through.
class _Board extends StatelessWidget {
  const _Board({required this.orders});

  final List<OrderView> orders;

  @override
  Widget build(BuildContext context) {
    final byStatus = <OrderStatus, List<OrderView>>{};
    for (final o in orders) {
      byStatus.putIfAbsent(o.status, () => []).add(o);
    }

    return ContentWidth(
      max: 900,
      child: ListView(
      padding: const EdgeInsets.fromLTRB(
          Space.lg, Space.md, Space.lg, Space.xxl * 2),
      children: [
        for (final status in [
          OrderStatus.confirmed,
          OrderStatus.inProduction,
          OrderStatus.ready,
        ])
          if (byStatus[status] != null) ...[
            SectionLabel('${status.label} · ${byStatus[status]!.length}'),
            CardGrid(children: [
              for (final o in byStatus[status]!) OrderCard(view: o, showDate: true),
            ]),
          ],
      ],
      ),
    );
  }
}

/// Every line across every order, added up. What to actually make.
class _BakeSheet extends StatelessWidget {
  const _BakeSheet({required this.orders});

  final List<OrderView> orders;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final totals = <String, int>{};
    final notes = <String, Set<String>>{};

    for (final o in orders) {
      for (final l in o.lines) {
        final key = [
          l.itemName,
          if (l.flavour != null) l.flavour!,
          if (l.weight != null) l.weight!.label,
        ].join(' · ');
        totals[key] = (totals[key] ?? 0) + l.qty;
        for (final d in Dietary.labels(o.order.dietaryFlags)) {
          notes.putIfAbsent(key, () => {}).add(d);
        }
        if (l.note != null) notes.putIfAbsent(key, () => {}).add(l.note!);
      }
    }

    final keys = totals.keys.toList()..sort();

    return ContentWidth(
      child: ListView(
      padding: const EdgeInsets.fromLTRB(
          Space.lg, Space.md, Space.lg, Space.xxl * 2),
      children: [
        LoafCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < keys.length; i++) ...[
                if (i > 0) Divider(height: 1, color: c.ruleSoft),
                ListTile(
                  title: Text(keys[i]),
                  subtitle: notes[keys[i]] == null
                      ? null
                      : Micro(notes[keys[i]]!.join(' · ')),
                  trailing: Text('× ${totals[keys[i]]}',
                      style: context.text.titleMedium!.copyWith(color: c.accent2)),
                ),
              ],
            ],
          ),
        ),
      ],
      ),
    );
  }
}
