import 'package:flutter/material.dart';

import '../../../app/scope.dart';
import '../../../common/money.dart';
import '../../../domain/orders/model.dart';
import '../../../domain/orders/repository.dart';
import '../../../platform/storage/database.dart';
import '../../theme/format.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/forms.dart';
import 'address_picker.dart';

/// One line of an order: pick the item from the menu, then flavour, weight,
/// quantity, base price and any number of add-ons.
///
/// The item can only come from the menu — a typed name produced items that no
/// report could group, and the menu is one tap away under More › Menu items.
///
/// Add-ons are priced **for the line**, not per unit — "gold leaf ₹200" is two
/// hundred rupees of gold leaf, not two hundred per cake.
/// docs/02-domain/orders/hld.md
Future<DraftLine?> editLine(
  BuildContext context, {
  DraftLine? existing,
  DraftLine? copyFrom,
  String? customerId,
  /// When set, what the item *is* is shown but cannot be changed — the baker
  /// has started. Only its schedule stays editable.
  LineStatus? status,
}) async {
  // Everything still being made. An item that vanished would
  // leave someone wondering whether they imagined it; one shown with a reason
  // answers the question before it is asked.
  final items = await context.app.menu.list(activeOnly: true);
  if (!context.mounted) return null;
  if (items.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('No menu items yet — add them under More › Menu items'),
    ));
    return null;
  }
  return showModalBottomSheet<DraftLine>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _LineSheet(
      menu: items,
      existing: existing,
      copyFrom: copyFrom,
      customerId: customerId,
      status: status,
    ),
  );
}

String _trimZero(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toString();

class _LineSheet extends StatefulWidget {
  const _LineSheet({
    required this.menu,
    this.existing,
    this.copyFrom,
    this.customerId,
    this.status,
  });

  final List<MenuItem> menu;
  final DraftLine? existing;

  /// The line above this one, when there is one. Its schedule is what
  /// "same as the item above" copies.
  final DraftLine? copyFrom;

  /// Lets the address picker offer this customer's saved addresses.
  final String? customerId;

  /// Null while the line is only a draft.
  final LineStatus? status;

  @override
  State<_LineSheet> createState() => _LineSheetState();
}

class _LineSheetState extends State<_LineSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _flavour = TextEditingController(text: widget.existing?.flavour ?? '');
  late final _weight = TextEditingController(
      text: widget.existing?.weight == null
          ? ''
          : _trimZero(widget.existing!.weight!.value));
  late String _weightUnit = widget.existing?.weight?.unit ?? Weight.units.first;
  late final _price =
      TextEditingController(text: moneyToField(widget.existing?.basePrice ?? Money.zero));
  late final _note = TextEditingController(text: widget.existing?.note ?? '');
  late int _qty = widget.existing?.qty ?? 1;
  late String? _menuItemId = widget.existing?.menuItemId;

  // ── the line's own schedule (D25) ──
  /// Where the schedule starts from: this line's own values when editing, and
  /// otherwise the line above — so a new item arrives **already** carrying the
  /// previous one's date and address. Most multi-item orders go to one place on
  /// one day, so the common case needs no typing at all; the "Same as above"
  /// button is for putting it back after a change, not for the first fill.
  DraftLine? get _seed => widget.existing ?? widget.copyFrom;

  /// Once the baker has started, what the item *is* is settled. The schedule
  /// is not: a van can be redirected, a cake cannot be un-baked.
  bool get _locked => widget.status?.hasStarted ?? false;

  late DateTime? _date = _seed?.deliveryDate == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(_seed!.deliveryDate!);
  late TimeOfDay? _time = _seed?.deliveryTime == null
      ? null
      : TimeOfDay(
          hour: _seed!.deliveryTime! ~/ 60,
          minute: _seed!.deliveryTime! % 60,
        );
  late Fulfilment _fulfilment = _seed?.fulfilment ?? Fulfilment.delivery;
  late DeliveryType _deliveryType = _seed?.deliveryType ?? DeliveryType.local;
  late AddressDraft? _address = _seed?.addressText == null
      ? null
      : AddressDraft(
          label: 'Delivery',
          addressText: _seed!.addressText!,
          pinLat: _seed!.pinLat,
          pinLng: _seed!.pinLng,
          pinUrl: _seed!.pinUrl,
        );

  /// Copies the line above rather than linking to it, so editing that one
  /// afterwards leaves this alone.
  void _sameAsAbove() {
    final o = widget.copyFrom;
    if (o == null) return;
    setState(() {
      _date = o.deliveryDate == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(o.deliveryDate!);
      _time = o.deliveryTime == null
          ? null
          : TimeOfDay(hour: o.deliveryTime! ~/ 60, minute: o.deliveryTime! % 60);
      _fulfilment = o.fulfilment ?? Fulfilment.delivery;
      _deliveryType = o.deliveryType ?? DeliveryType.local;
      _address = o.addressText == null
          ? null
          : AddressDraft(
              label: 'Delivery',
              addressText: o.addressText!,
              pinLat: o.pinLat,
              pinLng: o.pinLng,
              pinUrl: o.pinUrl,
            );
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 1)),
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 11, minute: 0),
    );
    setState(() => _time = picked);
  }

  Future<void> _pickAddress() async {
    final id = widget.customerId;
    final AddressDraft? picked;
    if (id == null) {
      picked = await editAddress(context, existing: _address);
    } else {
      picked = await pickAddress(context, customerId: id);
    }
    if (!mounted || picked == null) return;
    setState(() => _address = picked);
  }
  late final List<Addon> _addons = [...?widget.existing?.addons];

  @override
  void dispose() {
    for (final c in [_flavour, _weight, _price, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Money get _lineTotal =>
      moneyFromField(_price.text).times(_qty) +
      _addons.fold(Money.zero, (a, x) => a + x.price);

  Future<void> _addAddon() async {
    final nameC = TextEditingController();
    final priceC = TextEditingController();
    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => ControllerHost(
      controllers: [nameC, priceC],
      child: AlertDialog(
        title: const Text('Add-on'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameC,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'What *'),
            ),
            TextField(
              controller: priceC,
              keyboardType: TextInputType.number,
              inputFormatters: rupeeInput,
              decoration: const InputDecoration(labelText: 'Price *', prefixText: '₹ '),
            ),
            const SizedBox(height: Space.sm),
            Text('Priced for the whole line, not per unit.',
                style: dialogContext.text.bodySmall!
                    .copyWith(color: dialogContext.colors.ink3)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Add')),
        ],
      ),
    ));
    if (added == true && nameC.text.trim().isNotEmpty) {
      setState(() => _addons.add(
          Addon(name: nameC.text.trim(), price: moneyFromField(priceC.text))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
              Text(widget.existing == null ? 'Add item' : 'Edit item',
                  style: context.text.titleMedium),
              if (_locked)
                Padding(
                  padding: const EdgeInsets.only(top: Space.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lock_outline, size: 16, color: c.ink3),
                      const SizedBox(width: Space.sm),
                      Expanded(
                        child: Text(
                          'This item is ${widget.status!.label.toLowerCase()}. '
                          'When and where it goes can still change; what it is '
                          'cannot.',
                          style: context.text.bodySmall!
                              .copyWith(color: c.ink3),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: Space.lg),

              Padding(
                padding: const EdgeInsets.only(bottom: Space.lg),
                child: DropdownButtonFormField<String>(
                  initialValue: _menuItemId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Item *'),
                  items: [
                    for (final m in widget.menu)
                      DropdownMenuItem(
                        value: m.id,
                        child: Text(m.name),
                      ),
                  ],
                  onChanged:
                      _locked ? null : (v) => setState(() => _menuItemId = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ),

              LoafField(
                label: 'Flavour',
                controller: _flavour,
                enabled: !_locked,
              ),

              // A number and a unit, so the bake sheet can add weights up
              // instead of concatenating "1 kg" and "500 g" as text.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LoafField(
                      label: 'Weight',
                      controller: _weight,
                      enabled: !_locked,
                      keyboardType: TextInputType.number,
                      inputFormatters: qtyInput,
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  SizedBox(
                    width: 112,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: Space.lg),
                      child: DropdownButtonFormField<String>(
                        initialValue: _weightUnit,
                        // Without this the field takes the width of its widest
                        // item plus the arrow, which overflows the row.
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Unit'),
                        items: [
                          for (final u in Weight.units)
                            DropdownMenuItem(value: u, child: Text(u)),
                        ],
                        onChanged: _locked
                            ? null
                            : (v) => setState(
                                () => _weightUnit = v ?? Weight.units.first),
                      ),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: LoafField(
                      label: 'Base price',
                      controller: _price,
                      required: true,
                      enabled: !_locked,
                      helper: 'Price of one item',
                      prefix: '₹ ',
                      keyboardType: TextInputType.number,
                      inputFormatters: rupeeInput,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.lg),
                    child: Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: _locked || _qty <= 1
                              ? null
                              : () => setState(() => _qty--),
                          icon: const Icon(Icons.remove, size: 18),
                        ),
                        SizedBox(
                          width: 34,
                          child: Text('$_qty',
                              textAlign: TextAlign.center,
                              style: context.text.titleMedium),
                        ),
                        IconButton.filledTonal(
                          onPressed:
                              _locked ? null : () => setState(() => _qty++),
                          icon: const Icon(Icons.add, size: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SectionLabel('Add-ons',
                  trailing: TextButton.icon(
                    onPressed: _locked ? null : _addAddon,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add'),
                  )),
              for (var i = 0; i < _addons.length; i++)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(_addons[i].name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(money(_addons[i].price, showZero: true)!),
                      IconButton(
                        icon: Icon(Icons.close, size: 18, color: c.ink3),
                        onPressed: () => setState(() => _addons.removeAt(i)),
                      ),
                    ],
                  ),
                ),

              LoafField(label: 'Note for the kitchen', controller: _note, maxLines: 2),

              // ── when and where this line goes (D25) ──
              SectionLabel('When and where',
                  // A new line already arrives copied, so this is the way back
                  // after editing it — not the way in.
                  trailing: widget.copyFrom == null
                      ? null
                      : TextButton.icon(
                          onPressed: _sameAsAbove,
                          icon: const Icon(Icons.copy_all_outlined, size: 16),
                          label: const Text('Same as above'),
                        )),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.event, size: 18),
                      label: Text(_date == null
                          ? 'Delivery date *'
                          : _dayLabel(_date!)),
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.schedule, size: 18),
                      label: Text(_time == null
                          ? 'Any time'
                          : timeLabel(_time!.hour * 60 + _time!.minute)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.md),
              SegmentedButton<Fulfilment>(
                segments: const [
                  ButtonSegment(
                      value: Fulfilment.delivery, label: Text('Delivery')),
                  ButtonSegment(
                      value: Fulfilment.pickup, label: Text('Pickup')),
                ],
                selected: {_fulfilment},
                onSelectionChanged: (v) =>
                    setState(() => _fulfilment = v.first),
              ),
              if (_fulfilment == Fulfilment.delivery) ...[
                const SizedBox(height: Space.md),
                SegmentedButton<DeliveryType>(
                  segments: [
                    for (final d in DeliveryType.values)
                      ButtonSegment(value: d, label: Text(d.label)),
                  ],
                  selected: {_deliveryType},
                  onSelectionChanged: (v) =>
                      setState(() => _deliveryType = v.first),
                ),
                const SizedBox(height: Space.md),
                _LineAddress(
                  address: _address,
                  onChoose: _pickAddress,
                  onClear: () => setState(() => _address = null),
                ),
              ],
              const SizedBox(height: Space.md),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Space.lg, vertical: Space.md),
                decoration: BoxDecoration(
                  color: c.accentSoft,
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Line total', style: context.text.bodyMedium),
                    Text(money(_lineTotal, showZero: true)!,
                        style: context.text.titleMedium!
                            .copyWith(color: c.accent2)),
                  ],
                ),
              ),
              const SizedBox(height: Space.lg),
              FilledButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  if (_date == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('This item needs a delivery date'),
                    ));
                    return;
                  }
                  final picked =
                      widget.menu.firstWhere((m) => m.id == _menuItemId);
                  // Blank, 0 and junk all mean "no weight given".
                  final typed = double.tryParse(_weight.text.trim());
                  final weightValue =
                      (typed == null || typed <= 0) ? null : typed;
                  Navigator.pop(
                    context,
                    DraftLine(
                      menuItemId: picked.id,
                      itemName: picked.name,
                      flavour: _flavour.text.trim().isEmpty ? null : _flavour.text.trim(),
                      weight: weightValue == null
                          ? null
                          : Weight(weightValue, _weightUnit),
                      qty: _qty,
                      basePrice: moneyFromField(_price.text),
                      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
                      addons: _addons,
                      deliveryDate: _date == null
                          ? null
                          : DateTime(_date!.year, _date!.month, _date!.day)
                              .millisecondsSinceEpoch,
                      deliveryTime: _time == null
                          ? null
                          : _time!.hour * 60 + _time!.minute,
                      fulfilment: _fulfilment,
                      deliveryType: _fulfilment == Fulfilment.pickup
                          ? null
                          : _deliveryType,
                      addressText: _address?.addressText,
                      pinLat: _address?.pinLat,
                      pinLng: _address?.pinLng,
                      pinUrl: _address?.pinUrl,
                    ),
                  );
                },
                child: const Text('Done'),
              ),
            ],
          ),
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

/// Where this line goes. A pin is worth calling out: it is the difference
/// between a courier finding the flat and phoning from the gate.
class _LineAddress extends StatelessWidget {
  const _LineAddress({
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
      return OutlinedButton.icon(
        onPressed: onChoose,
        icon: const Icon(Icons.place_outlined, size: 18),
        label: const Text('Choose address'),
      );
    }
    return Row(
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
    );
  }
}
