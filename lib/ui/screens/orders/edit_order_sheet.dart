import 'package:flutter/material.dart';

import '../../../app/scope.dart';
import '../../../common/money.dart';
import '../../../domain/orders/model.dart';
import '../../../domain/orders/repository.dart';
import '../../../platform/storage/database.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/forms.dart';
import 'address_picker.dart';

/// Change an order after it was taken.
///
/// Three things are deliberately absent: the **items**, the **message on the
/// item** and the **special requirements**. Those are what the kitchen reads
/// and may already have acted on, so they are not edited casually from here —
/// everything else about an order is a detail that legitimately changes when a
/// customer rings back.
Future<bool> editOrder(BuildContext context, Order order) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _EditOrderSheet(order: order),
  );
  return result ?? false;
}

class _EditOrderSheet extends StatefulWidget {
  const _EditOrderSheet({required this.order});

  final Order order;

  @override
  State<_EditOrderSheet> createState() => _EditOrderSheetState();
}

class _EditOrderSheetState extends State<_EditOrderSheet> {
  final _formKey = GlobalKey<FormState>();

  late Fulfilment _fulfilment = widget.order.fulfilment == 'pickup'
      ? Fulfilment.pickup
      : Fulfilment.delivery;

  late DeliveryType _deliveryType = widget.order.deliveryType == 'outstation'
      ? DeliveryType.outstation
      : DeliveryType.local;

  late final DateTime _date =
      DateTime.fromMillisecondsSinceEpoch(widget.order.deliveryDate);


  late AddressDraft? _address = widget.order.addressText == null
      ? null
      : AddressDraft(
          label: 'Delivery',
          addressText: widget.order.addressText!,
          pinLat: widget.order.pinLat,
          pinLng: widget.order.pinLng,
          pinUrl: widget.order.pinUrl,
        );

  late DiscountType? _discountType = switch (widget.order.discountType) {
    'percent' => DiscountType.percent,
    'amount' => DiscountType.amount,
    _ => null,
  };

  late final _discount = TextEditingController(
    text: switch (_discountType) {
      DiscountType.percent =>
        ((widget.order.discountValue ?? 0) / 100).toStringAsFixed(0),
      DiscountType.amount => moneyToField(Money(widget.order.discountValue ?? 0)),
      null => '',
    },
  );

  late final _delivery =
      TextEditingController(text: moneyToField(Money(widget.order.deliveryCharge)));
  late final _notes = TextEditingController(text: widget.order.notes ?? '');
  late final _itemMessage =
      TextEditingController(text: widget.order.itemMessage ?? '');

  /// The message can change while the item is still being made, but not once
  /// it is ready — by then it has been piped on.
  late final bool _messageEditable =
      canEditItemMessage(OrderStatus.parse(widget.order.status));
  late int _dietary = widget.order.dietaryFlags;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_discount, _delivery, _notes, _itemMessage]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _chooseAddress() async {
    final picked = await editAddress(context, existing: _address);
    if (!mounted || picked == null) return;
    setState(() => _address = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final orders = context.app.orders;
    final navigator = Navigator.of(context);
    final isDelivery = _fulfilment == Fulfilment.delivery;

    try {
      await orders.updateDetails(
        widget.order.id,
        fulfilment: _fulfilment,
        deliveryType: isDelivery ? _deliveryType : null,
        // A pickup has nowhere to be delivered to, so the address goes with it
        // rather than lingering on the order as a half-truth.
        addressText: isDelivery ? _address?.addressText : null,
        pinLat: isDelivery ? _address?.pinLat : null,
        pinLng: isDelivery ? _address?.pinLng : null,
        pinUrl: isDelivery ? _address?.pinUrl : null,
        discountType: _discountType,
        discountValue: _discountType == null
            ? 0
            : (_discountType == DiscountType.percent
                ? ((double.tryParse(_discount.text.trim()) ?? 0) * 100).round()
                : moneyFromField(_discount.text).paise),
        deliveryCharge:
            isDelivery ? moneyFromField(_delivery.text) : Money.zero,
        dietaryFlags: _dietary,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        // kUnchanged, not null: null would *clear* a message that is locked
        // precisely because it must not change.
        itemMessage: _messageEditable
            ? (_itemMessage.text.trim().isEmpty
                ? null
                : _itemMessage.text.trim())
            : kUnchanged,
      );
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDelivery = _fulfilment == Fulfilment.delivery;

    return Padding(
      padding: EdgeInsets.only(
        left: Space.lg,
        right: Space.lg,
        top: Space.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + Space.lg,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Edit order', style: context.text.titleMedium),
              Padding(
                padding: const EdgeInsets.only(top: Space.xs, bottom: Space.lg),
                child: Text(
                  _messageEditable
                      ? 'The items and the special requirements are not changed '
                          'here — the kitchen may already have acted on them.'
                      : 'The items, the message and the special requirements '
                          'are fixed now the order is ready.',
                  style: context.text.bodySmall!.copyWith(color: c.ink3),
                ),
              ),

              SegmentedButton<Fulfilment>(
                segments: const [
                  ButtonSegment(value: Fulfilment.delivery, label: Text('Delivery')),
                  ButtonSegment(value: Fulfilment.pickup, label: Text('Pickup')),
                ],
                selected: {_fulfilment},
                onSelectionChanged: (s) => setState(() => _fulfilment = s.first),
              ),
              const SizedBox(height: Space.lg),

              if (isDelivery) ...[
                SegmentedButton<DeliveryType>(
                  segments: [
                    for (final d in DeliveryType.values)
                      ButtonSegment(value: d, label: Text(d.label)),
                  ],
                  selected: {_deliveryType},
                  onSelectionChanged: (s) =>
                      setState(() => _deliveryType = s.first),
                ),
                const SizedBox(height: Space.lg),
                _AddressRow(
                  address: _address,
                  onChoose: _chooseAddress,
                  onClear: () => setState(() => _address = null),
                ),
              ],

              // No delivery date here. The order's is the last date among its
              // items and moves when they do (D25), so a picker would be
              // writing a value the next item change overwrote — a control
              // that looks like it works and does not.
              Row(
                children: [
                  Icon(Icons.event, size: 16, color: context.colors.ink3),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Text(
                      'Dates are set on each item. This order is due '
                      '${_dateLabel(_date)}.',
                      style: context.text.bodySmall!
                          .copyWith(color: context.colors.ink3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.lg),

              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('None')),
                  ButtonSegment(value: 1, label: Text('%')),
                  ButtonSegment(value: 2, label: Text('₹')),
                ],
                selected: {
                  switch (_discountType) {
                    null => 0,
                    DiscountType.percent => 1,
                    DiscountType.amount => 2,
                  }
                },
                onSelectionChanged: (s) => setState(() => _discountType =
                    switch (s.first) {
                      1 => DiscountType.percent,
                      2 => DiscountType.amount,
                      _ => null,
                    }),
              ),
              const SizedBox(height: Space.lg),
              if (_discountType != null)
                LoafField(
                  label: _discountType == DiscountType.percent
                      ? 'Discount %'
                      : 'Discount',
                  controller: _discount,
                  keyboardType: TextInputType.number,
                  inputFormatters: rupeeInput,
                  prefix: _discountType == DiscountType.amount ? '₹ ' : null,
                ),

              if (isDelivery)
                LoafField(
                  label: 'Delivery charge',
                  controller: _delivery,
                  prefix: '₹ ',
                  keyboardType: TextInputType.number,
                  inputFormatters: rupeeInput,
                ),

              if (_messageEditable)
                LoafField(
                  label: 'Message on the item',
                  controller: _itemMessage,
                  helper: 'Can be changed until the order is ready',
                ),

              LoafField(
                label: 'Internal notes',
                controller: _notes,
                maxLines: 2,
                helper: 'Never shown to the customer',
              ),

              Wrap(
                spacing: Space.sm,
                children: [
                  for (final (flag, label) in const [
                    (Dietary.eggless, 'Eggless'),
                    (Dietary.nutFree, 'Nut-free'),
                    (Dietary.glutenFree, 'Gluten-free'),
                    (Dietary.sugarFree, 'Sugar-free'),
                  ])
                    FilterChip(
                      label: Text(label),
                      selected: _dietary & flag != 0,
                      onSelected: (on) => setState(() =>
                          _dietary = on ? _dietary | flag : _dietary & ~flag),
                    ),
                ],
              ),
              const SizedBox(height: Space.lg),

              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving…' : 'Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _dateLabel(DateTime d) =>
      '${d.day} ${const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][d.month - 1]}';
}

/// Same shape as the one on the new-order form: a pin is the difference
/// between a courier finding the flat and phoning from the gate.
class _AddressRow extends StatelessWidget {
  const _AddressRow({
    required this.address,
    required this.onChoose,
    required this.onClear,
  });

  final AddressDraft? address;
  final VoidCallback onChoose;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final a = address;
    final c = context.colors;
    if (a == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: Space.lg),
        child: OutlinedButton.icon(
          onPressed: onChoose,
          icon: const Icon(Icons.place_outlined, size: 18),
          label: const Text('Add address'),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(a.hasPin ? Icons.place : Icons.place_outlined,
              size: 18, color: a.hasPin ? c.accent2 : c.ink3),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Text(a.addressText,
                style: context.text.bodySmall!.copyWith(color: c.ink2)),
          ),
          TextButton(onPressed: onChoose, child: const Text('Change')),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: c.ink3),
            tooltip: 'Remove address',
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}
