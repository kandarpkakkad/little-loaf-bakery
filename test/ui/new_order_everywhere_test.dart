import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/ui/shell/shell.dart';

import '../support/harness.dart';

/// Taking an order is the most common thing anyone does here, so it is never
/// more than one tap away — including from the Kitchen, where you are standing
/// when the phone rings.
void main() {
  testWidgets('New order is on every tab', (tester) async {
    final services = await testServices(tester: tester);
    await services.menu.create(name: 'Cake');

    await tester.pumpWidget(wrapped(services, const AppShell()));
    await tester.pumpAndSettle();

    for (final tab in ['Today', 'Orders', 'Kitchen', 'Stock', 'More']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      expect(find.text('New order'), findsOneWidget,
          reason: 'missing on $tab');
    }
    expect(tester.takeException(), isNull);
    await drain(tester);
  });

  testWidgets('it opens the form from the Kitchen', (tester) async {
    final services = await testServices(tester: tester);
    await services.menu.create(name: 'Cake');

    await tester.pumpWidget(wrapped(services, const AppShell()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kitchen').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('New order'));
    await tester.pumpAndSettle();

    expect(find.text('Save order'), findsOneWidget,
        reason: 'the order form, reached without leaving the kitchen first');
    expect(tester.takeException(), isNull);
    await drain(tester);
  });
}
