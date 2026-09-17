import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/ui/screens/customers_screen.dart';

import '../support/harness.dart';

/// Editing a customer, and the case that would otherwise hit the unique index
/// on phone_e164 and surface as an unreadable constraint violation.
///
/// The number is entered as national digits only; what the unique index
/// compares is those digits with the dialling code composed on.
void main() {
  Future<void> openEditor(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();
  }

  testWidgets('a number can be changed', (tester) async {
    final services = await testServices(tester: tester);
    final id = await services.customers
        .findOrCreate(name: 'Asha Rao', phoneE164: '+919876543210');

    await tester.pumpWidget(wrapped(services, const CustomersScreen()));
    await tester.pumpAndSettle();
    await openEditor(tester);

    // fields are: name, number, allergy, notes
    await tester.enterText(find.byType(TextFormField).at(1), '9000000001');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final row = await services.customers.byPhone('+919000000001');
    expect(row, isNotNull);
    expect(row!.id, id, reason: 'the same customer, not a new one');
    expect(row.name, 'Asha Rao');
    expect(tester.takeException(), isNull);
    await drain(tester);
  });

  testWidgets('taking a number already in use is refused', (tester) async {
    final services = await testServices(tester: tester);
    await services.customers
        .findOrCreate(name: 'Asha Rao', phoneE164: '+919876543210');
    await services.customers
        .findOrCreate(name: 'Bina Shah', phoneE164: '+919000000002');

    await tester.pumpWidget(wrapped(services, const CustomersScreen()));
    await tester.pumpAndSettle();
    await openEditor(tester);

    // Asha sorts first, so this is Asha taking Bina's number
    await tester.enterText(find.byType(TextFormField).at(1), '9000000002');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull, reason: 'refused, not crashed');
    expect(find.textContaining('already uses'), findsOneWidget);

    final asha = await services.customers.byPhone('+919876543210');
    expect(asha, isNotNull, reason: 'Asha keeps her original number');
    await drain(tester);
  });
}
