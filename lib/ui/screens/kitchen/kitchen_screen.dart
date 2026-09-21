import 'package:flutter/material.dart';

import '../../../app/scope.dart';
import '../../../domain/orders/model.dart';
import '../../../domain/orders/repository.dart';
import '../../../domain/reminders/model.dart';
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

  /// A week, not today. What the kitchen needs to see is what is coming, not
  /// what is already late — a cake due tomorrow is started today, so a board
  /// that opened on Today hid the work that actually needed planning.
  int _days = 7;

  /// `deriveOrderStatus` never returns `ready` or `out` — half a ready order
  /// is not a thing, and an order does not travel; both collapse to
  /// `inProduction`, which is what keeps an order whose vans have all left on
  /// the board. Listing `ready` here did nothing at all.
  static const _active = {
    OrderStatus.confirmed,
    OrderStatus.inProduction,
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
                  onChanged: (v) => setState(() => _days = v ?? 7),
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
          // A board of **journeys**, not of orders and not of loose items
          // (D28). An order with a cake on Friday and a box on Sunday puts the
          // Friday journey on Friday's board — its own date is the Sunday one,
          // so filtering by that would hide the cake from the week it is baked
          // in. And a journey is the unit the kitchen actually works to: this
          // lot, going there, then.
          final due = [
            for (final o in all)
              for (final s in o.subOrdersDueBetween(0, horizon))
                (order: o, sub: s),
          ];

          // Work reaches the kitchen when the order is confirmed, so a journey
          // still merely created is not theirs yet.
          final onBoard = due
              .where((w) => w.sub.status != SubOrderStatus.created)
              .toList();
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

/// Grouped by status, so the board reads top to bottom as work moving through.
/// One journey of one order — what the kitchen actually works to.
typedef Work = ({OrderView order, SubOrder sub});

class _Board extends StatelessWidget {
  const _Board({required this.work});

  final List<Work> work;

  @override
  Widget build(BuildContext context) {
    final byStatus = <SubOrderStatus, List<Work>>{};
    for (final w in work) {
      byStatus.putIfAbsent(w.sub.status, () => []).add(w);
    }
    // Soonest first within a column: the board is read top-down under time
    // pressure, so the next thing out of the oven belongs at the top.
    for (final list in byStatus.values) {
      list.sort((a, b) {
        final d = a.sub.deliveryDate.compareTo(b.sub.deliveryDate);
        if (d != 0) return d;
        return (a.sub.deliveryTime ?? 1 << 30)
            .compareTo(b.sub.deliveryTime ?? 1 << 30);
      });
    }

    return ContentWidth(
      max: 900,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            Space.lg, Space.md, Space.lg, Space.xxl * 2),
        children: [
          // Nearest the door first. A board is read top-down, and the lots
          // that are out or boxed are the ones somebody is about to hand over
          // — clearing those off the top leaves what still needs doing below.
          //
          // The board still *starts* at confirmed, which is the change that
          // mattered: work appears when the customer agrees to it rather than
          // when somebody has already begun. This is only the reading order.
          for (final status in [
            SubOrderStatus.out,
            SubOrderStatus.ready,
            SubOrderStatus.inProduction,
            SubOrderStatus.confirmed,
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
    final sub = work.sub;

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
            // What the kitchen calls this lot. Theirs, not the customer's —
            // it never goes in a message (D28).
            Row(
              children: [
                Expanded(
                  child: Text(sub.reference(work.order.order.orderNo),
                      style: context.text.titleMedium),
                ),
                Micro(sub.isPickup ? 'Pickup' : 'Delivery'),
              ],
            ),
            const SizedBox(height: Space.xs),
            Row(
              children: [
                Icon(Icons.event, size: 14, color: c.ink3),
                const SizedBox(width: Space.xs),
                Text(
                  [
                    dayLabel(sub.deliveryDate),
                    timeLabel(sub.deliveryTime),
                  ].join(' · '),
                  style: context.text.bodySmall!.copyWith(
                    // Past its hour and still here: the board is where this
                    // needs to be loud, because it is the screen somebody is
                    // actually looking at during service.
                    color: isLate(sub) ? c.warn : c.ink2,
                    fontWeight: isLate(sub) ? FontWeight.w600 : null,
                  ),
                ),
                if (isLate(sub)) ...[
                  const SizedBox(width: Space.xs),
                  Icon(Icons.schedule, size: 13, color: c.warn),
                ],
              ],
            ),
            Text(work.order.customer.name,
                style: context.text.bodySmall!.copyWith(color: c.ink3)),

            const SizedBox(height: Space.sm),
            // Everything travelling on it, each with its own next step: the
            // kitchen bakes items, and the journey follows them.
            for (final l in sub.liveLines)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text([
                            l.itemName,
                            if (l.flavour != null) l.flavour!,
                            if (l.weight != null) l.weight!.label,
                            if (l.qty > 1) '× ${l.qty}',
                          ].join(' · ')),
                          if (l.note != null)
                            Text(l.note!,
                                style: context.text.bodySmall!
                                    .copyWith(color: c.warn)),
                          if (l.itemMessage != null)
                            Micro('Piped: "${l.itemMessage!}"'),
                          if (dietaryLabels(l.dietaryFlags).isNotEmpty)
                            Micro(dietaryLabels(l.dietaryFlags).join(', ')),
                        ],
                      ),
                    ),
                    LineNextStep(view: work.order, line: l),
                  ],
                ),
              ),

            // The journey's own move — loading the van, and saying it
            // arrived. Offered only once everything on it is ready.
            Align(
              alignment: Alignment.centerRight,
              child: SubOrderNextStep(view: work.order, sub: sub),
            ),
          ],
        ),
      ),
    );
  }
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
      for (final l in w.sub.liveLines) {
        final key = [
          l.itemName,
          if (l.flavour != null) l.flavour!,
          if (l.weight != null) l.weight!.label,
        ].join(' · ');
        totals[key] = (totals[key] ?? 0) + l.qty;
        for (final d in dietaryLabels(l.dietaryFlags)) {
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
