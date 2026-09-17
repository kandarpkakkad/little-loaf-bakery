import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/ui/screens/orders/new_order_screen.dart';
import 'package:little_loaf/ui/theme/theme.dart';

import '../support/harness.dart';

void main() {
  testWidgets('the save bar lays out across the full width', (tester) async {
    final services = await testServices(tester: tester);
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrapped(services, const NewOrderScreen()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Save order'), findsOneWidget);
    expect(find.text('TOTAL'), findsOneWidget);

    // The bar reads left to right: the running total, then the action. If the
    // row ever collapses again, the button lands on top of the total instead
    // of well to the right of it.
    final total = tester.getTopLeft(find.text('TOTAL'));
    final button = tester.getTopLeft(find.text('Save order'));
    expect(button.dx - total.dx, greaterThan(150),
        reason: 'save button at ${button.dx}, total at ${total.dx}');
  });

  testWidgets('a themed button inside a Row does not force infinite width',
      (tester) async {
    // The regression this guards: a button minimum size of
    // Size.fromHeight(48) sets width to infinity, which is a tight infinite
    // width for a non-flex child of a Row.
    await tester.pumpWidget(MaterialApp(
      theme: loafTheme(Brightness.light),
      home: Scaffold(
        body: Row(
          children: [
            const Expanded(child: Text('Total')),
            FilledButton(onPressed: () {}, child: const Text('Save')),
            OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
          ],
        ),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });
}
