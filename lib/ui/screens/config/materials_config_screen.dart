import 'package:flutter/material.dart';

import '../../../app/scope.dart';
import '../../../domain/stock/model.dart';
import '../../../platform/storage/database.dart';
import '../../theme/breakpoints.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/forms.dart';
import '../../widgets/primitives.dart';

const kUnits = ['kg', 'g', 'L', 'ml', 'pcs', 'box'];

/// Raw materials and packaging. Stocking something is a separate act on the
/// Stock screen — this is only the list of what exists and when it runs low.
class MaterialsConfigScreen extends StatelessWidget {
  const MaterialsConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return Scaffold(
      backgroundColor: context.colors.paper,
      appBar: AppBar(title: const Text('Materials')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, null),
        backgroundColor: context.colors.brand,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add material'),
      ),
      body: ContentWidth(
        max: 720,
        child: StreamBuilder<List<RawMaterial>>(
        stream: app.stock.watchMaterials(),
        builder: (context, snap) {
          final items = snap.data;
          if (items == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.inventory_2_outlined,
              message: 'No materials yet.\nAdd what you buy and track.',
            );
          }

          final byCategory = <String, List<RawMaterial>>{};
          for (final i in items) {
            byCategory.putIfAbsent(i.category, () => []).add(i);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
                Space.lg, Space.sm, Space.lg, Space.xxl * 2),
            children: [
              for (final entry in byCategory.entries) ...[
                SectionLabel(entry.key == 'raw' ? 'Raw' : 'Packaging'),
                LoafCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < entry.value.length; i++) ...[
                        if (i > 0)
                          Divider(height: 1, color: context.colors.ruleSoft),
                        _MaterialRow(material: entry.value[i]),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
        ),
      ),
    );
  }
}

class _MaterialRow extends StatelessWidget {
  const _MaterialRow({required this.material});

  final RawMaterial material;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListTile(
      onTap: () => _edit(context, material),
      title: Text(
        material.name,
        style: context.text.bodyLarge!.copyWith(
          color: material.active ? c.ink : c.ink3,
          decoration: material.active ? null : TextDecoration.lineThrough,
        ),
      ),
      subtitle: Micro('Low below ${_qty(material.thresholdQty)} ${material.unit}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: material.active,
            onChanged: (v) => context.app.stock.updateMaterial(material.id, active: v),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: c.ink3),
            onPressed: () async {
              final ok = await confirmAction(
                context,
                title: 'Remove ${material.name}?',
                message: 'Its stock history goes with it. '
                    'To stop tracking it without losing the history, switch it off instead.',
                confirm: 'Remove',
                destructive: true,
              );
              if (ok && context.mounted) {
                await context.app.stock.removeMaterial(material.id);
              }
            },
          ),
        ],
      ),
    );
  }
}

String _qty(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

Future<void> _edit(BuildContext context, RawMaterial? existing) async {
  final app = context.app;
  final name = TextEditingController(text: existing?.name ?? '');
  final threshold =
      TextEditingController(text: existing == null ? '' : _qty(existing.thresholdQty));
  // Only on creation. Afterwards the level moves through stock in / waste /
  // count on the Stock screen, and a second "opening" figure would quietly
  // overwrite whatever those recorded.
  final opening = TextEditingController();
  final openingCost = TextEditingController();
  var unit = existing?.unit ?? 'kg';
  var category = existing?.category ?? 'raw';
  final formKey = GlobalKey<FormState>();

  final saved = await loafSheet<bool>(
    context,
    builder: (sheetContext) => ControllerHost(
      controllers: [name, threshold, opening, openingCost],
      child: StatefulBuilder(
      builder: (sheetContext, setSheetState) => Padding(
        padding: EdgeInsets.only(
          left: Space.lg,
          right: Space.lg,
          top: Space.lg,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + Space.lg,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(existing == null ? 'Add material' : 'Edit material',
                  style: sheetContext.text.titleMedium),
              const SizedBox(height: Space.lg),
              LoafField(
                  label: 'Name', controller: name, required: true, autofocus: true),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'raw', label: Text('Raw')),
                  ButtonSegment(value: 'packaging', label: Text('Packaging')),
                ],
                selected: {category},
                onSelectionChanged: (s) => setSheetState(() => category = s.first),
              ),
              const SizedBox(height: Space.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LoafField(
                      label: 'Low below',
                      controller: threshold,
                      required: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: qtyInput,
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  SizedBox(
                    width: 110,
                    child: DropdownButtonFormField<String>(
                      initialValue: unit,
                      // Same trap as the others: without this the field sizes
                      // to its widest item and overflows a fixed-width box.
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Unit *'),
                      items: [
                        for (final u in kUnits)
                          DropdownMenuItem(value: u, child: Text(u)),
                      ],
                      onChanged: (v) => setSheetState(() => unit = v ?? 'kg'),
                    ),
                  ),
                ],
              ),

              if (existing == null) ...[
                LoafField(
                  label: 'Stock on hand now',
                  controller: opening,
                  keyboardType: TextInputType.number,
                  inputFormatters: qtyInput,
                  helper: 'What you already have. Leave blank for none.',
                ),
                // Optional, and worth asking: this is the only price the app
                // will ever know for a material you already had. Without it
                // the first "use last price" has nothing to offer, and the
                // opening stock is worth nothing on paper.
                LoafField(
                  label: 'What that cost',
                  controller: openingCost,
                  prefix: '₹ ',
                  keyboardType: TextInputType.number,
                  inputFormatters: rupeeInput,
                  helper: 'For all of it, not per unit. Skip if you do not know.',
                ),
              ],
              const SizedBox(height: Space.md),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(sheetContext, true);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    ),
  ));

  if (saved == true) {
    final t = double.tryParse(threshold.text.trim()) ?? 0;
    final start = double.tryParse(opening.text.trim()) ?? 0;
    if (existing == null) {
      final id = await app.stock.createMaterial(
          name: name.text.trim(), category: category, unit: unit, thresholdQty: t);
      if (start > 0) {
        final cost = moneyFromField(openingCost.text);
        // With a price it is a purchase: it sets the level AND teaches the app
        // what this material costs, which is what "use last price" reads.
        // Without one it is a stocktake — you have it, you cannot say what it
        // cost, and inventing a number would be worse than leaving it blank.
        await app.stock.addMovement(
          materialId: id,
          kind: cost.isZero ? StockKind.count : StockKind.stockIn,
          qty: start,
          amount: cost.isZero ? null : cost,
        );
      }
    } else {
      await app.stock.updateMaterial(existing.id,
          name: name.text.trim(), unit: unit, thresholdQty: t);
    }
  }
}
