import 'package:flutter/material.dart';

import '../../../app/scope.dart';
import '../../../common/money.dart';
import '../../../common/phone.dart';
import '../../../domain/orders/model.dart';
import '../../../domain/orders/repository.dart';
import '../../theme/format.dart';
import '../../theme/breakpoints.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/forms.dart';
import '../../widgets/primitives.dart';
import 'address_picker.dart';
import 'customer_picker.dart';
import 'line_editor.dart';
import 'order_detail_screen.dart';

/// One screen, not a wizard. Everything an order needs is visible at once and
/// the total updates as it is typed, because the number the customer is about
/// to be quoted should never be a surprise at the end.
class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _requirements = TextEditingController();
  final _itemMessage = TextEditingController();
  final _discount = TextEditingController();
  final _delivery = TextEditingController();
  final _advance = TextEditingController();

  final List<DraftLine> _lines = [];
  Fulfilment _fulfilment = Fulfilment.delivery;
  DeliveryType _deliveryType = DeliveryType.local;
  DiscountType? _discountType;
  int _dietary = 0;
  String _advanceMode = 'upi';
  bool _saving = false;

  /// Set once an existing customer is chosen or matched by number. Null means
  /// this order will create one.
  String? _customerId;

  /// The address this order is going to. Null until one is picked or typed.
  AddressDraft? _address;

  /// Guards the phone lookup: the field fires onChanged on every keystroke and
  /// only the last number typed should win.
  String _lastLookedUp = '';

  bool _defaultsLoaded = false;

  // Not initState: reading AppScope is a dependency lookup, and looking one up
  // before initState has finished is illegal. didChangeDependencies is the
  // first point where the scope is legitimately available.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_defaultsLoaded) return;
    _defaultsLoaded = true;
    _loadDefaultDeliveryCharge();
  }

  /// A known number fills in the name and unlocks that customer's saved
  /// addresses. Typing over the name afterwards still works — findOrCreate
  /// treats the number as the identity and updates the name.
  Phone get _typedPhone => Phone(Phone.digitsOf(_phone.text));

  Future<void> _lookUpPhone(String value) async {
    final phone = _typedPhone.e164;
    if (_phone.text.trim().length < 6 || phone == _lastLookedUp) return;
    _lastLookedUp = phone;
    final repo = context.app.customers;
    final found = await repo.byPhone(phone);
    if (!mounted || found == null) return;
    setState(() {
      _customerId = found.id;
      if (_name.text.trim().isEmpty) _name.text = found.name;
    });
  }

  Future<void> _chooseCustomer() async {
    final picked = await pickCustomer(context);
    if (picked == null || !mounted) return;
    setState(() {
      _customerId = picked.id;
      _name.text = picked.name;
      _phone.text = Phone.parse(picked.phoneE164).national;
      _lastLookedUp = picked.phoneE164;
      _address = null; // theirs, not the previous customer's
    });
  }

  /// Saved addresses need a customer to hang off. Without one there is still a
  /// perfectly good one-off address to type.
  Future<void> _chooseAddress() async {
    final id = _customerId;
    // Written as a statement rather than a ternary so the analyzer can see
    // that only one branch touches context, and neither does so after an await.
    final AddressDraft? picked;
    if (id == null) {
      picked = await editAddress(context, existing: _address);
    } else {
      picked = await pickAddress(context, customerId: id);
    }
    if (!mounted || picked == null) return;
    setState(() => _address = picked);
  }

  Future<void> _loadDefaultDeliveryCharge() async {
    final s = await context.app.settings();
    if (!mounted) return;
    setState(() => _delivery.text = moneyToField(Money(
        _deliveryType == DeliveryType.local
            ? s.deliveryChargeLocal
            : s.deliveryChargeOutstation)));
  }

  @override
  void dispose() {
    for (final c in [
      _name, _phone, _requirements, _itemMessage,
      _discount, _delivery, _advance,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// The order-level date, fulfilment and address are no longer facts about
  /// the order — they are the defaults a new line starts from (D25). Shaped as
  /// a DraftLine so the line editor can copy it exactly as it copies a real
  /// line above.
  /// What the order will be due — the last date among its items (D25).
  int? get _dueDate => _lines
      .map((l) => l.deliveryDate)
      .whereType<int>()
      .fold<int?>(null, (a, b) => a == null || b > a ? b : a);

  DraftLine get _orderDefaults => DraftLine(
        menuItemId: '',
        itemName: '',
        // deliberately no date: the first item asks for one, and every item
        // after copies the one above
        fulfilment: _fulfilment,
        deliveryType:
            _fulfilment == Fulfilment.delivery ? _deliveryType : null,
        addressText: _address?.addressText,
        pinLat: _address?.pinLat,
        pinLng: _address?.pinLng,
        pinUrl: _address?.pinUrl,
      );

  OrderTotals get _totals => OrderTotals(
        lines: [for (final l in _lines) l.toLine()],
        discountType: _discountType,
        discountValue: _discountType == DiscountType.percent
            ? ((double.tryParse(_discount.text.trim()) ?? 0) * 100).round()
            : moneyFromField(_discount.text).paise,
        deliveryCharge:
            _fulfilment == Fulfilment.delivery ? moneyFromField(_delivery.text) : Money.zero,
        paid: moneyFromField(_advance.text),
      );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add at least one item')));
      return;
    }
    setState(() => _saving = true);
    final app = context.app;
    final navigator = Navigator.of(context);
    try {
      final phone = _typedPhone;
      final customerId = await app.customers.findOrCreate(
        name: _name.text.trim(),
        phoneE164: phone.e164,
        countryCode: kDefaultCountry.code,
      );
      // A new address typed on this form is worth keeping for next time.
      final addr = _address;
      if (addr != null && addr.id == null) {
        await app.customers.addAddress(
          customerId: customerId,
          label: addr.label,
          addressText: addr.addressText,
          pinLat: addr.pinLat,
          pinLng: addr.pinLng,
          pinUrl: addr.pinUrl,
        );
      }
      final t = _totals;
      final orderId = await app.orders.create(
        customerId: customerId,
        lines: _lines,
        fulfilment: _fulfilment,
        deliveryType: _fulfilment == Fulfilment.delivery ? _deliveryType : null,
        // snapshotted onto the order, so editing the address later cannot
        // rewrite where a delivered order went
        addressText: addr?.addressText,
        pinLat: addr?.pinLat,
        pinLng: addr?.pinLng,
        pinUrl: addr?.pinUrl,
        discountType: _discountType,
        discountValue: t.discountValue,
        deliveryCharge: t.deliveryCharge,
        requirements:
            _requirements.text.trim().isEmpty ? null : _requirements.text.trim(),
        itemMessage:
            _itemMessage.text.trim().isEmpty ? null : _itemMessage.text.trim(),
        dietaryFlags: _dietary,
        advance: moneyFromField(_advance.text),
        advanceMode: _advanceMode,
      );
      navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId)));
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
    final t = _totals;

    return Scaffold(
      backgroundColor: context.colors.paper,
      appBar: AppBar(title: const Text('New order')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Micro('Total'),
                    Text(money(t.total, showZero: true)!,
                        style: context.text.titleLarge!.copyWith(color: c.accent2)),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.check),
                label: const Text('Save order'),
              ),
            ],
          ),
        ),
      ),
      body: ContentWidth(
        max: 760,
        child: Form(
        key: _formKey,
        child: ListView(
          padding:
              const EdgeInsets.fromLTRB(Space.lg, Space.sm, Space.lg, Space.xxl),
          children: [
            SectionLabel('Customer',
                trailing: TextButton.icon(
                  onPressed: _chooseCustomer,
                  icon: const Icon(Icons.person_search, size: 16),
                  label: const Text('Existing'),
                )),
            LoafCard(
              child: Column(
                children: [
                  LoafField(label: 'Name', controller: _name, required: true),
                  LoafPhoneField(
                    controller: _phone,
                    onChanged: _lookUpPhone,
                  ),
                  if (_customerId != null)
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 14, color: context.colors.accent2),
                        const SizedBox(width: Space.sm),
                        Text('Existing customer',
                            style: context.text.bodySmall!
                                .copyWith(color: context.colors.accent2)),
                      ],
                    ),
                ],
              ),
            ),

            SectionLabel('Items',
                trailing: TextButton.icon(
                  onPressed: () async {
                    final line = await editLine(
                      context,
                      // a new line starts as a copy of the one above
                      // the first line copies the order-level defaults;
                      // later ones copy the line above (D25)
                      copyFrom: _lines.isEmpty ? _orderDefaults : _lines.last,
                      customerId: _customerId,
                    );
                    if (line != null) setState(() => _lines.add(line));
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add item'),
                )),
            if (_lines.isEmpty)
              LoafCard(
                child: Text('No items yet — add at least one.',
                    style: context.text.bodyMedium!.copyWith(color: c.ink3)),
              )
            else
              LoafCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < _lines.length; i++) ...[
                      if (i > 0) Divider(height: 1, color: c.ruleSoft),
                      _LineTile(
                        line: _lines[i],
                        onEdit: () async {
                          final edited =
                              await editLine(
                                context,
                                existing: _lines[i],
                                copyFrom:
                                    i == 0 ? _orderDefaults : _lines[i - 1],
                                customerId: _customerId,
                              );
                          if (edited != null) setState(() => _lines[i] = edited);
                        },
                        onRemove: () => setState(() => _lines.removeAt(i)),
                      ),
                    ],
                  ],
                ),
              ),

            const SectionLabel('Fulfilment'),
            LoafCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<Fulfilment>(
                    segments: const [
                      ButtonSegment(
                          value: Fulfilment.delivery,
                          icon: Icon(Icons.local_shipping_outlined),
                          label: Text('Delivery')),
                      ButtonSegment(
                          value: Fulfilment.pickup,
                          icon: Icon(Icons.storefront_outlined),
                          label: Text('Pickup')),
                    ],
                    selected: {_fulfilment},
                    onSelectionChanged: (s) => setState(() => _fulfilment = s.first),
                  ),
                  if (_fulfilment == Fulfilment.delivery) ...[
                    const SizedBox(height: Space.lg),
                    SegmentedButton<DeliveryType>(
                      segments: [
                        for (final d in DeliveryType.values)
                          ButtonSegment(value: d, label: Text(d.label)),
                      ],
                      selected: {_deliveryType},
                      onSelectionChanged: (s) {
                        setState(() => _deliveryType = s.first);
                        _loadDefaultDeliveryCharge();
                      },
                    ),
                    const SizedBox(height: Space.lg),
                    _AddressRow(
                      address: _address,
                      onChoose: _chooseAddress,
                      onClear: () => setState(() => _address = null),
                    ),
                  ],
                  // No date here. Each item carries its own (D25), and the
                  // order's is whatever the last of them is — so a picker at
                  // this level would be setting something the items overwrite.
                  Row(
                    children: [
                      Icon(Icons.event, size: 16, color: c.ink3),
                      const SizedBox(width: Space.sm),
                      Expanded(
                        child: Text(
                          _lines.isEmpty
                              ? 'Each item gets its own delivery date.'
                              : 'Due ${_dateLabel(DateTime.fromMillisecondsSinceEpoch(_dueDate!))} — '
                                  'the last item to go.',
                          style: context.text.bodySmall!.copyWith(color: c.ink3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SectionLabel('Requirements'),
            LoafCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LoafField(
                      label: 'Message on the item', controller: _itemMessage),
                  LoafField(
                      label: 'Special requirements',
                      controller: _requirements,
                      maxLines: 3),
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
                          onSelected: (on) => setState(
                              () => _dietary = on ? _dietary | flag : _dietary & ~flag),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SectionLabel('Money'),
            LoafCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 128,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: Space.lg),
                          child: DropdownButtonFormField<DiscountType?>(
                            initialValue: _discountType,
                            // Without this the field takes the width of its
                            // widest item plus the arrow and overflows the box.
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'Discount'),
                            items: const [
                              DropdownMenuItem(value: null, child: Text('None')),
                              DropdownMenuItem(
                                  value: DiscountType.percent, child: Text('%')),
                              DropdownMenuItem(
                                  value: DiscountType.amount, child: Text('₹')),
                            ],
                            onChanged: (v) => setState(() => _discountType = v),
                          ),
                        ),
                      ),
                      const SizedBox(width: Space.md),
                      Expanded(
                        child: LoafField(
                          label: _discountType == DiscountType.percent
                              ? 'Percent off'
                              : 'Amount off',
                          controller: _discount,
                          keyboardType: TextInputType.number,
                          inputFormatters: rupeeInput,
                          prefix: _discountType == DiscountType.amount ? '₹ ' : null,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  if (_fulfilment == Fulfilment.delivery)
                    LoafField(
                      label: 'Delivery charge',
                      controller: _delivery,
                      prefix: '₹ ',
                      keyboardType: TextInputType.number,
                      inputFormatters: rupeeInput,
                      onChanged: (_) => setState(() {}),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: LoafField(
                          label: 'Advance received',
                          controller: _advance,
                          prefix: '₹ ',
                          keyboardType: TextInputType.number,
                          inputFormatters: rupeeInput,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: Space.md),
                      SizedBox(
                        width: 118,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: Space.lg),
                          child: DropdownButtonFormField<String>(
                            initialValue: _advanceMode,
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'Mode'),
                            items: const [
                              DropdownMenuItem(value: 'upi', child: Text('UPI')),
                              DropdownMenuItem(value: 'cash', child: Text('Cash')),
                              DropdownMenuItem(
                                  value: 'transfer', child: Text('Transfer')),
                            ],
                            onChanged: (v) => setState(() => _advanceMode = v ?? 'upi'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(color: c.ruleSoft),
                  MoneyRow('Subtotal', t.subtotal),
                  MoneyRow('Discount', -t.discount),
                  MoneyRow('Delivery', t.deliveryCharge),
                  MoneyRow('Total', t.total, strong: true, showZero: true),
                  MoneyRow('Advance', t.paid),
                  if (t.hasBalance) MoneyRow('Balance due', t.balanceDue, strong: true),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _LineTile extends StatelessWidget {
  const _LineTile({required this.line, required this.onEdit, required this.onRemove});

  final DraftLine line;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final detail = [
      if (line.flavour != null) line.flavour!,
      if (line.weight != null) line.weight!.label,
      if (line.qty > 1) '× ${line.qty}',
      for (final a in line.addons) '+ ${a.name}',
    ].join(' · ');

    return ListTile(
      onTap: onEdit,
      title: Text(line.itemName),
      subtitle: detail.isEmpty ? null : Micro(detail),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(money(line.toLine().total, showZero: true)!,
              style: context.text.bodyLarge),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: context.colors.ink3),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

String _dateLabel(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final today = DateTime.now();
  final isToday = d.year == today.year && d.month == today.month && d.day == today.day;
  final tomorrow = today.add(const Duration(days: 1));
  final isTomorrow =
      d.year == tomorrow.year && d.month == tomorrow.month && d.day == tomorrow.day;
  if (isToday) return 'Today';
  if (isTomorrow) return 'Tomorrow';
  return '${d.day} ${months[d.month - 1]}';
}

/// Shows the address the order is going to, or an invitation to pick one.
///
/// A pin is worth calling out: it is the difference between a courier finding
/// the flat and phoning from the gate.
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
          label: const Text('Choose address'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.label, style: context.text.bodyMedium),
                Text(a.addressText,
                    style: context.text.bodySmall!.copyWith(color: c.ink2)),
                if (a.hasPin)
                  Text('Map pin saved',
                      style: context.text.bodySmall!.copyWith(color: c.accent2)),
              ],
            ),
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
