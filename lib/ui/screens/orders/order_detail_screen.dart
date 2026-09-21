import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/scope.dart';
import '../../../common/money.dart';
import '../../../common/phone.dart';
import '../../../domain/messaging/compose.dart';
import '../../../domain/orders/model.dart';
import '../../../domain/orders/repository.dart';
import '../../../domain/reminders/model.dart';
import '../../../platform/storage/database.dart';
import '../../theme/format.dart';
import '../../theme/breakpoints.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/forms.dart';
import '../../widgets/primitives.dart';
import 'edit_order_sheet.dart';
import 'line_editor.dart';

/// Everything about one order, and every action it can take right now.
///
/// The status row **offers** the next move; it never takes one. A cake that
/// says "Ready" said so because a person pressed Ready.
/// docs/02-domain/orders/hld.md
class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({
    super.key,
    required this.orderId,
    this.embedded = false,
  });

  final String orderId;

  /// True when shown beside the list on a tablet: no back arrow, because
  /// there is nothing to go back to.
  final bool embedded;

  @override
  Widget build(BuildContext context) => StreamBuilder<OrderView?>(
        stream: context.app.orders.watchOrder(orderId),
        builder: (context, snap) {
          final view = snap.data;
          if (view == null) {
            return Scaffold(
              backgroundColor: context.colors.paper,
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          return _Detail(view: view, embedded: embedded);
        },
      );
}

class _Detail extends StatelessWidget {
  const _Detail({required this.view, this.embedded = false});

  final OrderView view;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final o = view.order;
    final t = view.totals;
    final isPickup = o.fulfilment == 'pickup';
    final next = allowedNext(view.status);

    // Two columns when there is room AND this is the whole screen. Embedded in
    // the Orders two-pane it is already half a tablet, and splitting that
    // again gives two columns too narrow to read either.
    final wide = !context.window.isCompact && !embedded;
    final detailPane = <Widget>[
      if (view.requirementsChanged)
        Padding(
          padding: const EdgeInsets.only(bottom: Space.md),
          child: LoafAlert(
            'Requirements changed after confirming',
            icon: Icons.flag_outlined,
            action: 'Seen',
            onAction: () => context.app.orders.acknowledgeRequirements(o.id),
          ),
        ),

      _StatusRow(view: view),

      const SectionLabel('Customer'),
      LoafCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(view.customer.name, style: context.text.titleMedium),
            const SizedBox(height: 2),
            InkWell(
              onTap: () => _dial(view.customer.phoneE164),
              child: Text(Phone.parse(view.customer.phoneE164).pretty,
                  style: context.text.bodyMedium!.copyWith(color: c.accent2)),
            ),

          ],
        ),
      ),

      // Grouped into the journeys they travel on (D28). An order of a
      // cake on Friday and a box on Sunday is two trips, and reading it as
      // one flat list left no way to see which was which — or to say the
      // Friday van had left.
      for (final sub in view.subOrders) ...[
        SectionLabel(
          view.subOrders.length == 1
              ? 'Items'
              : (sub.isPickup ? 'Pickup' : 'Delivery'),
          trailing: view.subOrders.length == 1
              ? null
              : Micro(sub.reference(o.orderNo)),
        ),
        LoafCard(
          child: Column(
            children: [
              // When and where this lot goes, said once for all of it
              // rather than repeated on every item.
              Padding(
                padding: const EdgeInsets.only(bottom: Space.sm),
                child: Row(
                  children: [
                    Icon(Icons.event, size: 14, color: c.ink3),
                    const SizedBox(width: Space.xs),
                    Expanded(
                      child: Micro([
                        dayLabel(sub.deliveryDate),
                        timeLabel(sub.deliveryTime),
                        if (sub.addressText != null) sub.addressText!,
                      ].join(' · ')),
                    ),
                    _SubChip(status: sub.status, isPickup: sub.isPickup),
                  ],
                ),
              ),
              // Shown for as long as it stays true. An hour's notification
              // is easy to miss and impossible to come back to; a line on
              // the journey itself is still there when you next look.
              if (isLate(sub)) const _LateStrip(),
              // The courier link belongs to this trip. A pickup has none,
              // and a two-journey order has two.
              if (!sub.isPickup)
                _Fact('Tracking', sub.trackingUrl ?? 'Not added',
                    onTap: () async {
                  final url = await promptText(context,
                      title: 'Tracking link',
                      initial: sub.trackingUrl,
                      hint: 'https://…',
                      keyboardType: TextInputType.url);
                  if (url != null && context.mounted) {
                    await context.app.orders.setTrackingUrl(sub.id, url);
                  }
                }),
            for (final l in sub.lines) ...[
              InkWell(
                onTap: () => _editItem(context, view, l),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Space.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${l.itemName}${l.qty > 1 ? '  × ${l.qty}' : ''}',
                                style: context.text.bodyLarge!.copyWith(
                                  decoration:
                                      l.status == LineStatus.cancelled
                                          ? TextDecoration.lineThrough
                                          : null,
                                  color: l.status == LineStatus.cancelled
                                      ? c.ink3
                                      : null,
                                )),
                            if ([l.flavour, l.weight].any((x) => x != null))
                              Micro([
                                if (l.flavour != null) l.flavour!,
                                if (l.weight != null) l.weight!.label,
                              ].join(' · ')),
                            for (final a in l.addons)
                              Micro('+ ${a.name}  ${money(a.price) ?? ''}'),
                            if (l.itemMessage != null)
                              Micro('Piped: "${l.itemMessage!}"'),
                            if (l.requirements != null)
                              Micro(l.requirements!),
                            if (l.dietaryFlags != 0)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: Space.xs),
                                child: Wrap(
                                  spacing: Space.sm,
                                  children: [
                                    for (final d
                                        in dietaryLabels(l.dietaryFlags))
                                      Chip(
                                        label: Text(d),
                                        visualDensity:
                                            VisualDensity.compact,
                                        backgroundColor: c.goodSoft,
                                        side: BorderSide.none,
                                      ),
                                  ],
                                ),
                              ),
                            if (l.note != null) Micro('Note: ${l.note!}'),
                            // Each item says when it goes and where it is
                            // in its own life -- the whole point of D25 is
                            // that these differ within one order.
                            Padding(
                              padding: const EdgeInsets.only(top: Space.xs),
                              child: Wrap(
                                spacing: Space.sm,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  // No date here: the journey above says
                                  // when and where this lot goes, and
                                  // repeating it per item was three copies
                                  // of one fact.
                                  _LineChip(status: l.status),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(money(l.total, showZero: true)!,
                              style: context.text.bodyLarge),
                          LineNextStep(view: view, line: l),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (l != sub.lines.last) Divider(color: c.ruleSoft),
            ],

            // The journey's own move: loading the van, and saying it
            // arrived. Offered only once everything on it is ready.
            Align(
              alignment: Alignment.centerRight,
              child: SubOrderNextStep(view: view, sub: sub),
            ),
          ],
        ),
      ),
    ],

    LoafCard(
      child: Column(
        children: [
            // Adding to a live order is an edit, not a new order -- the
            // customer rang back, they did not place a second one.
            if (view.status != OrderStatus.completed && !view.isCancelled)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _addItem(context, view),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add item'),
                ),
              ),
          ],
        ),
      ),
    ];
    // `money` is the formatter; this needed its own name.
    final moneyPane = <Widget>[
      const SectionLabel('Money'),
      LoafCard(
        child: Column(
          children: [
            MoneyRow('Subtotal', t.subtotal),
            MoneyRow('Discount', -t.discount),
            MoneyRow('Delivery', t.deliveryCharge),
            MoneyRow('Total', t.total, strong: true, showZero: true),
            MoneyRow('Paid', t.paid),
            if (t.hasBalance)
              MoneyRow('Balance due', t.balanceDue, strong: true),
            const SizedBox(height: Space.sm),
            // No delivery charge button here. A charge belongs to a
            // journey, not to an order (D28) — this one wrote
            // `orders.delivery_charge`, which `_refreshOrderCache`
            // recomputes from the journeys and no view reads. It is set on
            // the item, in the line editor.
            Row(
              children: [
                if (t.hasBalance)
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _recordPayment(context, view),
                      child: const Text('Record payment'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),

      // What the Paid line is made of. A total with nothing behind it is
      // no help when it is wrong, and until there was a list here a
      // mistyped amount could not even be found, let alone corrected.
      _Payments(orderId: o.id),

      const SectionLabel('Move to'),
      if (next.isEmpty)
        LoafCard(
          child: Text('${view.statusLabel} — nothing further.',
              style: context.text.bodyMedium!.copyWith(color: c.ink3)),
        )
      else
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final s in next)
              s == OrderStatus.cancelled
                  ? OutlinedButton.icon(
                      onPressed: () => _cancel(context, o.id),
                      icon: const Icon(Icons.block, size: 16),
                      style: OutlinedButton.styleFrom(foregroundColor: c.bad),
                      label: const Text('Cancel'),
                    )
                  : FilledButton(
                      onPressed: () => _move(context, view, s),
                      child: Text(s.actionFor(isPickup: isPickup)),
                    ),
          ],
        ),
    ];

    return Scaffold(
      backgroundColor: c.paper,
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        title: Text(o.orderNo),
        actions: [
          // Gone once the order is out with a courier: its address and date
          // describe something already in motion.
          if (canEditOrder(view.status))
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit order',
              onPressed: () => editOrder(context, o),
            ),
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            tooltip: 'WhatsApp',
            onPressed: () => _messageSheet(context, view),
          ),
        ],
      ),
      body: ContentWidth(
        max: wide ? 1200 : 760,
        child: wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                          Space.lg, Space.sm, Space.md, Space.xxl),
                      children: detailPane,
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                          Space.md, Space.sm, Space.lg, Space.xxl),
                      children: moneyPane,
                    ),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                    Space.lg, Space.sm, Space.lg, Space.xxl),
                children: [...detailPane, ...moneyPane],
              ),
      ),
    );
  }
}

/// The chips read as history: where the order has been, where it is, and what
/// is still ahead.
class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.view});

  final OrderView view;

  /// An order has no "ready" and no "out" — items do, and the order follows
  /// the last of them. Showing steps nothing can ever reach reads as a stalled
  /// order rather than a finished one.
  static const _flow = [
    OrderStatus.created,
    OrderStatus.confirmed,
    OrderStatus.inProduction,
    OrderStatus.delivered,
    OrderStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (view.isCancelled) {
      return LoafAlert(
        'Cancelled${view.order.cancelReason == null ? '' : ' · ${view.order.cancelReason}'}',
        icon: Icons.block,
        tone: AlertTone.bad,
      );
    }
    final at = _flow.indexOf(view.status);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _flow.length; i++) ...[
            if (i > 0)
              Container(
                width: 14,
                height: 1,
                color: i <= at ? c.accent : c.rule,
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: i < at
                    ? c.accentSoft
                    : i == at
                        ? c.accent
                        : c.surface2,
                borderRadius: BorderRadius.circular(Radii.pill),
              ),
              child: Text(
                _flow[i].label,
                style: context.text.labelSmall!.copyWith(
                  color: i == at
                      ? Colors.white
                      : i < at
                          ? c.accent2
                          : c.ink3,
                  fontWeight: i == at ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value, {this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Space.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 92, child: Micro(label)),
              Expanded(
                child: Text(value,
                    style: context.text.bodyMedium!.copyWith(
                        color: onTap == null
                            ? context.colors.ink
                            : context.colors.accent2)),
              ),
              if (onTap != null)
                Icon(Icons.edit_outlined, size: 15, color: context.colors.ink3),
            ],
          ),
        ),
      );
}

// ── actions ───────────────────────────────────────────────────────────────

Future<void> _move(BuildContext context, OrderView view, OrderStatus to) async {
  final app = context.app;
  final messenger = ScaffoldMessenger.of(context);
  try {
    await app.orders.moveTo(view.order.id, to);
  } on StateError catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
    return;
  }
  if (!context.mounted) return;

  // Moving is one act; telling the customer is another. The app offers the
  // message that the new status makes sense of, and a person still presses send.
  //
  // Going out and arriving are not here: they are facts about a journey, and
  // `kAllowedTransitions` has not offered them at order level since D28.
  if (to != OrderStatus.confirmed) return;

  // Composed from the order as it now is, not the copy this screen was holding
  // before the move.
  final fresh = await app.orders.watchOrder(view.order.id).first;
  if (fresh == null || !context.mounted) return;
  await _offerMessage(context, fresh, MessageKind.confirmation);
}

/// The one step this **item** can take next, as a button.
///
/// The kitchen's two moves and nothing else: start it, and it is ready. Going
/// out and arriving belong to the journey it is on (D29) — a cake does not
/// travel on its own, and marking one delivered while the box beside it in the
/// same van was not would be a lie about one doorbell.
class LineNextStep extends StatelessWidget {
  const LineNextStep({super.key, required this.view, required this.line});

  final OrderView view;
  final OrderLine line;

  /// Cancelling is deliberately not here — it needs a reason, and a
  /// destructive action does not belong on the same gesture as the ordinary
  /// next step.
  LineStatus? get _next {
    final next = line.nextStatuses.where(
        (s) => s != LineStatus.cancelled && s != LineStatus.delivered);
    return next.isEmpty ? null : next.first;
  }

  /// Verbs, deliberately. The chip beside this says where the item *is*; a
  /// button reading the same word would be two different claims in one row.
  String _label(LineStatus to) => switch (to) {
        LineStatus.inProduction => 'Start',
        LineStatus.ready => 'Mark ready',
        _ => to.label,
      };

  @override
  Widget build(BuildContext context) {
    final to = _next;
    // An order still to be confirmed is moved as a whole, from the order's own
    // action — confirming one item of three is not a thing that happens.
    if (to == null || to == LineStatus.confirmed) return const SizedBox.shrink();

    return TextButton(
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          await context.app.orders.moveLine(line.id!, to);
        } on StateError catch (e) {
          messenger.showSnackBar(SnackBar(content: Text(e.message)));
        }
      },
      child: Text(_label(to)),
    );
  }
}

/// The journey's own move: send it out, and say it arrived (D29).
///
/// The two things no item can tell you — a cake does not know the van has
/// left. Delivering it delivers everything on it, and sends **one** message
/// naming exactly those things: two cakes to one house at four o'clock were
/// one doorbell, and three texts about it would be three too many.
class SubOrderNextStep extends StatelessWidget {
  const SubOrderNextStep({super.key, required this.view, required this.sub});

  final OrderView view;
  final SubOrder sub;

  @override
  Widget build(BuildContext context) {
    final to = sub.status.nextFor(isPickup: sub.isPickup);
    if (to == null) return const SizedBox.shrink();

    final count = sub.liveLines.length;
    final label = switch (to) {
      SubOrderStatus.out => 'Send out',
      SubOrderStatus.delivered =>
        sub.isPickup ? 'Mark collected' : 'Mark delivered',
      _ => to.label,
    };

    return FilledButton.tonal(
      onPressed: () => _go(context, to),
      child: Text(count > 1 ? '$label ($count)' : label),
    );
  }

  Future<void> _go(BuildContext context, SubOrderStatus to) async {
    final messenger = ScaffoldMessenger.of(context);
    final orders = context.app.orders;

    // Four hours past its hour, ask once. It is never refused: a van that
    // broke down still has to be recorded, and a handover the app will not
    // accept is a journey that can never be closed.
    if (to == SubOrderStatus.delivered && isVeryLate(sub)) {
      final now = DateTime.now();
      final ok = await showDialog<bool>(
        context: context,
        builder: (d) => AlertDialog(
          title: Text(sub.isPickup ? 'Collected late?' : 'Delivered late?'),
          content: Text(
            'This was due ${dayLabel(sub.deliveryDate)} at '
            '${timeLabel(sub.deliveryTime)} — more than four hours ago.\n\n'
            'It will be recorded as handed over now, at '
            '${timeLabel(now.hour * 60 + now.minute)}.',
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(d, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(d, true),
                child: const Text('Yes, record it')),
          ],
        ),
      );
      if (ok != true) return;
    }
    if (!context.mounted) return;

    // What is on it *now*, before the move. Afterwards every one of them is
    // delivered, and the message would name them all whatever happened.
    final moving = sub.liveLines;

    try {
      await orders.moveSubOrder(sub.id, to);
    } on StateError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    if (!context.mounted) return;

    final kind = switch (to) {
      SubOrderStatus.out => MessageKind.outForDelivery,
      SubOrderStatus.delivered => MessageKind.delivery,
      _ => null,
    };
    if (kind == null) return;

    // The message names what went and what is still coming, so the customer is
    // never told "your order has been delivered" while a box is outstanding.
    final fresh = await orders.watchOrder(view.order.id).first;
    if (fresh == null || !context.mounted) return;
    await _offerMessage(context, fresh, kind,
        dropLines: moving,
        isPickup: sub.isPickup,
        trackingUrl: sub.trackingUrl);
  }
}

/// Edit one item. What it *is* is only editable until a baker has started on
/// it; when and where it goes stays editable until it has gone.
Future<void> _editItem(
    BuildContext context, OrderView view, OrderLine line) async {
  if (line.status.isDone) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('This item is ${line.status.label.toLowerCase()} — '
          'it is a record of what happened now.'),
    ));
    return;
  }

  final orders = context.app.orders;
  final messenger = ScaffoldMessenger.of(context);
  final edited = await editLine(
    context,
    existing: _draftOf(
        line, view.subOrders.where((s) => s.id == line.subOrderId).firstOrNull),
    customerId: view.customer.id,
    status: line.status,
  );
  if (edited == null) return;

  try {
    await orders.updateLine(
      line.id!,
      flavour: edited.flavour,
      weight: edited.weight,
      qty: edited.qty,
      basePrice: edited.basePrice,
      note: edited.note,
      deliveryDate: edited.deliveryDate,
      deliveryTime: edited.deliveryTime,
      fulfilment: edited.fulfilment,
      deliveryType: edited.deliveryType,
      addressText: edited.addressText,
      pinLat: edited.pinLat,
      pinLng: edited.pinLng,
      pinUrl: edited.pinUrl,
    );
  } on StateError catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  }
}

Future<void> _addItem(BuildContext context, OrderView view) async {
  final orders = context.app.orders;
  // Resolved before the await below, not reached for across it.
  final messenger = ScaffoldMessenger.of(context);
  final added = await editLine(
    context,
    // Every item already on the order, so the new one can join any journey
    // they are on rather than only the most recent. Cancelled items are not
    // offered as something to be "same as".
    siblings: [
      for (final sub in view.subOrders)
        for (final l in sub.liveLines) _draftOf(l, sub),
    ],
    customerId: view.customer.id,
  );
  if (added == null) return;
  try {
    await orders.addLine(view.order.id, added);
  } on StateError catch (e) {
    // A date in the past is refused here, same as everywhere else.
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
    return;
  }
  if (!context.mounted) return;

  // The customer agreed to an order that no longer matches what is written
  // down, so they are shown the new version. Only once it has been confirmed:
  // before that, nothing has been sent and there is nothing to correct.
  if (view.order.confirmedAt == null) return;
  final fresh = await orders.watchOrder(view.order.id).first;
  if (fresh == null || !context.mounted) return;
  await _offerMessage(context, fresh, MessageKind.confirmation, isUpdate: true);
}

/// An item as the editor wants it: what it is, plus when and where its
/// journey goes — because that is what a person edits, even though the journey
/// is what stores it (D28).
DraftLine _draftOf(OrderLine l, SubOrder? sub) => DraftLine(
      menuItemId: l.menuItemId,
      itemName: l.itemName,
      flavour: l.flavour,
      weight: l.weight,
      qty: l.qty,
      basePrice: l.basePrice,
      note: l.note,
      addons: l.addons,
      itemMessage: l.itemMessage,
      requirements: l.requirements,
      dietaryFlags: l.dietaryFlags,
      // When and where comes from the journey it is on (D28).
      deliveryDate: sub?.deliveryDate,
      deliveryTime: sub?.deliveryTime,
      fulfilment: sub?.fulfilment,
      deliveryType: sub?.deliveryType,
      addressText: sub?.addressText,
      pinLat: sub?.pinLat,
      pinLng: sub?.pinLng,
      pinUrl: sub?.pinUrl,
      deliveryCharge: sub?.deliveryCharge,
    );

/// Where one journey has got to. Read beside the items it carries, so it is
/// the same size as their own chips rather than shouting over them.
class _SubChip extends StatelessWidget {
  const _SubChip({required this.status, required this.isPickup});

  final SubOrderStatus status;
  final bool isPickup;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (fg, bg) = switch (status) {
      SubOrderStatus.cancelled => (c.bad, c.badSoft),
      SubOrderStatus.delivered => (c.good, c.goodSoft),
      SubOrderStatus.out || SubOrderStatus.ready => (c.accent, c.accentSoft),
      _ => (c.ink3, c.surface2),
    };
    final label = status == SubOrderStatus.delivered && isPickup
        ? 'Collected'
        : status.label;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Space.sm, vertical: 2),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Radii.pill)),
      child: Text(label,
          style: context.text.labelSmall!.copyWith(color: fg)),
    );
  }
}

/// Where one item is in its own life. Small, because it is read alongside the
/// item rather than instead of it.
class _LineChip extends StatelessWidget {
  const _LineChip({required this.status});

  final LineStatus status;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (fg, bg) = switch (status) {
      LineStatus.cancelled => (c.bad, c.badSoft),
      LineStatus.delivered => (c.good, c.goodSoft),
      LineStatus.ready => (c.accent, c.accentSoft),
      _ => (c.ink3, c.surface2),
    };
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 2),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(Radii.sm)),
      child: Text(status.label,
          style: context.text.bodySmall!.copyWith(color: fg)),
    );
  }
}

Future<void> _cancel(BuildContext context, String orderId) async {
  final reason = await promptText(context,
      title: 'Cancel order', hint: 'Reason', confirm: 'Cancel order');
  if (reason == null || !context.mounted) return;
  await context.app.orders.moveTo(orderId, OrderStatus.cancelled, reason: reason);
}

/// Record a payment, in part or in full.
///
/// The amount starts at the balance because that is the common case, but it is
/// only a starting point: a customer paying half now and half on delivery is
/// normal, so the dialog shows what is outstanding and what will still be
/// outstanding after this payment, and never rounds either up.
Future<void> _recordPayment(BuildContext context, OrderView view) async {
  var mode = 'upi';
  final due = view.totals.balanceDue;
  final amount = TextEditingController(text: moneyToField(due));

  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => ControllerHost(
      controllers: [amount],
      child: StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: const Text('Record payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Balance due', style: dialogContext.text.bodyMedium),
                Text(money(due, showZero: true)!,
                    style: dialogContext.text.titleMedium!
                        .copyWith(color: dialogContext.colors.accent2)),
              ],
            ),
            const SizedBox(height: Space.md),
            TextField(
              controller: amount,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: rupeeInput,
              onChanged: (_) => setDialogState(() {}),
              decoration: const InputDecoration(
                labelText: 'Amount *',
                prefixText: '₹ ',
                helperText: 'Part of the balance is fine',
              ),
            ),
            const SizedBox(height: Space.sm),
            Builder(builder: (_) {
              final paying = moneyFromField(amount.text);
              final left = due - paying;
              final over = paying > due;
              return Text(
                over
                    ? 'More than the balance — the most you can take is '
                        '${money(due, showZero: true)}'
                    : left.isZero
                        ? 'Settles the order in full'
                        : '${money(left, showZero: true)} would still be due',
                style: dialogContext.text.bodySmall!.copyWith(
                    color: over
                        ? dialogContext.colors.bad
                        : dialogContext.colors.ink3),
              );
            }),
            const SizedBox(height: Space.md),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'upi', label: Text('UPI')),
                ButtonSegment(value: 'cash', label: Text('Cash')),
                ButtonSegment(value: 'transfer', label: Text('Transfer')),
              ],
              selected: {mode},
              onSelectionChanged: (s) => setDialogState(() => mode = s.first),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          // Disabled rather than warned about: taking more than is owed makes
          // the balance negative, and there is no refund flow to undo it with.
          FilledButton(
              onPressed: () {
                final paying = moneyFromField(amount.text);
                if (paying.paise <= 0 || paying > due) return;
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: _payable(amount.text, due)
                    ? null
                    : dialogContext.colors.ruleSoft,
              ),
              child: const Text('Record')),
        ],
      ),
    ),
  ));

  if (ok == true && context.mounted) {
    final value = moneyFromField(amount.text);
    // The button already refuses this, but the value is re-checked here so no
    // other route into this code can record more than is owed.
    if (value.paise > 0 && value <= due) {
      // Resolved before the awaits below, not reached for across them.
      final orders = context.app.orders;
      await orders.addPayment(
        orderId: view.order.id,
        amount: value,
        kind: view.totals.paid.isZero ? 'advance' : 'balance',
        mode: mode,
      );
      // Every payment earns a receipt, partial or final. Recording money is
      // its own trigger: a part-paid order sits at the same status before and
      // after, so nothing status-driven would ever fire for it.
      //
      // Re-read first. `view` was captured before addPayment, so its totals
      // still show the old balance — the receipt said "we have received
      // ₹1,600" and then asked for ₹1,600.
      final fresh = await orders.watchOrder(view.order.id).first;
      if (fresh != null && context.mounted) {
        await _offerMessage(context, fresh, MessageKind.paymentReceived,
            justPaid: value);
      }
    }
  }
}

// ── WhatsApp ──────────────────────────────────────────────────────────────

Future<MessageContext> _messageContext(BuildContext context, OrderView view,
    {Money? justPaid,
    List<OrderLine> dropLines = const [],
    bool? isPickup,
    String? trackingUrl,
    bool isUpdate = false}) async {
  // Both resolved before either await: reaching through context afterwards is
  // what the async-gap lint is about.
  final app = context.app;
  final s = await app.settings();
  final o = view.order;
  return MessageContext(
    customerFirstName: view.customer.name.split(' ').first,
    orderNo: o.orderNo,
    totals: view.totals,
    lines: view.lines,
    journeys: view.subOrders,
    businessName: s.businessName,
    // the order's own date is just the default new lines copy now (D25), so
    // the message quotes when the order is actually next due
    deliveryDateLabel: _dateLabel(DateTime.fromMillisecondsSinceEpoch(
        view.dueDate ?? o.deliveryDate)),
    deliveryTimeLabel: timeLabel(view.dueTime ?? o.deliveryTime),
    addressText: o.addressText,
    // The moving journey's link when there is one; the order's cache — which
    // is the finishing journey's — only as a fallback.
    trackingUrl: trackingUrl ?? o.trackingUrl,
    upiId: s.upiId,
    paymentPhone: s.paymentPhone,
    lastPayment: justPaid,
    dropLines: dropLines,
    // A message about one journey takes that journey's word for it; a message
    // about the whole order takes the one that finishes it.
    isPickup: isPickup ?? finishingSubOrder(view.subOrders)?.isPickup ?? false,
    isUpdate: isUpdate,
  );
}

/// Shows the message, lets it be read before it goes, then opens WhatsApp on
/// that customer's chat. A `wa.me` link can pre-select the chat but cannot
/// carry an attachment — which is exactly why the invoice is text.
/// docs/00-overview/decisions.md D13.
/// Whether WhatsApp is on this phone at all.
///
/// Answered by asking the system whether anything handles `whatsapp://`, which
/// works because the manifest declares that scheme — without the declaration
/// Android would say no to everything (see `<queries>`).
///
/// Not cached: installing WhatsApp mid-session is rare, and a remembered "no"
/// that outlives the install is worse than one channel call per message.
Future<bool> _hasWhatsApp() async {
  try {
    return await canLaunchUrl(Uri.parse('whatsapp://send'));
  } catch (_) {
    return false;
  }
}

Future<void> _offerMessage(
    BuildContext context, OrderView view, MessageKind kind,
    {Money? justPaid,
    List<OrderLine> dropLines = const [],
    bool? isPickup,
    String? trackingUrl,
    bool isUpdate = false}) async {
  final ctx = await _messageContext(context, view,
      justPaid: justPaid,
      dropLines: dropLines,
      isPickup: isPickup,
      trackingUrl: trackingUrl,
      isUpdate: isUpdate);
  if (!context.mounted || !isOffered(kind, ctx)) return;

  // No WhatsApp, no sheet. Composing a message somebody cannot send and then
  // putting a dead button under it wastes the one moment they were paying
  // attention. The status move has already happened either way.
  if (!await _hasWhatsApp() || !context.mounted) return;

  final text = compose(kind, ctx);

  final send = await loafSheet<bool>(
    context,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.all(Space.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_kindLabel(kind), style: sheetContext.text.titleMedium),
          const SizedBox(height: Space.md),
          Flexible(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(Space.md),
                decoration: BoxDecoration(
                  color: sheetContext.colors.surface2,
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child: SelectableText(text,
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 12, height: 1.45)),
              ),
            ),
          ),
          const SizedBox(height: Space.lg),
          FilledButton.icon(
            onPressed: () => Navigator.pop(sheetContext, true),
            icon: const Icon(Icons.chat),
            label: const Text('Open WhatsApp'),
          ),
          TextButton(
              onPressed: () => Navigator.pop(sheetContext, false),
              child: const Text('Not now')),
        ],
      ),
    ),
  );

  if (send == true && context.mounted) {
    // Opening WhatsApp with a number it cannot resolve shows a search that
    // spins and fails, and the owner's own number is the one case that works
    // anyway — so this has to be said before the hand-off, not after.
    if (!canMessage(view.customer.phoneE164)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${view.customer.name}\u2019s number needs a country '
            'code before WhatsApp can find it — edit it under More \u203a '
            'Customers'),
      ));
      return;
    }
    final messenger = ScaffoldMessenger.of(context);

    // Say so when it does not open. This returned false and told nobody, so
    // the sheet closed and WhatsApp did not appear and there was nothing to
    // go on — which is the same failure as a Drive error hidden behind a
    // generic sentence.
    var launched = false;
    for (final u in [
      // The scheme first: straight to the chat, no browser in between.
      whatsappUri(phoneE164: view.customer.phoneE164, text: text),
      // wa.me only if that somehow finds nothing, despite the check above.
      waMeUri(phoneE164: view.customer.phoneE164, text: text),
    ]) {
      try {
        launched = await launchUrl(u, mode: LaunchMode.externalApplication);
      } catch (_) {
        launched = false;
      }
      if (launched) break;
    }
    if (!launched) {
      messenger.showSnackBar(SnackBar(
        content: const Text('Could not open WhatsApp. The message is copied — '
            'paste it into the chat.'),
        action: SnackBarAction(
          label: 'Copy again',
          onPressed: () => Clipboard.setData(ClipboardData(text: text)),
        ),
      ));
      // The work of composing it should not be lost because a link failed.
      await Clipboard.setData(ClipboardData(text: text));
    }
    if (context.mounted) {
      await context.app.orders
          .logShare(view.order.id, _kindWire(kind), launched: launched);
    }
  }
}

Future<void> _messageSheet(BuildContext context, OrderView view) async {
  final messenger = ScaffoldMessenger.of(context);
  final ctx = await _messageContext(context, view);
  if (!context.mounted) return;

  // Asked for outright, so it gets an answer. An offer that arrives by itself
  // can simply not arrive; a button somebody pressed cannot do nothing.
  if (!await _hasWhatsApp()) {
    messenger.showSnackBar(const SnackBar(
      content: Text('WhatsApp is not installed on this phone.'),
    ));
    return;
  }
  if (!context.mounted) return;

  final kinds = MessageKind.values.where((k) => isOffered(k, ctx)).toList();

  await loafSheet<void>(
    context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final k in kinds)
            ListTile(
              leading: const Icon(Icons.chat_outlined),
              title: Text(_kindLabel(k)),
              onTap: () {
                Navigator.pop(sheetContext);
                _offerMessage(context, view, k);
              },
            ),
        ],
      ),
    ),
  );
}

/// Correct a payment, or take it off the order entirely.
///
/// The amount is not validated against the balance the way recording one is:
/// this is the screen for fixing a number that was already wrong, and refusing
/// the correction because the wrong number is in the way would be circular.
Future<void> _editPayment(BuildContext context, Payment p) async {
  final orders = context.app.orders;
  final messenger = ScaffoldMessenger.of(context);
  var mode = p.mode;
  final amount = TextEditingController(text: moneyToField(Money(p.amount.abs())));
  final reference = TextEditingController(text: p.reference ?? '');

  final action = await showDialog<String>(
    context: context,
    builder: (dialogContext) => ControllerHost(
      controllers: [amount, reference],
      child: StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Edit payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LoafField(
                label: 'Amount',
                controller: amount,
                prefix: '₹ ',
                keyboardType: TextInputType.number,
                inputFormatters: rupeeInput,
              ),
              const SizedBox(height: Space.md),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'upi', label: Text('UPI')),
                  ButtonSegment(value: 'cash', label: Text('Cash')),
                  ButtonSegment(value: 'transfer', label: Text('Transfer')),
                ],
                selected: {mode},
                onSelectionChanged: (v) =>
                    setDialogState(() => mode = v.first),
              ),
              const SizedBox(height: Space.md),
              LoafField(
                  label: 'Reference',
                  controller: reference,
                  hint: 'UPI reference, cheque number…'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'remove'),
              child: const Text('Remove'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'cancel'),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, 'save'),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    ),
  );

  if (action == 'remove') {
    await orders.removePayment(p.id);
    messenger.showSnackBar(
        const SnackBar(content: Text('Payment removed')));
    return;
  }
  if (action != 'save') return;

  // A refund keeps its sign; everything else is money coming in.
  final typed = moneyFromField(amount.text);
  final signed = p.kind == 'refund' ? Money(-typed.paise) : typed;
  try {
    await orders.editPayment(p.id, amount: signed, mode: mode,
        reference: reference.text.trim().isEmpty ? null : reference.text.trim());
  } on StateError catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  }
}

/// A journey past its hour and still not handed over.
class _LateStrip extends StatelessWidget {
  const _LateStrip();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: Space.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: Space.sm, vertical: Space.xs),
      decoration: BoxDecoration(
        color: c.warnSoft,
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, size: 14, color: c.warn),
          const SizedBox(width: Space.xs),
          Expanded(
            child: Text('Past its time and still not handed over',
                style: context.text.bodySmall!.copyWith(color: c.warn)),
          ),
        ],
      ),
    );
  }
}

/// Every payment on the order, each correctable and removable.
///
/// **Collapsed by default.** The Paid line above is the answer most of the
/// time; this is what you open when that number looks wrong. Oldest first, the
/// way a ledger reads, each with the day the money actually arrived.
class _Payments extends StatefulWidget {
  const _Payments({required this.orderId});

  final String orderId;

  @override
  State<_Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<_Payments> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return StreamBuilder<List<Payment>>(
      stream: context.app.orders.watchPayments(widget.orderId),
      builder: (context, snap) {
        final rows = snap.data ?? const <Payment>[];
        if (rows.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => setState(() => _open = !_open),
              child: SectionLabel(
                rows.length == 1 ? 'Payments' : 'Payments (${rows.length})',
                trailing: Icon(
                  _open ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: c.ink3,
                ),
              ),
            ),
            if (_open)
              LoafCard(
                child: Column(
                  children: [
                    for (final p in rows)
                      InkWell(
                        onTap: () => _editPayment(context, p),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: Space.sm),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      money(Money(p.amount), showZero: true)!,
                                      style: context.text.bodyMedium,
                                    ),
                                    Micro([
                                      dayLabel(p.paidAt),
                                      _payKind(p.kind),
                                      _payMode(p.mode),
                                      if (p.reference != null) p.reference!,
                                    ].join(' · ')),
                                  ],
                                ),
                              ),
                              Icon(Icons.edit_outlined,
                                  size: 16, color: c.ink3),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

String _payKind(String k) => switch (k) {
      'advance' => 'Advance',
      'refund' => 'Refund',
      _ => 'Balance',
    };

String _payMode(String m) => switch (m) {
      'cash' => 'Cash',
      'transfer' => 'Transfer',
      _ => 'UPI',
    };

String _kindLabel(MessageKind k) => switch (k) {
      MessageKind.confirmation => 'Order confirmation',
      MessageKind.outForDelivery => 'On its way',
      MessageKind.delivery => 'Delivered',
      MessageKind.paymentReceived => 'Payment received',
    };

String _kindWire(MessageKind k) => switch (k) {
      MessageKind.confirmation => 'confirmation',
      MessageKind.outForDelivery => 'out_for_delivery',
      MessageKind.delivery => 'delivery',
      MessageKind.paymentReceived => 'payment_received',
    };

Future<void> _dial(String phone) async {
  final uri = Uri.parse('tel:$phone');
  await launchUrl(uri);
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

/// Whether this amount may be recorded against a balance of [due].
bool _payable(String text, Money due) {
  final v = moneyFromField(text);
  return v.paise > 0 && v <= due;
}
