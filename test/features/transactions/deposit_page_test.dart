import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/transactions/presentation/screens/deposit_page.dart';

void main() {
  testWidgets('DepositPage menampilkan semua elemen QR deposit dengan benar',
      (WidgetTester tester) async {
    bool confirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: DepositPage(
          onPaymentSuccess: () {
            confirmed = true;
          },
        ),
      ),
    );

    expect(find.text('Complete your deposit'), findsOneWidget);
    expect(
      find.text('Scan this QR code below to complete your deposit for this transaction'),
      findsOneWidget,
    );
    expect(find.text('Deposit amount'), findsOneWidget);
    expect(find.text('RP 50.000'), findsOneWidget);
    expect(
      find.text('The deposit will be held securely and will be refunded after the book is returned'),
      findsOneWidget,
    );
    expect(find.text("I've made the payment"), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    await tester.ensureVisible(find.text("I've made the payment"));
    await tester.tap(find.text("I've made the payment"));
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
  });
}
