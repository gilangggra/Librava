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
    expect(find.text('Virtual Account'), findsOneWidget);
    expect(find.text('BCA'), findsWidgets);
    expect(find.text('8801 2345 6789 0123'), findsOneWidget);
    expect(find.text('Salin'), findsOneWidget);

    // Ganti bank ke Mandiri lewat PopupMenu
    await tester.ensureVisible(find.text('BCA').first);
    await tester.tap(find.text('BCA').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mandiri Virtual Account'));
    await tester.pumpAndSettle();

    expect(find.text('8902 4567 8901 2345'), findsOneWidget);

    // Tekan tombol Salin
    await tester.ensureVisible(find.text('Salin'));
    await tester.tap(find.text('Salin'));
    await tester.pump();
    expect(find.text('Nomor VA Mandiri disalin!'), findsOneWidget);

    await tester.ensureVisible(find.text("I've made the payment"));
    await tester.tap(find.text("I've made the payment"));
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
  });
}
