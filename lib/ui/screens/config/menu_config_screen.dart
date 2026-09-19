import 'package:flutter/material.dart';

import '../../../app/scope.dart';
import '../../../platform/storage/database.dart';
import '../../theme/breakpoints.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/forms.dart';
import '../../widgets/primitives.dart';

/// The fixed items the bakery makes. The item is the category — "Cake",
/// "Croissant", "Focaccia" — so the list is flat.
///
/// No price lives here on purpose: customisation moves the price on nearly
/// every order, so a menu price would be a number that is wrong more often than
/// right. docs/02-domain/menu/hld.md
class MenuConfigScreen extends StatelessWidget {
  const MenuConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return Scaffold(
      backgroundColor: context.colors.paper,
      appBar: AppBar(title: const Text('Menu items')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, null),
        backgroundColor: context.colors.brand,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
      ),
      body: ContentWidth(
        max: 720,
        child: StreamBuilder<List<MenuItem>>(
        stream: app.menu.watchAll(),
        builder: (context, snap) {
          final items = snap.data;
          if (items == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.bakery_dining_outlined,
              message: 'No menu items yet.\nAdd what the bakery makes.',
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
                Space.lg, Space.lg, Space.lg, Space.xxl * 2),
            children: [
              LoafCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0)
                        Divider(height: 1, color: context.colors.ruleSoft),
                      _MenuRow(item: items[i]),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListTile(
      onTap: () => _edit(context, item),
      title: Text(
        item.name,
        style: context.text.bodyLarge!.copyWith(
          color: item.active ? c.ink : c.ink3,
          decoration: item.active ? null : TextDecoration.lineThrough,
        ),
      ),
      subtitle: item.leadDays > 0
          ? Micro('${item.leadDays} day${item.leadDays == 1 ? '' : 's'} notice')
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: item.active,
            onChanged: (v) => context.app.menu.update(item.id, active: v),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: c.ink3),
            onPressed: () async {
              final ok = await confirmAction(
                context,
                title: 'Remove ${item.name}?',
                message: 'Past orders keep the name they were taken with. '
                    'To stop offering it without removing it, switch it off instead.',
                confirm: 'Remove',
                destructive: true,
              );
              if (ok && context.mounted) {
                await context.app.menu.remove(item.id);
              }
            },
          ),
        ],
      ),
    );
  }
}

Future<void> _edit(BuildContext context, MenuItem? existing) async {
  final app = context.app;
  final name = TextEditingController(text: existing?.name ?? '');
  final lead = TextEditingController(text: '${existing?.leadDays ?? 0}');
  // Months only. A season is "November to January", never "the 3rd of
  // November" — storing a day would invite a precision nobody wants.
  var seasonFrom = existing?.seasonFrom;
  var seasonTo = existing?.seasonTo;
  final formKey = GlobalKey<FormState>();

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => ControllerHost(
      controllers: [name, lead],
      // The season pickers change what the sheet says about itself, so it has
      // to rebuild without rebuilding the screen behind it.
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
            Text(existing == null ? 'Add menu item' : 'Edit menu item',
                style: sheetContext.text.titleMedium),
            const SizedBox(height: Space.lg),
            LoafField(
              label: 'Item',
              controller: name,
              required: true,
              autofocus: true,
              hint: 'Cake, Croissant, Focaccia…',
            ),
            LoafField(
              label: 'Notice needed (days)',
              controller: lead,
              keyboardType: TextInputType.number,
              inputFormatters: qtyInput,
            ),
            const SectionLabel('Season'),
            Text(
              seasonFrom == null
                  ? 'Made all year.'
                  : 'Only offered ${_monthName(seasonFrom!)} to '
                      '${_monthName(seasonTo!)}.',
              style: sheetContext.text.bodySmall!
                  .copyWith(color: sheetContext.colors.ink3),
            ),
            const SizedBox(height: Space.sm),
            Row(
              children: [
                Expanded(
                  child: _MonthPicker(
                    label: 'From',
                    value: seasonFrom,
                    onChanged: (v) => setSheetState(() {
                      seasonFrom = v;
                      // A half-set season would be meaningless, and the schema
                      // has a CHECK that says so.
                      if (v == null) seasonTo = null;
                      seasonTo ??= v;
                    }),
                  ),
                ),
                const SizedBox(width: Space.md),
                Expanded(
                  child: _MonthPicker(
                    label: 'To',
                    value: seasonTo,
                    enabled: seasonFrom != null,
                    onChanged: (v) => setSheetState(() => seasonTo = v),
                  ),
                ),
              ],
            ),
            if (seasonFrom != null && seasonTo != null && seasonFrom! > seasonTo!)
              Padding(
                padding: const EdgeInsets.only(top: Space.sm),
                child: Text(
                  'Wraps the year — ${_monthName(seasonFrom!)} through to '
                  '${_monthName(seasonTo!)}.',
                  style: sheetContext.text.bodySmall!
                      .copyWith(color: sheetContext.colors.ink3),
                ),
              ),
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
  )));

  if (saved == true) {
    final leadDays = int.tryParse(lead.text.trim()) ?? 0;
    if (existing == null) {
      await app.menu.create(
        name: name.text.trim(),
        leadDays: leadDays,
        seasonFrom: seasonFrom,
        seasonTo: seasonTo,
      );
    } else {
      await app.menu.update(
        existing.id,
        name: name.text.trim(),
        leadDays: leadDays,
        seasonFrom: seasonFrom,
        seasonTo: seasonTo,
      );
    }
  }

}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _monthName(int monthDay) => _months[(monthDay ~/ 100) - 1];

/// A month, stored as the MMDD the schema wants.
///
/// "From" takes the first of the month and "to" the last, so a season set as
/// Nov–Jan actually runs to the 31st rather than stopping on the 1st.
class _MonthPicker extends StatelessWidget {
  const _MonthPicker({
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;
  final bool enabled;

  static const _lastDay = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  bool get _isTo => label == 'To';

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<int?>(
        initialValue: value == null ? null : (value! ~/ 100),
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: [
          const DropdownMenuItem<int?>(value: null, child: Text('All year')),
          for (var m = 1; m <= 12; m++)
            DropdownMenuItem<int?>(value: m, child: Text(_months[m - 1])),
        ],
        onChanged: enabled
            ? (m) => onChanged(
                m == null ? null : m * 100 + (_isTo ? _lastDay[m - 1] : 1))
            : null,
      );
}
