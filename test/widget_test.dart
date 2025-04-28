import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:medeasee/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build the app without isLoggedIn (handled by SplashScreen)
    await tester.pumpWidget(const MedeaseApp());

    // Verify that the counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that the counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
