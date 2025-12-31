import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shrine/app.dart'; // Change this line

void main() {
  testWidgets('Shrine app starts at login page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ShrineApp());

    // Verify that the login page is displayed
    expect(find.text('SHRINE'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('CANCEL'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
  });
}