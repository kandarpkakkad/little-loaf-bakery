import 'package:flutter/material.dart';

import '../../app/scope.dart';
import '../../platform/storage/database.dart';
import '../theme/breakpoints.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../../common/phone.dart';
import '../widgets/forms.dart';
import '../widgets/primitives.dart';
import 'orders/address_picker.dart';

/// Customers exist because orders created them. There is no "add customer"
/// here on purpose — a customer with no order is a contact, not a customer.
class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colors.paper,
        appBar: AppBar(title: const Text('Customers')),
        // Wide enough for two columns of customers on a tablet; still a
        // comfortable measure on a phone, where CardGrid is a plain list.
        body: ContentWidth(
          max: context.window.isCompact ? 720 : 1100,
          child: StreamBuilder<List<Customer>>(
          stream: context.app.customers.watchAll(),
          builder: (context, snap) {
            final customers = snap.data;
            if (customers == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (customers.isEmpty) {
              return const EmptyState(
                icon: Icons.people_outline,
                message: 'No customers yet.\nThey are added by taking an order.',
              );
            }
            // One long divided card on a phone, a card each in columns on a
            // tablet. A divider is how you separate rows in a single column;
            // across two columns it stops meaning anything, so the card
            // boundary does the work instead.
            if (!context.window.isCompact) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                    Space.lg, Space.md, Space.lg, Space.xxl),
                children: [
                  CardGrid(children: [
                    for (final c in customers)
                      LoafCard(
                        padding: EdgeInsets.zero,
                        child: _CustomerTile(customer: c),
                      ),
                  ]),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                  Space.lg, Space.md, Space.lg, Space.xxl),
              children: [
                LoafCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < customers.length; i++) ...[
                        if (i > 0)
                          Divider(height: 1, color: context.colors.ruleSoft),
                        _CustomerTile(customer: customers[i]),
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

/// Name and number on the face of it; addresses when it is opened. A customer
/// keeps as many as they order to, so the list is the point rather than a
/// single line squeezed into the subtitle.
class _CustomerTile extends StatelessWidget {
  const _CustomerTile({required this.customer});

  final Customer customer;

  Future<void> _add(BuildContext context) async {
    final repo = context.app.customers;
    final made = await editAddress(context);
    if (made == null) return;
    await repo.addAddress(
      customerId: customer.id,
      label: made.label,
      addressText: made.addressText,
      pinLat: made.pinLat,
      pinLng: made.pinLng,
      pinUrl: made.pinUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ExpansionTile(
      shape: const Border(),
      collapsedShape: const Border(),
      title: Text(customer.name),
      subtitle: Micro(Phone.parse(customer.phoneE164).pretty),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (customer.allergyNote != null)
            Icon(Icons.warning_amber_rounded, size: 18, color: c.warn),
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 18, color: c.ink3),
            tooltip: 'Edit customer',
            onPressed: () => editCustomer(context, customer),
          ),
        ],
      ),
      childrenPadding:
          const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.md),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<List<CustomerAddress>>(
          stream: context.app.customers.watchAddresses(customer.id),
          builder: (context, snap) {
            final addresses = snap.data;
            if (addresses == null) {
              return const Padding(
                padding: EdgeInsets.all(Space.md),
                child: LinearProgressIndicator(),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (addresses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.sm),
                    child: Text('No address saved yet.',
                        style:
                            context.text.bodySmall!.copyWith(color: c.ink3)),
                  )
                else
                  for (final a in addresses)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Space.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(a.pinLat != null ? Icons.place : Icons.place_outlined,
                              size: 16,
                              color: a.pinLat != null ? c.accent2 : c.ink3),
                          const SizedBox(width: Space.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.label, style: context.text.bodyMedium),
                                Text(a.addressText,
                                    style: context.text.bodySmall!
                                        .copyWith(color: c.ink2)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, size: 16, color: c.ink3),
                            tooltip: 'Remove address',
                            onPressed: () =>
                                context.app.customers.removeAddress(a.id),
                          ),
                        ],
                      ),
                    ),
                TextButton.icon(
                  onPressed: () => _add(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add address'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Change a customer's details — most often the number, when they move.
///
/// The number is the identity: one number, one customer, enforced by a unique
/// index. So a number already on someone else's record is refused here with an
/// explanation, rather than being allowed through to fail as a constraint
/// violation the user cannot interpret.
Future<void> editCustomer(BuildContext context, Customer customer) async {
  final repo = context.app.customers;
  final name = TextEditingController(text: customer.name);
  final phone =
      TextEditingController(text: Phone.parse(customer.phoneE164).national);
  final allergy = TextEditingController(text: customer.allergyNote ?? '');
  final notes = TextEditingController(text: customer.notes ?? '');
  final formKey = GlobalKey<FormState>();

  final saved = await loafSheet<bool>(
    context,
    builder: (sheetContext) => ControllerHost(
      controllers: [name, phone, allergy, notes],
      child: Padding(
      padding: EdgeInsets.only(
        left: Space.lg,
        right: Space.lg,
        top: Space.lg,
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom + Space.lg,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Edit customer', style: sheetContext.text.titleMedium),
              const SizedBox(height: Space.lg),
              LoafField(label: 'Name', controller: name, required: true),
              LoafPhoneField(
                controller: phone,
                helper: 'Changing this moves their whole order history',
              ),
              LoafField(
                  label: 'Allergy note',
                  controller: allergy,
                  hint: 'Carried onto every order they place'),
              LoafField(
                  label: 'Notes',
                  controller: notes,
                  hint: 'Never shown to the customer',
                  maxLines: 3),
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
    final entered = Phone(Phone.digitsOf(phone.text));
    final newPhone = entered.e164;
    // Only when it actually changed: byPhone would otherwise find this very
    // customer and refuse an edit that changes nothing about the number.
    if (newPhone != customer.phoneE164) {
      final clash = await repo.byPhone(newPhone);
      if (clash != null && clash.id != customer.id) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${clash.name} already uses $newPhone'),
          ));
        }
        return;
      }
    }
    await repo.update(
      customer.id,
      name: name.text.trim(),
      phoneE164: newPhone,
      countryCode: kDefaultCountry.code,
      allergyNote: allergy.text.trim().isEmpty ? '' : allergy.text.trim(),
      notes: notes.text.trim().isEmpty ? '' : notes.text.trim(),
    );
  }
}
