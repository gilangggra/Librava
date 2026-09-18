import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/books/presentation/screens/search_page.dart';

void main() {
  testWidgets('SearchPage dapat dimuat dan dirender dengan baik',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SearchPage(),
      ),
    );

    expect(find.text('Search'), findsNWidgets(2));
    expect(find.text('Trending'), findsOneWidget);
    expect(find.text('Recently added'), findsOneWidget);
    expect(find.text('Recommended'), findsOneWidget);
  });
}
