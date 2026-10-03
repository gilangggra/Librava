import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/admin/domain/models/admin_transaction_model.dart';
import 'package:librava/features/admin/presentation/providers/admin_provider.dart';
import 'package:librava/features/admin/presentation/screens/admin_request_detail_page.dart';
import 'package:librava/features/admin/presentation/screens/admin_requests_page.dart';
import 'package:librava/features/admin/presentation/screens/admin_transaction_detail_page.dart';
import 'package:librava/features/admin/presentation/screens/admin_transactions_page.dart';
import 'package:librava/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() {
  final sampleTransaction = AdminTransactionModel(
    id: 'TRX-101',
    tipeTransaksi: 'PINJAM',
    status: 'SELESAI',
    depositDummy: 50000,
    lokasiPertemuan: 'Gedung Tokong Nanas Lt. 2',
    waktuPertemuan: '2026-10-05 14:00',
    createdAt: '2026-10-01T10:00:00.000Z',
    updatedAt: '2026-10-02T10:00:00.000Z',
    requesterNama: 'Andi Baker',
    requesterEmail: 'andi@librava.com',
    ownerNama: 'Sari Dewi',
    ownerEmail: 'sari@librava.com',
    bookJudul: 'The Pragmatic Programmer',
  );

  final sampleRequest = AdminTransactionModel(
    id: 'REQ-202',
    tipeTransaksi: 'BARTER',
    status: 'MENUNGGU_PERSETUJUAN',
    depositDummy: 0,
    createdAt: '2026-10-03T08:30:00.000Z',
    updatedAt: '2026-10-03T08:30:00.000Z',
    requesterNama: 'Budi Santoso',
    requesterEmail: 'budi@librava.com',
    ownerNama: 'Citra Kirana',
    ownerEmail: 'citra@librava.com',
    bookJudul: 'Clean Architecture',
  );

  Widget buatHalamanUji(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  testWidgets('AdminTransactionDetailPage menampilkan detail transaksi dengan lengkap', (tester) async {
    await tester.pumpWidget(buatHalamanUji(AdminTransactionDetailPage(transaksi: sampleTransaction)));
    await tester.pumpAndSettle();

    expect(find.text('Transaction view'), findsOneWidget);
    expect(find.text('The Pragmatic Programmer'), findsOneWidget);
    expect(find.text('TRX-101'), findsOneWidget);
    expect(find.text('Andi Baker'), findsNWidgets(2));
    expect(find.text('Sari Dewi'), findsOneWidget);
  });

  testWidgets('AdminRequestDetailPage menampilkan detail request dengan lengkap', (tester) async {
    await tester.pumpWidget(buatHalamanUji(AdminRequestDetailPage(request: sampleRequest)));
    await tester.pumpAndSettle();

    expect(find.text('Request view'), findsOneWidget);
    expect(find.text('Clean Architecture'), findsOneWidget);
    expect(find.text('REQ-202'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsNWidgets(2));
    expect(find.text('Citra Kirana'), findsOneWidget);
  });

  testWidgets('AdminTransactionsPage dapat dimuat dan merender elemen utama', (tester) async {
    await tester.pumpWidget(buatHalamanUji(const AdminTransactionsPage()));
    await tester.pump();

    expect(find.text('Transaction data'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('AdminRequestsPage dapat dimuat dan merender elemen utama', (tester) async {
    await tester.pumpWidget(buatHalamanUji(const AdminRequestsPage()));
    await tester.pump();

    expect(find.text('Request data'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
