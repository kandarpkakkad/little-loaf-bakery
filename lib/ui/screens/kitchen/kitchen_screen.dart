import 'package:flutter/material.dart';

import '../../../app/scope.dart';
import '../../../domain/orders/model.dart';
import '../../../domain/orders/repository.dart';
import '../../theme/breakpoints.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/forms.dart';
import '../../widgets/sync_refresh.dart';
import '../../widgets/primitives.dart';
import '../../theme/format.dart';
import '../orders/order_detail_screen.dart';

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
      body: SyncRefresh(
        child: StreamBuilder<List<OrderView>>(
        stream: context.app.orders.watchOrders(statuses: _active),
        builder: (context, snap) {
          final all = snap.data;
          if (all == null) {
            return const Pullable(child: CircularProgressIndicator());
          }
          // A board of lines, not of orders. An order with a cake on Friday
          // and a box on Sunday has to put the cake on Friday's board — its
          // own date is the Sunday one (D25), so filtering by that would hide
          // the cake from the week it is baked in.
          final due = [
            for (final o in all)
              for (final l in o.linesDueBetween(0, horizon)) (order: o, line: l),
          ];

          // The board only draws items that have *started* — in production,
          // ready, out. So "nothing due" is not the only empty case: an order
          // sitting unconfirmed has items due and none of them started, and
          // asking `due.isEmpty` there rendered a blank screen with no
          // explanation at all.
          // Work reaches the kitchen when the order is confirmed, so anything
          // still merely created is not theirs yet.
          final onBoard =
              due.where((w) => w.line.status != LineStatus.created).toList();
          final boardIsEmpty = _view == 0 ? onBoard.isEmpty : due.isEmpty;

          if (boardIsEmpty) {
            return Pullable(child: EmptyState(
              icon: Icons.bakery_dining_outlined,
              message: due.isEmpty
                  ? (_days == 1
                      ? 'Nothing to bake today.'
                      : 'Nothing to bake in the next $_days days.')
                  : 'Nothing confirmed yet.\n'
                      'Confirming an order sends its items here.',
            ));
          }
          return _view == 0 ? _Board(work: due) : _BakeSheet(work: due);
        },
      )),
    );
  }
}

/// Grouped by status, so the board reads left to right as work moving through.
/// One item of one order — what the kitchen actually works on.
typedef Work = ({OrderView order, OrderLine line});

class _Board extends StatelessWidget {
  const _Board({required this.work});

  final List<Work> work;

  @override
  Widget build(BuildContext context) {
    final byStatus = <LineStatus, List<Work>>{};
    for (final w in work) {
      byStatus.putIfAbsent(w.line.status, () => []).add(w);
    }
    // Soonest first within a column: the board is read top-down under time
    // pressure, so the next thing out of the oven belongs at the top.
    for (final list in byStatus.values) {
      list.sort((a, b) {
        final d = (a.line.deliveryDate ?? 0).compareTo(b.line.deliveryDate ?? 0);
        if (d != 0) return d;
        return (a.line.deliveryTime ?? 1 << 30)
            .compareTo(b.line.deliveryTime ?? 1 << 30);
      });
    }

    return ContentWidth(
      max: 900,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            Space.lg, Space.md, Space.lg, Space.xxl * 2),
        children: [
          // Confirmed first: an order that has been agreed with the customer
          // is the kitchen's to do, and the board is where they see it. It
          // used to start at "in production", which meant work only appeared
          // once somebody had already started it — so the board showed what
          // was under way and never what was coming.
          for (final status in [
            LineStatus.confirmed,
            LineStatus.inProduction,
            LineStatus.ready,
            LineStatus.out,
          ])
            if (byStatus[status] != null) ...[
              SectionLabel('${status.label} · ${byStatus[status]!.length}'),
              CardGrid(children: [
                for (final w in byStatus[status]!) _WorkCard(work: w),
              ]),
            ],
        ],
      ),
    );
  }
}

/// One line, with the order it belongs to named rather than assumed. Two
/// customers ordering the same cake on the same day is the normal case, so the
/// card has to say whose it is.
class _WorkCard extends StatelessWidget {
  const _WorkCard({required this.work});

  final Work work;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = work.line;
    final sub = [
      if (l.flavour != null) l.flavour!,
      if (l.weight != null) l.weight!.label,
      if (l.qty > 1) '× ${l.qty}',
    ].join(' · ');

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: work.order.order.id)),
      ),
      child: LoafCard(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.itemName, style: context.text.titleMedium),
          if (sub.isNotEmpty) Micro(sub),
          const SizedBox(height: Space.sm),
          Row(
            children: [
              Icon(Icons.event, size: 14, color: c.ink3),
              const SizedBox(width: Space.xs),
              Text(
                [
                  if (l.deliveryDate != null)
                    _dayLabel(DateTime.fromMillisecondsSinceEpoch(l.deliveryDate!)),
                  if (l.deliveryTime != null) timeLabel(l.deliveryTime),
                  if (l.fulfilment == Fulfilment.pickup) 'pickup',
                ].join(' · '),
                style: context.text.bodySmall!.copyWith(color: c.ink2),
              ),
            ],
          ),
          Text(work.order.customer.name,
              style: context.text.bodySmall!.copyWith(color: c.ink3)),
            if (l.note != null)
              Padding(
                padding: const EdgeInsets.only(top: Space.xs),
                child: Text(l.note!,
                    style: context.text.bodySmall!.copyWith(color: c.warn)),
              ),
            // The board is where the work happens, so the next step is here
            // rather than one tap away inside the order.
            Align(
              alignment: Alignment.centerRight,
              child: LineNextStep(view: work.order, line: l),
            ),
          ],
        ),
      ),
    );
  }
}

String _dayLabel(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]}';
}

/// Every line across every order, added up. What to actually make.
class _BakeSheet extends StatelessWidget {
  const _BakeSheet({required this.work});

  final List<Work> work;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final totals = <String, int>{};
    final notes = <String, Set<String>>{};

    // Only the lines actually due in the horizon. Adding up every line of
    // every order would put next month's cake on today's sheet.
    for (final w in work) {
      final l = w.line;
      final key = [
        l.itemName,
        if (l.flavour != null) l.flavour!,
        if (l.weight != null) l.weight!.label,
      ].join(' · ');
      totals[key] = (totals[key] ?? 0) + l.qty;
      for (final d in Dietary.labels(w.order.order.dietaryFlags)) {
        notes.putIfAbsent(key, () => {}).add(d);
      }
      if (l.note != null) notes.putIfAbsent(key, () => {}).add(l.note!);
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
