import 'package:flutter/material.dart';

import '../../../app/scope.dart';
import '../../../common/money.dart';
import '../../../domain/stock/model.dart';
import '../../../domain/stock/repository.dart';
import '../../theme/format.dart';
import '../../theme/breakpoints.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/forms.dart';
import '../../widgets/primitives.dart';
import '../config/materials_config_screen.dart';

/// What is on the shelf. One bar per material, nothing written underneath it —
/// the bar is the whole answer, and a line of supplier and price under every
/// row turns a glance into reading.
class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.paper,
      appBar: AppBar(
        title: const Text('Stock'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Materials',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MaterialsConfigScreen())),
          ),
        ],
      ),
      body: StreamBuilder<List<StockLevel>>(
        stream: context.app.stock.watchLevels(),
        builder: (context, snap) {
          final levels = snap.data;
          if (levels == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (levels.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              message: 'No materials yet.',
              action: 'Add materials',
              onAction: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MaterialsConfigScreen())),
            );
          }

          final low = levels.where((l) => l.state == StockState.below).toList();

          return ContentWidth(
            max: 820,
            child: ListView(
            padding: const EdgeInsets.fromLTRB(
                Space.lg, Space.md, Space.lg, Space.xxl * 2),
            children: [
              if (low.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.md),
                  child: LoafAlert(
                    low.length == 1
                        ? '${low.first.material.name} is below threshold'
                        : '${low.length} materials below threshold',
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
              CardGrid(children: [for (final l in levels) _StockRow(level: l)]),
            ],
          ),
          );
        },
      ),
    );
  }
}

class _StockRow extends StatelessWidget {
  const _StockRow({required this.level});

  final StockLevel level;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final m = level.material;

    return InkWell(
      onTap: () => _addStock(context, level),
      borderRadius: BorderRadius.circular(Radii.md),
      child: Container(
        margin: const EdgeInsets.only(bottom: Space.md),
        padding: const EdgeInsets.all(Space.lg),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: c.ruleSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(m.name, style: context.text.titleSmall)),
                Text('${_qty(level.level)} ${m.unit}',
                    style: context.text.titleSmall!.copyWith(
                      color: switch (level.state) {
                        StockState.below => c.bad,
                        StockState.near => c.warn,
                        StockState.ok => c.ink,
                      },
                    )),
              ],
            ),
            const SizedBox(height: Space.sm),
            StockBar(
              level: level.level,
              reference: level.reference,
              threshold: level.threshold,
            ),
          ],
        ),
      ),
    );
  }
}

String _qty(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

/// Stocking something is one entry: how much, and what it cost. No supplier, no
/// bill number, no batch — none of that is recorded anywhere else either, and a
/// field nobody fills is a field that makes the form look unfinished.
Future<void> _addStock(BuildContext context, StockLevel level) async {
  final qty = TextEditingController();
  final amount = TextEditingController();
  var kind = StockKind.stockIn;
  var useLastPrice = false;
  final rate = level.lastRate;

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => ControllerHost(
      controllers: [qty, amount],
      child: StatefulBuilder(
      builder: (sheetContext, setSheetState) {
        void recompute() {
          if (!useLastPrice || rate == null) return;
          final q = double.tryParse(qty.text.trim()) ?? 0;
          amount.text = moneyToField(Money((rate.paise * q).round()));
        }

        return Padding(
          padding: EdgeInsets.only(
            left: Space.lg,
            right: Space.lg,
            top: Space.lg,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + Space.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(level.material.name, style: sheetContext.text.titleMedium),
              Micro('Now ${_qty(level.level)} ${level.material.unit}'),
              const SizedBox(height: Space.lg),
              SegmentedButton<StockKind>(
                segments: const [
                  ButtonSegment(value: StockKind.stockIn, label: Text('Add')),
                  ButtonSegment(value: StockKind.waste, label: Text('Waste')),
                  ButtonSegment(value: StockKind.count, label: Text('Count')),
                ],
                selected: {kind},
                onSelectionChanged: (s) => setSheetState(() => kind = s.first),
              ),
              const SizedBox(height: Space.lg),
              LoafField(
                label: kind == StockKind.count
                    ? 'Counted level (${level.material.unit})'
                    : 'Quantity (${level.material.unit})',
                controller: qty,
                required: true,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: qtyInput,
                onChanged: (_) => setSheetState(recompute),
              ),
              if (kind == StockKind.stockIn) ...[
                LoafField(
                  label: 'Amount paid',
                  controller: amount,
                  prefix: '₹ ',
                  keyboardType: TextInputType.number,
                  inputFormatters: rupeeInput,
                ),
                if (rate != null)
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: useLastPrice,
                    title: Text('Use last price — ${money(rate)}/${level.material.unit}',
                        style: sheetContext.text.bodySmall),
                    onChanged: (v) => setSheetState(() {
                      useLastPrice = v ?? false;
                      recompute();
                    }),
                  ),
              ],
              const SizedBox(height: Space.sm),
              FilledButton(
                onPressed: () => Navigator.pop(sheetContext, true),
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    ),
  ));

  if (saved == true && context.mounted) {
    final q = double.tryParse(qty.text.trim());
    if (q != null && q >= 0) {
      final paid = moneyFromField(amount.text);
      await context.app.stock.addMovement(
        materialId: level.material.id,
        kind: kind,
        qty: q,
        // Left null rather than zero when nothing was typed, so "unknown" stays
        // unknown and never becomes a rate of ₹0.
        amount: paid.isZero ? null : paid,
      );
    }
  }
}
