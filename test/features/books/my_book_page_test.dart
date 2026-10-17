import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/auth/presentation/providers/auth_provider.dart';
import 'package:librava/features/books/domain/models/book_model.dart';
import 'package:librava/features/books/presentation/providers/book_provider.dart';
import 'package:librava/features/books/presentation/screens/my_book_page.dart';
import 'package:provider/provider.dart';

void main() {
  Widget createTestWidget({BookProvider? provider}) {
    final bp = provider ?? BookProvider();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider.value(value: bp),
      ],
      child: const MaterialApp(
        home: MyBookPage(),
      ),
    );
  }

  testWidgets('MyBookPage dapat dimuat dan dirender dengan baik',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('My book'), findsOneWidget);
    expect(find.text('Check your book collection'), findsOneWidget);
    expect(find.text('My Collection'), findsOneWidget);
    expect(find.text('Borrowed'), findsOneWidget);
    expect(find.text('Lent out'), findsOneWidget);
  });

  testWidgets('Menekan tombol tambah buku membuka halaman AddBookPage',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.byIcon(CupertinoIcons.plus_circle));
    await tester.pumpAndSettle();

    expect(find.text('Book cover'), findsOneWidget);
    expect(find.text('Book title'), findsOneWidget);
    expect(find.text('Author'), findsOneWidget);
    expect(find.text('Ganre'), findsOneWidget);
    await tester.ensureVisible(find.text('Publish book'));
    expect(find.text('Publish book'), findsOneWidget);
  });

  testWidgets(
      'Menekan tombol delete_left membuka modal Pilih Buku untuk Dihapus',
      (WidgetTester tester) async {
    final bp = BookProvider();
    bp.tambahBuku(
      const BookModel(
        id: 'bk_my_01',
        judul: 'Clean Code',
        penulis: 'Robert C. Martin',
        kategori: 'Teknologi',
        tahunTerbit: 2008,
      ),
    );
    await tester.pumpWidget(createTestWidget(provider: bp));

    expect(find.byIcon(CupertinoIcons.delete_left), findsOneWidget);
    await tester.tap(find.byIcon(CupertinoIcons.delete_left));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Buku untuk Dihapus'), findsOneWidget);
  });

  test('BookProvider hapusBuku menghapus buku dari daftar', () {
    final provider = BookProvider();
    provider.tambahBuku(
      const BookModel(
        id: 'bk_clean',
        judul: 'Clean Code',
        penulis: 'Robert C. Martin',
        kategori: 'Teknologi',
        tahunTerbit: 2008,
      ),
    );
    expect(provider.allBooks.any((b) => b.id == 'bk_clean'), isTrue);
    provider.hapusBuku('bk_clean');
    expect(provider.allBooks.any((b) => b.id == 'bk_clean'), isFalse);
    expect(provider.koleksiSaya.any((b) => b.id == 'bk_clean'), isFalse);
  });
}
