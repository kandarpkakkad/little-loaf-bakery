import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/ui/screens/orders/new_order_screen.dart';

import '../support/harness.dart';

void main() {
  testWidgets('what constraints does NewOrderScreen get', (tester) async {
    final services = await testServices(tester: tester);
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrapped(
      services,
      LayoutBuilder(builder: (context, c) {
        debugPrint('PROBE constraints: $c');
        debugPrint('PROBE mq: ${MediaQuery.sizeOf(context)}');
        return const NewOrderScreen();
      }),
    ));
    await tester.pump();
  });
}
