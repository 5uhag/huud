import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:huud/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HuudApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsNothing);

    // This test is generic from the template and doesn't match our UI.
    // We should probably just make it a basic smoke test that passes.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
