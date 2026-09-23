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

  testWidgets('Carousel event di HomePage dapat bergeser ke slide berikutnya',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomePage(),
      ),
    );

    expect(find.text('Book Exchange Day'), findsOneWidget);

    final nextButton = find.byIcon(Icons.chevron_right_rounded).last;
    expect(nextButton, findsOneWidget);

    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    expect(find.text('Reading Meetup'), findsOneWidget);
  });

  testWidgets('Carousel buku pinjaman di HomePage dapat bergeser ke Fruit Fly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomePage(),
      ),
    );

    expect(find.text('The Unknown'), findsWidgets);
    expect(find.text('Borrowing from Andi'), findsOneWidget);

    final borrowNextButton = find.byIcon(Icons.chevron_right_rounded).first;
    await tester.tap(borrowNextButton);
    await tester.pumpAndSettle();

    expect(find.text('Fruit Fly'), findsWidgets);
    expect(find.text('Borrowed from Sarah'), findsOneWidget);
    expect(find.text('Due in 3 days'), findsOneWidget);
  });
}
