import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:librava/features/auth/presentation/providers/auth_provider.dart';
import 'package:librava/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:librava/features/transactions/presentation/screens/transaction_history_page.dart';

void main() {
  testWidgets('TransactionHistoryPage dapat dimuat dan memfilter transaksi',
      (WidgetTester tester) async {
    final trxProvider = TransactionProvider(isiDataAwal: false);
    final trx1 = trxProvider.ajukanPinjam(
      bukuId: 'b1',
      judulBuku: 'Atomic Habits',
      pemohonNama: 'Gilang Ramadan',
      pemilikNama: 'Andi',
    );
    trxProvider.selesaikanTransaksi(trx1.id);

    trxProvider.ajukanBarter(
      bukuId: 'b2',
      judulBuku: 'Clean Code',
      bukuBarter: 'Pragmatic Programmer',
      pemohonNama: 'Gilang Ramadan',
      pemilikNama: 'Budi',
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
          ChangeNotifierProvider<TransactionProvider>.value(value: trxProvider),
        ],
        child: const MaterialApp(
          home: TransactionHistoryPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Transaction History'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Borrow'), findsWidgets);
    expect(find.text('Barter'), findsWidgets);
    expect(find.text('Completed'), findsWidgets);

    // Keduanya tampil pada filter 'All'
    expect(find.text('Atomic Habits'), findsOneWidget);
    expect(find.text('Clean Code'), findsOneWidget);

    // Ganti filter ke 'Borrow'
    await tester.tap(find.text('Borrow').first);
    await tester.pumpAndSettle();

    expect(find.text('Atomic Habits'), findsOneWidget);
    expect(find.text('Clean Code'), findsNothing);

    // Ganti filter ke 'Barter'
    await tester.tap(find.text('Barter').first);
    await tester.pumpAndSettle();

    expect(find.text('Clean Code'), findsOneWidget);
    expect(find.text('Atomic Habits'), findsNothing);

    // Ganti filter ke 'Completed'
    await tester.tap(find.text('Completed').first);
    await tester.pumpAndSettle();

    expect(find.text('Atomic Habits'), findsOneWidget);
    expect(find.text('Clean Code'), findsNothing);
  });
}
