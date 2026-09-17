import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/ui/screens/config/materials_config_screen.dart';
import 'package:little_loaf/ui/screens/config/menu_config_screen.dart';

import '../support/harness.dart';

/// Adding through a bottom sheet used to crash on save with
/// "_dependents.isEmpty: is not true" — the controllers were disposed the
/// instant `await showModalBottomSheet` returned, while the sheet's fields were
/// still mounted and animating out.
void main() {
  testWidgets('a menu item can be added without crashing', (tester) async {
    final services = await testServices(tester: tester);
    await tester.pumpWidget(wrapped(services, const MenuConfigScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Cake');
    await tester.tap(find.text('Save'));

    // Deliberately NOT pumpAndSettle: on a device the controllers are torn
    // down one frame after the pop, while the sheet is still animating out.
    // Settling first hides exactly the window where this used to crash.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));
    expect(tester.takeException(), isNull, reason: 'crashed mid-animation');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(await services.menu.list(), hasLength(1));
    await drain(tester);
  });

  testWidgets('a material can be added without crashing', (tester) async {
    final services = await testServices(tester: tester);
    await tester.pumpWidget(wrapped(services, const MaterialsConfigScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Flour');
    await tester.tap(find.text('Save'));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));
    expect(tester.takeException(), isNull, reason: 'crashed mid-animation');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await drain(tester);
  });
}
