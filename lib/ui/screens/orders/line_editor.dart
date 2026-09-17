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

/// One line of an order: pick the item from the menu, then flavour, weight,
/// quantity, base price and any number of add-ons.
///
/// The item can only come from the menu — a typed name produced items that no
/// report could group, and the menu is one tap away under More › Menu items.
///
/// Add-ons are priced **for the line**, not per unit — "gold leaf ₹200" is two
/// hundred rupees of gold leaf, not two hundred per cake.
/// docs/02-domain/orders/hld.md
Future<DraftLine?> editLine(BuildContext context, {DraftLine? existing}) async {
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
    builder: (_) => _LineSheet(menu: items, existing: existing),
  );
}

String _trimZero(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toString();

class _LineSheet extends StatefulWidget {
  const _LineSheet({required this.menu, this.existing});

  final List<MenuItem> menu;
  final DraftLine? existing;

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
              const SizedBox(height: Space.lg),

              Padding(
                padding: const EdgeInsets.only(bottom: Space.lg),
                child: DropdownButtonFormField<String>(
                  initialValue: _menuItemId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Item *'),
                  items: [
                    for (final m in widget.menu)
                      DropdownMenuItem(value: m.id, child: Text(m.name)),
                  ],
                  onChanged: (v) => setState(() => _menuItemId = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ),

              LoafField(label: 'Flavour', controller: _flavour),

              // A number and a unit, so the bake sheet can add weights up
              // instead of concatenating "1 kg" and "500 g" as text.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LoafField(
                      label: 'Weight',
                      controller: _weight,
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
                        onChanged: (v) =>
                            setState(() => _weightUnit = v ?? Weight.units.first),
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
                          onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                          icon: const Icon(Icons.remove, size: 18),
                        ),
                        SizedBox(
                          width: 34,
                          child: Text('$_qty',
                              textAlign: TextAlign.center,
                              style: context.text.titleMedium),
                        ),
                        IconButton.filledTonal(
                          onPressed: () => setState(() => _qty++),
                          icon: const Icon(Icons.add, size: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SectionLabel('Add-ons',
                  trailing: TextButton.icon(
                    onPressed: _addAddon,
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
