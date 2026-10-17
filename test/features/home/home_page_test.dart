import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:librava/features/auth/presentation/providers/auth_provider.dart';
import 'package:librava/features/books/presentation/providers/book_provider.dart';
import 'package:librava/features/events/presentation/providers/event_provider.dart';
import 'package:librava/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:librava/features/home/presentation/screens/home_page.dart';

Widget createTestWidget({TransactionProvider? customTrxProvider}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => BookProvider()),
      ChangeNotifierProvider(
        create: (_) =>
            customTrxProvider ?? TransactionProvider(isiDataAwal: false),
      ),
      ChangeNotifierProvider(create: (_) => EventProvider()),
    ],
    child: const MaterialApp(
      home: HomePage(),
    ),
  );
}

void main() {
  testWidgets('HomePage dapat dimuat dan dirender dengan baik',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Event'), findsOneWidget);
    expect(find.text('Featured books'), findsOneWidget);
    expect(find.text('Belum Ada Buku Dipinjam'), findsOneWidget);
    expect(find.text('Book Exchange Day'), findsOneWidget);
  });

  testWidgets('Carousel event di HomePage dapat bergeser ke slide berikutnya',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('Book Exchange Day'), findsOneWidget);

    final nextButton = find.byIcon(Icons.chevron_right_rounded).last;
    expect(nextButton, findsOneWidget);

    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    expect(find.text('Reading Meetup'), findsOneWidget);
  });

  testWidgets(
      'Carousel buku pinjaman di HomePage dapat bergeser ke transaksi berikutnya',
      (WidgetTester tester) async {
    final trxProvider = TransactionProvider(isiDataAwal: false);
    trxProvider.ajukanPinjam(
      bukuId: 'bk_001',
      judulBuku: 'Clean Code',
      pemohonNama: 'Budi Santoso',
      pemilikNama: 'Gilang Ramadan',
    );
    trxProvider.ajukanPinjam(
      bukuId: 'bk_002',
      judulBuku: 'Refactoring',
      pemohonNama: 'Gilang Ramadan',
      pemilikNama: 'Sarah',
    );

    await tester.pumpWidget(createTestWidget(customTrxProvider: trxProvider));

    expect(find.text('Refactoring'), findsWidgets);

    final borrowNextButton = find.byIcon(Icons.chevron_right_rounded).first;
    await tester.tap(borrowNextButton);
    await tester.pumpAndSettle();

    expect(find.text('Clean Code'), findsWidgets);
  });

  testWidgets(
      'Menekan tombol View transaction di HomePage membuka TransactionDetailPage',
      (WidgetTester tester) async {
    final trxProvider = TransactionProvider(isiDataAwal: false);
    trxProvider.ajukanPinjam(
      bukuId: 'bk_001',
      judulBuku: 'Clean Code',
      pemohonNama: 'Budi Santoso',
      pemilikNama: 'Gilang Ramadan',
    );

    await tester.pumpWidget(createTestWidget(customTrxProvider: trxProvider));

    await tester.ensureVisible(find.text('View transaction'));
    await tester.tap(find.text('View transaction'));
    await tester.pumpAndSettle();

    expect(find.text('Transaction Info'), findsOneWidget);
    expect(find.text('Clean Code'), findsWidgets);
  });
}
