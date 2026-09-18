import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/home/presentation/screens/home_page.dart';

void main() {
  testWidgets('HomePage dapat dimuat dan dirender dengan baik',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomePage(),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Event'), findsOneWidget);
    expect(find.text('Featured books'), findsOneWidget);
    expect(find.text('The Unknown'), findsWidgets);
    expect(find.text('View transaction'), findsOneWidget);
    expect(find.text('Book Exchange Day'), findsOneWidget);
  });
}
