import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/books/domain/models/book_model.dart';
import 'package:librava/features/books/presentation/screens/book_detail_page.dart';
import 'package:librava/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

void main() {
  Widget buildTestableWidget({BookModel? book, String? coverPath}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        home: BookDetailPage(
          book: book,
          coverPath: coverPath,
        ),
      ),
    );
  }

  testWidgets('BookDetailPage dapat dimuat dengan default The Unknown',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());

    expect(find.text('The Unknown'), findsOneWidget);
    expect(find.text('Author'), findsOneWidget);
    expect(find.text('Riley Sager'), findsOneWidget);
    expect(find.text('Genre'), findsOneWidget);
    expect(find.text('Horror/Thriller'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Rating'), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
    expect(find.text('About this book'), findsOneWidget);
    expect(find.text('Borrow'), findsOneWidget);
    expect(find.text('Barter'), findsOneWidget);
  });

  testWidgets('Menekan bookmark mengaktifkan status bookmark',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());

    expect(find.byIcon(CupertinoIcons.bookmark), findsOneWidget);

    await tester.tap(find.byIcon(CupertinoIcons.bookmark));
    await tester.pumpAndSettle();

    expect(find.byIcon(CupertinoIcons.bookmark_fill), findsOneWidget);
    expect(find.text('Buku disimpan ke bookmark'), findsOneWidget);
  });

  testWidgets('Menekan tombol Borrow membuka modal pengajuan pinjam',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());

    final borrowButtonFinder = find.text('Borrow');
    await tester.ensureVisible(borrowButtonFinder);
    await tester.pumpAndSettle();

    await tester.tap(borrowButtonFinder);
    await tester.pumpAndSettle();

    expect(find.text('Ajukan Peminjaman'), findsOneWidget);
    expect(find.text('Buku: The Unknown'), findsOneWidget);
    expect(find.text('Durasi Pinjam'), findsOneWidget);
    expect(find.text('3 Hari'), findsOneWidget);
    expect(find.text('7 Hari'), findsOneWidget);
    expect(find.text('14 Hari'), findsOneWidget);
    expect(find.text('Konfirmasi Pengajuan Pinjam'), findsOneWidget);
  });

  testWidgets('Menekan tombol Barter membuka modal barter dengan pilihan koleksi',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());

    final barterButtonFinder = find.text('Barter');
    await tester.ensureVisible(barterButtonFinder);
    await tester.pumpAndSettle();

    await tester.tap(barterButtonFinder);
    await tester.pumpAndSettle();

    expect(find.text('Ajukan Barter Buku'), findsOneWidget);
    expect(find.text('Ingin ditukar dengan: The Unknown'), findsOneWidget);
    expect(find.text('Pilih Buku dari Koleksimu'), findsOneWidget);
    expect(find.text('Clean Code'), findsOneWidget);
    expect(find.text('Konfirmasi Pengajuan Barter'), findsOneWidget);
  });

  testWidgets('BookDetailPage dapat menampilkan data buku kustom',
      (WidgetTester tester) async {
    const customBook = BookModel(
      id: 'bk_custom',
      judul: 'Algoritma Pemrograman',
      penulis: 'Andi (dummy)',
      kategori: 'Teknologi',
      tahunTerbit: 2024,
      tersedia: true,
      rating: 4.9,
      deskripsi: 'Panduan lengkap algoritma dan struktur data.',
    );

    await tester.pumpWidget(buildTestableWidget(book: customBook));

    expect(find.text('Algoritma Pemrograman'), findsOneWidget);
    expect(find.text('Andi (dummy)'), findsOneWidget);
    expect(find.text('Teknologi'), findsOneWidget);
    expect(find.text('4.9'), findsOneWidget);
    expect(find.text('Panduan lengkap algoritma dan struktur data.'), findsOneWidget);
  });
}
