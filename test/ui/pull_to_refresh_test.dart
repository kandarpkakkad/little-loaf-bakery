import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_loaf/ui/screens/orders/orders_screen.dart';
import 'package:little_loaf/ui/screens/today_screen.dart';
import 'package:little_loaf/ui/widgets/sync_refresh.dart';

import '../support/harness.dart';

/// Pull-to-refresh is what fetches another device's orders on demand — the
/// drift streams underneath only see local writes.
void main() {
  testWidgets('Today can be pulled even with nothing on it', (tester) async {
    final services = await testServices(tester: tester);
    await tester.pumpWidget(wrapped(services, const TodayScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(find.byType(Scrollable), findsWidgets,
        reason: 'the gesture needs something scrollable, even when empty');
    expect(tester.takeException(), isNull);
    await drain(tester);
  });

  testWidgets('an empty Orders list is still pullable', (tester) async {
    final services = await testServices(tester: tester);
    await tester.pumpWidget(wrapped(services, const OrdersScreen()));
    await tester.pumpAndSettle();

    // "No open orders" is exactly when you pull, waiting for the other device
    expect(find.byType(Pullable), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
    await drain(tester);
  });
}
