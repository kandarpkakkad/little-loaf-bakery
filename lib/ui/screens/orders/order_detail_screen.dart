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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Space.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${l.itemName}${l.qty > 1 ? '  × ${l.qty}' : ''}',
                                  style: context.text.bodyLarge),
                              if ([l.flavour, l.weight].any((x) => x != null))
                                Micro([
                                  if (l.flavour != null) l.flavour!,
                                  if (l.weight != null) l.weight!.label,
                                ].join(' · ')),
                              for (final a in l.addons)
                                Micro('+ ${a.name}  ${money(a.price) ?? ''}'),
                              if (l.note != null) Micro('Note: ${l.note!}'),
                            ],
                          ),
                        ),
                        Text(money(l.total, showZero: true)!,
                            style: context.text.bodyLarge),
                      ],
                    ),
                  ),
                  if (l != view.lines.last) Divider(color: c.ruleSoft),
                ],
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
      final hadBalance = view.totals.hasBalance;
      await context.app.orders.addPayment(
        orderId: view.order.id,
        amount: value,
        kind: view.totals.paid.isZero ? 'advance' : 'balance',
        mode: mode,
      );
      // Offered only when there was a balance to clear — otherwise the
      // customer already knows, and the delivery message thanked them.
      if (hadBalance && context.mounted) {
        await _offerMessage(context, view, MessageKind.paymentReceived);
      }
    }
  }
}

// ── WhatsApp ──────────────────────────────────────────────────────────────

Future<MessageContext> _messageContext(BuildContext context, OrderView view) async {
  final s = await context.app.settings();
  final o = view.order;
  return MessageContext(
    customerFirstName: view.customer.name.split(' ').first,
    orderNo: o.orderNo,
    totals: view.totals,
    lines: view.lines,
    businessName: s.businessName,
    deliveryDateLabel:
        _dateLabel(DateTime.fromMillisecondsSinceEpoch(o.deliveryDate)),
    deliveryTimeLabel: timeLabel(o.deliveryTime),
    addressText: o.addressText,
    trackingUrl: o.trackingUrl,
    itemMessage: o.itemMessage,
    requirements: o.requirements,
    upiId: s.upiId,
    paymentPhone: s.paymentPhone,
    hadBalance: view.totals.hasBalance,
  );
}

/// Shows the message, lets it be read before it goes, then opens WhatsApp on
/// that customer's chat. A `wa.me` link can pre-select the chat but cannot
/// carry an attachment — which is exactly why the invoice is text.
/// docs/00-overview/decisions.md D13.
Future<void> _offerMessage(
    BuildContext context, OrderView view, MessageKind kind) async {
  final ctx = await _messageContext(context, view);
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
