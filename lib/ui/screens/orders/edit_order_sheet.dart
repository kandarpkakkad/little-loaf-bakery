import 'package:flutter/material.dart';

import '../../../app/scope.dart';
import '../../../platform/storage/database.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/forms.dart';

/// Change an order after it was taken.
///
/// What is left here is what belongs to the **order** rather than to any item:
/// the discount, and notes nobody outside the bakery sees. Everything else
/// moved down to the item, where it always belonged — when a thing goes out,
/// how, to what address, what is piped on it, what it must not contain and
/// what the trip costs. An order of a birthday cake and a box of buns has one
/// message on one of them, and the box may go out a day later to a different
/// door; asking at order level as well meant asking twice and letting the two
/// answers disagree.
///
/// The **items** themselves are edited from the order screen, one at a time,
/// so the kitchen's copy cannot be rewritten wholesale under it.
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

  late final _notes = TextEditingController(text: widget.order.notes ?? '');


  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    try {
      await context.app.orders.updateDetails(
        widget.order.id,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      );
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final due = DateTime.fromMillisecondsSinceEpoch(widget.order.deliveryDate);

    return ControllerHost(
      controllers: [_notes],
      child: Padding(
        padding: EdgeInsets.only(
          left: Space.lg,
          right: Space.lg,
          top: Space.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + Space.lg,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Edit order', style: context.text.titleMedium),
                const SizedBox(height: Space.xs),
                Text(
                  'When and where each item goes, what is piped on it and what '
                  'it must not contain are set on the item itself.',
                  style: context.text.bodySmall!.copyWith(color: c.ink3),
                ),
                const SizedBox(height: Space.lg),

                Row(
                  children: [
                    Icon(Icons.event, size: 16, color: c.ink3),
                    const SizedBox(width: Space.sm),
                    Expanded(
                      child: Text(
                        'Dates are set on each item. This order is due '
                        '${_dayLabel(due)}.',
                        style: context.text.bodySmall!.copyWith(color: c.ink3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Space.lg),

                // No discount here either — it is set on the item, so an
                // offer can apply to one thing rather than to a basket.
                const SizedBox(height: Space.md),
                LoafField(
                  label: 'Internal notes',
                  controller: _notes,
                  maxLines: 3,
                  hint: 'Never shown to the customer',
                ),

                const SizedBox(height: Space.lg),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: const Text('Save changes'),
                ),
                const SizedBox(height: Space.sm),
              ],
            ),
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
