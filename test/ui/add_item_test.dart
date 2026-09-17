import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/ui/screens/orders/new_order_screen.dart';

import '../support/harness.dart';

void main() {
  testWidgets('Add item opens the line editor', (tester) async {
    final services = await testServices(tester: tester);
    await services.menu.create(name: 'Sourdough loaf');
    await services.menu.create(name: 'Brownie box');

    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrapped(services, const NewOrderScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add item'));
    // The handler loads the menu before it opens the sheet, so the first
    // settle only gets as far as that await completing.
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Add item').hitTestable(), findsWidgets);
    // the sheet's own fields
    expect(find.text('Base price *'), findsOneWidget,
        reason: 'the line editor did not open');
    expect(find.text('Price of one item'), findsOneWidget,
        reason: 'base price must say it is per unit');
    expect(find.text('Item *'), findsOneWidget);

    // The item comes from a dropdown only — a free-text item was how untypeable
    // one-off names got into reports.
    expect(find.byType(DropdownButtonFormField<String>), findsWidgets);
    await tester.tap(find.text('Item *'));
    await tester.pumpAndSettle();
    expect(find.text('Sourdough loaf'), findsWidgets);
    expect(find.text('Brownie box'), findsWidgets);
  });
}
