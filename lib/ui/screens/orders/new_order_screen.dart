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
  final _advance = TextEditingController();

  final List<DraftLine> _lines = [];
  String _advanceMode = 'upi';
  bool _saving = false;

  /// Set once an existing customer is chosen or matched by number. Null means
  /// this order will create one.
  String? _customerId;

  /// The address this order is going to. Null until one is picked or typed.

  /// Guards the phone lookup: the field fires onChanged on every keystroke and
  /// only the last number typed should win.
  String _lastLookedUp = '';


  // Not initState: reading AppScope is a dependency lookup, and looking one up
  // before initState has finished is illegal. didChangeDependencies is the
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
    dismissKeyboard(context);
    final picked = await pickCustomer(context);
    if (picked == null || !mounted) return;
    setState(() {
      _customerId = picked.id;
      _name.text = picked.name;
      _phone.text = Phone.parse(picked.phoneE164).national;
      _lastLookedUp = picked.phoneE164;
    });
  }

  /// Saved addresses need a customer to hang off. Without one there is still a
  /// perfectly good one-off address to type.
  @override
  void dispose() {
    for (final c in [
      _name, _phone, _requirements, _itemMessage,
      _advance,
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

  /// What a new item starts from when there is no item above to copy.
  ///
  /// Delivery inside the city is the common case, and the first item asks for
  /// its own date — there is deliberately no date here, because every item
  /// after the first copies the one above.
  DraftLine get _orderDefaults => DraftLine(
        menuItemId: '',
        itemName: '',
        fulfilment: Fulfilment.delivery,
        deliveryType: DeliveryType.local,
      );

  OrderTotals get _totals => OrderTotals(
        lines: [for (final l in _lines) l.toLine()],
        // One charge per journey (D28): items sharing a day, a time and a
        // place go out together, so their charge is counted once. Worked out
        // here from the drafts, because the journeys themselves do not exist
        // until the order is saved.
        deliveryCharge: _draftDeliveryTotal(),
        paid: moneyFromField(_advance.text),
      );

  /// What the delivery will come to, counting each journey once.
  Money _draftDeliveryTotal() {
    final byJourney = <String, int>{};
    for (final l in _lines) {
      final key = l.subOrderKey;
      if (key == null || l.fulfilment == Fulfilment.pickup) continue;
      final paise = l.deliveryCharge?.paise ?? 0;
      // The highest anything on that journey names, so a second item added
      // without a charge cannot quietly zero the trip.
      if (paise > (byJourney[key] ?? 0)) byJourney[key] = paise;
    }
    return Money(byJourney.values.fold(0, (a, b) => a + b));
  }

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
      final orderId = await app.orders.create(
        customerId: customerId,
        lines: _lines,
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

  /// The three sections, so one ListView on a phone and two beside each
  /// other on a tablet are the same screen rather than two of them.
  List<Widget> _customer(BuildContext context) {
    return [
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
    ];
  }

  List<Widget> _items(BuildContext context) {
    final c = context.colors;
    return [
          SectionLabel('Items',
              trailing: TextButton.icon(
                onPressed: () async {
                  dismissKeyboard(context);
                  final line = await editLine(
                    context,
                    // a new line starts as a copy of the one above
                    // the first line copies the order-level defaults;
                    // later ones copy the line above (D25)
                    siblings: _lines.isEmpty ? [_orderDefaults] : _lines,
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
                        dismissKeyboard(context);
                        final edited = await editLine(
                              context,
                              existing: _lines[i],
                              // Every *other* item, so this one can be moved
                              // onto any journey the order already has.
                              siblings: [
                                for (var j = 0; j < _lines.length; j++)
                                  if (j != i) _lines[j],
                              ],
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

          // No fulfilment here, and no requirements. Both belong to the
          // item (D25): an order of a birthday cake and a box of buns has
          // one message piped on one of them, and the box may go out on a
          // different day to a different address. Asking at this level as
          // well meant asking twice and letting the two disagree.
          if (_lines.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: Space.md),
              child: Row(
                children: [
                  Icon(Icons.event, size: 16, color: c.ink3),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Text(
                      _dueDate == null
                          ? 'Each item gets its own delivery date.'
                          : 'Due ${_dateLabel(DateTime.fromMillisecondsSinceEpoch(_dueDate!))} — '
                              'the last item to go.',
                      style: context.text.bodySmall!.copyWith(color: c.ink3),
                    ),
                  ),
                ],
              ),
            ),
    ];
  }

  List<Widget> _money(BuildContext context) {
    final c = context.colors;
    final t = _totals;
    return [
          const SectionLabel('Money'),
          LoafCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // No discount here. It belongs to the item now, so an offer
                // can be run on one thing — ten percent off cakes — without
                // working out what that means for a basket.
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
    ];
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
      // One column on a phone, two on a tablet. Items is the half that grows
      // — a ten-line order pushes the money off the bottom of a phone and
      // there is nothing to be done about that, but on a tablet the total can
      // simply stay in view beside it.
      body: ContentWidth(
        max: context.window.isCompact ? 760 : 1200,
        child: Form(
        key: _formKey,
        child: context.window.isCompact
            ? ListView(
                padding: const EdgeInsets.fromLTRB(
                    Space.lg, Space.sm, Space.lg, Space.xxl),
                children: [
                  ..._customer(context),
                  ..._items(context),
                  ..._money(context),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                          Space.lg, Space.sm, Space.md, Space.xxl),
                      children: [
                        ..._customer(context),
                        ..._money(context),
                      ],
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                          Space.md, Space.sm, Space.lg, Space.xxl),
                      children: _items(context),
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