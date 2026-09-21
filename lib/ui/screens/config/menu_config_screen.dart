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
  // Empty for a new item, not '0'. A zero typed into the box by the app is a
  // value somebody has to notice and delete; a placeholder says the same thing
  // and leaves the field alone.
  final lead = TextEditingController(
      text: existing == null ? '' : '${existing.leadDays}');
  final formKey = GlobalKey<FormState>();

  final saved = await loafSheet<bool>(
    context,
    builder: (sheetContext) => ControllerHost(
      controllers: [name, lead],
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
              hint: '0 for same day',
              controller: lead,
              keyboardType: TextInputType.number,
              inputFormatters: qtyInput,
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
      );
    } else {
      await app.menu.update(
        existing.id,
        name: name.text.trim(),
        leadDays: leadDays,
      );
    }
  }

}
