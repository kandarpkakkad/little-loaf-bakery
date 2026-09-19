import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/scope.dart';
import '../../../common/money.dart';
import '../../../common/phone.dart';
import '../../../domain/messaging/compose.dart';
import '../../../domain/orders/model.dart';
import '../../../domain/orders/repository.dart';
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
    final next = allowedNext(view.status, isPickup: isPickup);

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
        max: 760,
        child: ListView(
        padding: const EdgeInsets.fromLTRB(Space.lg, Space.sm, Space.lg, Space.xxl),
        children: [
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
                if (o.addressText != null) ...[
                  const SizedBox(height: Space.sm),
                  Text(o.addressText!, style: context.text.bodySmall),
                ],
              ],
            ),
          ),

          const SectionLabel('Delivery'),
          LoafCard(
            child: Column(
              children: [
                _Fact(
                    'When',
                    '${_dateLabel(DateTime.fromMillisecondsSinceEpoch(o.deliveryDate))}'
                        ' · ${timeLabel(o.deliveryTime)}'),
                _Fact(
                    'How',
                    o.fulfilment == 'pickup'
                        ? 'Pickup'
                        : 'Delivery · ${o.deliveryType == 'outstation' ? 'Out of city' : 'Inside city'}'),
                if (o.fulfilment == 'delivery')
                  _Fact('Tracking', o.trackingUrl ?? 'Not added',
                      onTap: () async {
                    final url = await promptText(context,
                        title: 'Tracking link',
                        initial: o.trackingUrl,
                        hint: 'https://…',
                        keyboardType: TextInputType.url);
                    if (url != null && context.mounted) {
                      await context.app.orders.setTrackingUrl(o.id, url);
                    }
                  }),
              ],
            ),
          ),

          if (o.itemMessage != null ||
              o.requirements != null ||
              o.dietaryFlags != 0) ...[
            const SectionLabel('Requirements'),
            LoafCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (o.itemMessage != null)
                    _Fact('On the item', o.itemMessage!),
                  if (o.dietaryFlags != 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Space.xs),
                      child: Wrap(
                        spacing: Space.sm,
                        children: [
                          for (final l in Dietary.labels(o.dietaryFlags))
                            Chip(
                              label: Text(l),
                              visualDensity: VisualDensity.compact,
                              backgroundColor: c.goodSoft,
                              side: BorderSide.none,
                            ),
                        ],
                      ),
                    ),
                  if (o.requirements != null)
                    Padding(
                      padding: const EdgeInsets.only(top: Space.xs),
                      child: Text(o.requirements!, style: context.text.bodyMedium),
                    ),
                ],
              ),
            ),
          ],

          const SectionLabel('Items'),
          LoafCard(
            child: Column(
              children: [
                for (final l in view.lines) ...[
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
                                      _LineChip(status: l.status),
                                      if (l.deliveryDate != null)
                                        Micro([
                                          _dateLabel(
                                              DateTime.fromMillisecondsSinceEpoch(
                                                  l.deliveryDate!)),
                                          if (l.deliveryTime != null)
                                            timeLabel(l.deliveryTime),
                                          if (l.fulfilment == Fulfilment.pickup)
                                            'pickup',
                                        ].join(' · ')),
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
                  if (l != view.lines.last) Divider(color: c.ruleSoft),
                ],
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
                Row(
                  children: [
                    if (o.fulfilment == 'delivery')
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final v = await promptText(context,
                                title: 'Delivery charge',
                                initial: moneyToField(Money(o.deliveryCharge)),
                                keyboardType: TextInputType.number);
                            if (v != null && context.mounted) {
                              await context.app.orders
                                  .setDeliveryCharge(o.id, moneyFromField(v));
                            }
                          },
                          child: const Text('Delivery charge'),
                        ),
                      ),
                    if (o.fulfilment == 'delivery' && t.hasBalance)
                      const SizedBox(width: Space.md),
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
        ],
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

  static const _flow = [
    OrderStatus.created,
    OrderStatus.confirmed,
    OrderStatus.inProduction,
    OrderStatus.ready,
    OrderStatus.out,
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
  final kind = switch (to) {
    OrderStatus.confirmed => MessageKind.confirmation,
    OrderStatus.out => MessageKind.outForDelivery,
    OrderStatus.delivered => MessageKind.delivery,
    _ => null,
  };
  if (kind != null) await _offerMessage(context, view, kind);
}

/// Move every line of one drop together, then offer the one message that
/// describes it.
///
/// A drop is a journey: lines sharing a day, a time and a destination. Moving
/// them one at a time would be three taps and three identical texts for what
/// the customer experienced as one doorbell.
Future<void> moveDrop(
  BuildContext context,
  OrderView view,
  Drop drop,
  LineStatus to,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final orders = context.app.orders;
  try {
    for (final line in drop.lines) {
      if (line.status.canGoTo(to)) await orders.moveLine(line.id!, to);
    }
  } on StateError catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
    return;
  }
  if (!context.mounted) return;

  final kind = switch (to) {
    LineStatus.out => MessageKind.outForDelivery,
    LineStatus.delivered => MessageKind.delivery,
    _ => null,
  };
  if (kind == null) return;

  // The message names what arrived and what is still coming, so the customer
  // is never told "your order has been delivered" while a box is outstanding.
  final fresh = await orders.watchOrder(view.order.id).first;
  if (fresh == null || !context.mounted) return;
  await _offerMessage(context, fresh, kind, dropLines: drop.lines);
}

/// The one step this item can take next, as a button.
///
/// Baking is per item; handing over is per **drop**. So "Start" and "Ready"
/// move this item alone, while "Send out" and "Delivered" move everything
/// travelling with it — two cakes going to the same house at 4pm leave in one
/// van, and marking them separately would send the customer two texts about
/// one doorbell.
class LineNextStep extends StatelessWidget {
  const LineNextStep({super.key, required this.view, required this.line});

  final OrderView view;
  final OrderLine line;

  /// The single step worth offering. Cancelling is deliberately not here — it
  /// needs a reason, and a destructive action does not belong on the same
  /// gesture as the ordinary next step.
  LineStatus? get _next {
    final next = line.nextStatuses.where((s) => s != LineStatus.cancelled);
    if (next.isEmpty) return null;
    // ready → {out, delivered}: a delivery goes out, a pickup is collected.
    if (next.contains(LineStatus.out)) return LineStatus.out;
    if (next.contains(LineStatus.delivered)) return LineStatus.delivered;
    return next.first;
  }

  /// Verbs, deliberately. The chip beside this says where the item *is*; a
  /// button reading the same word would be two different claims in one row.
  String _label(LineStatus to) => switch (to) {
        LineStatus.confirmed => 'Confirm',
        LineStatus.inProduction => 'Start',
        LineStatus.ready => 'Mark ready',
        LineStatus.out => 'Send out',
        LineStatus.delivered =>
          line.fulfilment == Fulfilment.pickup ? 'Mark collected' : 'Mark delivered',
        _ => to.label,
      };

  bool _isHandover(LineStatus to) =>
      to == LineStatus.out || to == LineStatus.delivered;

  @override
  Widget build(BuildContext context) {
    final to = _next;
    // An order still to be confirmed is moved as a whole, from the order's own
    // action — confirming one item of three is not a thing that happens.
    if (to == null || to == LineStatus.confirmed) return const SizedBox.shrink();

    final drop = dropFor(line, view.liveLines);
    final travelsWith = _isHandover(to) ? drop.lines.length : 1;

    return TextButton(
      onPressed: () => _go(context, to, drop),
      child: Text(
        travelsWith > 1 ? '${_label(to)} ($travelsWith)' : _label(to),
      ),
    );
  }

  Future<void> _go(BuildContext context, LineStatus to, Drop drop) async {
    if (_isHandover(to)) {
      await moveDrop(context, view, drop, to);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.app.orders.moveLine(line.id!, to);
    } on StateError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
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
    existing: _draftOf(line),
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
  final added = await editLine(
    context,
    // a new item starts from the last one, as it does on the order form
    copyFrom: view.lines.isEmpty ? null : _draftOf(view.lines.last),
    customerId: view.customer.id,
  );
  if (added == null) return;
  await orders.addLine(view.order.id, added);
  if (!context.mounted) return;

  // The customer agreed to an order that no longer matches what is written
  // down, so they are shown the new version. Only once it has been confirmed:
  // before that, nothing has been sent and there is nothing to correct.
  if (view.order.confirmedAt == null) return;
  final fresh = await orders.watchOrder(view.order.id).first;
  if (fresh == null || !context.mounted) return;
  await _offerMessage(context, fresh, MessageKind.confirmation, isUpdate: true);
}

DraftLine _draftOf(OrderLine l) => DraftLine(
      menuItemId: l.menuItemId,
      itemName: l.itemName,
      flavour: l.flavour,
      weight: l.weight,
      qty: l.qty,
      basePrice: l.basePrice,
      note: l.note,
      addons: l.addons,
      deliveryDate: l.deliveryDate,
      deliveryTime: l.deliveryTime,
      fulfilment: l.fulfilment,
      deliveryType: l.deliveryType,
      addressText: l.addressText,
      pinLat: l.pinLat,
      pinLng: l.pinLng,
      pinUrl: l.pinUrl,
    );

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
      LineStatus.out || LineStatus.ready => (c.accent, c.accentSoft),
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
      await context.app.orders.addPayment(
        orderId: view.order.id,
        amount: value,
        kind: view.totals.paid.isZero ? 'advance' : 'balance',
        mode: mode,
      );
      // Every payment earns a receipt, partial or final. Recording money is
      // its own trigger: a part-paid order sits at the same status before and
      // after, so nothing status-driven would ever fire for it.
      if (context.mounted) {
        await _offerMessage(context, view, MessageKind.paymentReceived,
            justPaid: value);
      }
    }
  }
}

// ── WhatsApp ──────────────────────────────────────────────────────────────

Future<MessageContext> _messageContext(BuildContext context, OrderView view,
    {Money? justPaid,
    List<OrderLine> dropLines = const [],
    bool isUpdate = false}) async {
  final s = await context.app.settings();
  final o = view.order;
  return MessageContext(
    customerFirstName: view.customer.name.split(' ').first,
    orderNo: o.orderNo,
    totals: view.totals,
    lines: view.lines,
    businessName: s.businessName,
    // the order's own date is just the default new lines copy now (D25), so
    // the message quotes when the order is actually next due
    deliveryDateLabel: _dateLabel(DateTime.fromMillisecondsSinceEpoch(
        view.dueDate ?? o.deliveryDate)),
    deliveryTimeLabel: timeLabel(view.dueTime ?? o.deliveryTime),
    addressText: o.addressText,
    trackingUrl: o.trackingUrl,
    itemMessage: o.itemMessage,
    requirements: o.requirements,
    upiId: s.upiId,
    paymentPhone: s.paymentPhone,
    hadBalance: view.totals.hasBalance,
    lastPayment: justPaid,
    dropLines: dropLines,
    isUpdate: isUpdate,
  );
}

/// Shows the message, lets it be read before it goes, then opens WhatsApp on
/// that customer's chat. A `wa.me` link can pre-select the chat but cannot
/// carry an attachment — which is exactly why the invoice is text.
/// docs/00-overview/decisions.md D13.
Future<void> _offerMessage(
    BuildContext context, OrderView view, MessageKind kind,
    {Money? justPaid,
    List<OrderLine> dropLines = const [],
    bool isUpdate = false}) async {
  final ctx = await _messageContext(context, view,
      justPaid: justPaid, dropLines: dropLines, isUpdate: isUpdate);
  if (!context.mounted || !isOffered(kind, ctx)) return;
  final text = compose(kind, ctx);

  final send = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
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
    final uri = waMeUri(phoneE164: view.customer.phoneE164, text: text);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (context.mounted) {
      await context.app.orders
          .logShare(view.order.id, _kindWire(kind), launched: launched);
    }
  }
}

Future<void> _messageSheet(BuildContext context, OrderView view) async {
  final ctx = await _messageContext(context, view);
  if (!context.mounted) return;
  final kinds = MessageKind.values.where((k) => isOffered(k, ctx)).toList();

  await showModalBottomSheet<void>(
    context: context,
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

String _kindLabel(MessageKind k) => switch (k) {
      MessageKind.confirmation => 'Order confirmation',
      MessageKind.outForDelivery => 'On its way',
      MessageKind.delivery => 'Delivered',
      MessageKind.paymentReceived => 'Payment received',
      MessageKind.invoice => 'Invoice',
    };

String _kindWire(MessageKind k) => switch (k) {
      MessageKind.confirmation => 'confirmation',
      MessageKind.outForDelivery => 'out_for_delivery',
      MessageKind.delivery => 'delivery',
      MessageKind.paymentReceived => 'payment_received',
      MessageKind.invoice => 'invoice',
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
