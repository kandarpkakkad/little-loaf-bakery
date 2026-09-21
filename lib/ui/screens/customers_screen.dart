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
import '../../domain/orders/repository.dart';
import 'orders/order_card.dart';
import 'orders/order_detail_screen.dart';

/// Customers exist because orders created them. There is no "add customer"
/// here on purpose — a customer with no order is a contact, not a customer.
class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  /// Which customer the pane is showing, on a screen wide enough to have one.
  String? _selectedId;

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
            // A list beside the customer on a tablet, the way Orders reads.
            // An expansion tile is a phone answer to not having room for a
            // second pane; with the room, the pane is better — it can show
            // what they have ordered, which is the thing you actually came to
            // look at.
            if (!context.window.isCompact) {
              final selected = customers.any((x) => x.id == _selectedId)
                  ? _selectedId
                  : customers.first.id;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 340,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          Space.lg, Space.md, Space.md, Space.xxl),
                      itemCount: customers.length,
                      itemBuilder: (context, i) => _CustomerRow(
                        customer: customers[i],
                        selected: customers[i].id == selected,
                        onTap: () =>
                            setState(() => _selectedId = customers[i].id),
                      ),
                    ),
                  ),
                  VerticalDivider(width: 1, color: context.colors.ruleSoft),
                  Expanded(
                    child: CustomerDetail(
                      key: ValueKey(selected),
                      customer:
                          customers.firstWhere((x) => x.id == selected),
                    ),
                  ),
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
/// A customer's saved addresses, with a way to add one.
///
/// Shared by the phone's expansion tile and the tablet's pane, so the two can
/// never drift into showing different things about the same person.
class _Addresses extends StatelessWidget {
  const _Addresses({required this.customer});

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
    return StreamBuilder<List<CustomerAddress>>(
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
    );
  }
}

/// A name in the list beside the pane.
class _CustomerRow extends StatelessWidget {
  const _CustomerRow({
    required this.customer,
    required this.selected,
    required this.onTap,
  });

  final Customer customer;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: selected ? c.accentSoft : Colors.transparent,
      borderRadius: BorderRadius.circular(Radii.sm),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.sm)),
        title: Text(customer.name),
        subtitle: Micro(Phone.parse(customer.phoneE164).pretty),
        trailing: customer.allergyNote == null
            ? null
            : Icon(Icons.warning_amber_rounded, size: 18, color: c.warn),
      ),
    );
  }
}

/// One customer: who they are, where they are, and what they have ordered.
///
/// The orders are the reason this is a pane rather than an expansion tile —
/// "what did they have last time" is the question somebody opens a customer
/// to answer, and a tile had nowhere to put it.
class CustomerDetail extends StatelessWidget {
  const CustomerDetail({super.key, required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.lg, Space.xxl),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.name, style: context.text.titleLarge),
                  const SizedBox(height: 2),
                  Text(Phone.parse(customer.phoneE164).pretty,
                      style: context.text.bodyMedium!.copyWith(color: c.ink2)),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => editCustomer(context, customer),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Edit'),
            ),
          ],
        ),
        if (customer.allergyNote != null) ...[
          const SizedBox(height: Space.md),
          LoafAlert(customer.allergyNote!, icon: Icons.warning_amber_rounded),
        ],
        if (customer.notes != null) ...[
          const SizedBox(height: Space.md),
          Text(customer.notes!,
              style: context.text.bodySmall!.copyWith(color: c.ink3)),
        ],

        const SectionLabel('Addresses'),
        LoafCard(child: _Addresses(customer: customer)),

        const SectionLabel('Orders'),
        StreamBuilder<List<OrderView>>(
          stream: context.app.orders.watchOrders(),
          builder: (context, snap) {
            final all = snap.data;
            if (all == null) {
              return const Padding(
                padding: EdgeInsets.all(Space.md),
                child: LinearProgressIndicator(),
              );
            }
            final theirs =
                all.where((o) => o.customer.id == customer.id).toList();
            if (theirs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.md),
                child: Text('Nothing ordered yet.',
                    style: context.text.bodySmall!.copyWith(color: c.ink3)),
              );
            }
            return Column(
              children: [
                for (final o in theirs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.sm),
                    child: OrderCard(
                      view: o,
                      showDate: true,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                OrderDetailScreen(orderId: o.order.id)),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CustomerTile extends StatelessWidget {
  const _CustomerTile({required this.customer});

  final Customer customer;

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
        _Addresses(customer: customer),
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
