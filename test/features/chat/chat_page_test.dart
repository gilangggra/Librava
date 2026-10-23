import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/auth/presentation/providers/auth_provider.dart';
import 'package:librava/features/chat/presentation/providers/chat_provider.dart';
import 'package:librava/features/chat/presentation/screens/chat_page.dart';
import 'package:librava/features/transactions/domain/models/transaction_model.dart';
import 'package:librava/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

void main() {
  Widget buildTestableChatPage({
    TransactionProvider? transactionProvider,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        transactionProvider != null
            ? ChangeNotifierProvider.value(value: transactionProvider)
            : ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: const MaterialApp(
        home: ChatPage(),
      ),
    );
  }

  testWidgets('ChatPage dapat dimuat dan menampilkan empty state jika belum ada transaksi',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableChatPage());

    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('Search message'), findsOneWidget);
    expect(find.text('No Chats Yet'), findsOneWidget);
  });

  testWidgets('ChatPage menampilkan daftar transaksi percakapan dan memfilter pencarian',
      (WidgetTester tester) async {
    final tp = TransactionProvider();
    tp.tambahTransaksi(
      const TransactionModel(
        id: 'tx_1',
        bukuId: 'bk_1',
        judulBuku: 'Clean Code',
        pemilikNama: 'Budi Santoso',
        pemohonNama: 'Sari Indah',
        jenisTransaksi: 'pinjam',
        status: 'dalam_proses',
        tanggal: '17/10/2026',
      ),
    );

    await tester.pumpWidget(buildTestableChatPage(transactionProvider: tp));
    await tester.pumpAndSettle();

    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.textContaining('Clean Code'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Tidak ada');
    await tester.pump();

    expect(find.text('Budi Santoso'), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    expect(find.text('Budi Santoso'), findsOneWidget);
  });

  testWidgets('Mengetuk salah satu chat membuka ruang percakapan ChatRoomPage',
      (WidgetTester tester) async {
    final tp = TransactionProvider();
    tp.tambahTransaksi(
      const TransactionModel(
        id: 'tx_1',
        bukuId: 'bk_1',
        judulBuku: 'Clean Code',
        pemilikNama: 'Budi Santoso',
        pemohonNama: 'Sari Indah',
        jenisTransaksi: 'pinjam',
        status: 'dalam_proses',
        tanggal: '17/10/2026',
      ),
    );

    await tester.pumpWidget(buildTestableChatPage(transactionProvider: tp));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Budi Santoso'));
    await tester.pumpAndSettle();

    expect(find.text('Budi Santoso'), findsWidgets);
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Type a message...'), findsOneWidget);
    expect(find.text('Start Conversation'), findsOneWidget);
  });

  testWidgets('Mengetuk ikon kamera di ChatRoomPage membuka modal foto kondisi buku dan bisa mengirim foto',
      (WidgetTester tester) async {
    final tp = TransactionProvider();
    tp.tambahTransaksi(
      const TransactionModel(
        id: 'tx_1',
        bukuId: 'bk_1',
        judulBuku: 'Clean Code',
        pemilikNama: 'Budi Santoso',
        pemohonNama: 'Sari Indah',
        jenisTransaksi: 'pinjam',
        status: 'dalam_proses',
        tanggal: '17/10/2026',
      ),
    );

    await tester.pumpWidget(buildTestableChatPage(transactionProvider: tp));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Budi Santoso'));
    await tester.pumpAndSettle();

    // Temukan tombol kamera di input bar
    final cameraBtn = find.byTooltip('Send Book Condition Photo');
    expect(cameraBtn, findsOneWidget);

    await tester.tap(cameraBtn);
    await tester.pumpAndSettle();

    // Verifikasi modal terbuka dengan opsi kamera dan galeri
    expect(find.text('Kirim Foto Kondisi Buku'), findsOneWidget);
    expect(find.text('Ambil Foto'), findsOneWidget);
    expect(find.text('Pilih dari Galeri'), findsOneWidget);
    expect(find.text('Atau pilih dari contoh foto fisik:'), findsOneWidget);
    expect(find.text('Kirim Foto'), findsOneWidget);

    // Ketuk tombol Kirim Foto
    await tester.tap(find.text('Kirim Foto'));
    await tester.pumpAndSettle();

    // Modal tertutup dan pesan foto muncul di percakapan
    expect(find.text('Kirim Foto Kondisi Buku'), findsNothing);
    expect(find.text('Foto kondisi buku'), findsOneWidget);
  });
}
