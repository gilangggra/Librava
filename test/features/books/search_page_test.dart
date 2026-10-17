import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:librava/features/books/domain/models/book_model.dart';
import 'package:librava/features/books/presentation/providers/book_provider.dart';
import 'package:librava/features/books/presentation/screens/search_page.dart';

Widget createSearchWidget({String? initialQuery, BookProvider? provider}) {
  final bp = provider ?? BookProvider();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: bp),
    ],
    child: MaterialApp(
      home: SearchPage(initialQuery: initialQuery),
    ),
  );
}

void main() {
  testWidgets('SearchPage dapat dimuat dan dirender dengan baik pada kondisi awal',
      (WidgetTester tester) async {
    await tester.pumpWidget(createSearchWidget());

    expect(find.text('Search'), findsNWidgets(2));
    expect(find.text('Trending'), findsOneWidget);
    expect(find.text('Recently added'), findsOneWidget);
    expect(find.text('Recommended'), findsOneWidget);
  });

  testWidgets('SearchPage menampilkan Search result saat query terisi',
      (WidgetTester tester) async {
    final bp = BookProvider();
    bp.tambahBuku(
      const BookModel(
        id: '1',
        judul: 'The Unknown',
        penulis: 'Riley Sager',
        kategori: 'Horror',
        tahunTerbit: 2021,
      ),
    );
    await tester.pumpWidget(createSearchWidget(initialQuery: 'the unknown', provider: bp));

    expect(find.text('Search result'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.slider_horizontal_3), findsOneWidget);
    expect(find.text('Books'), findsOneWidget);
    expect(find.text('Authors'), findsOneWidget);
    expect(find.text('The Unknown'), findsOneWidget);
    expect(find.text('Riley Sager'), findsOneWidget);
    expect(find.text('Horror'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.chevron_right), findsOneWidget);
  });

  testWidgets('Menekan tab Authors menampilkan daftar author',
      (WidgetTester tester) async {
    final bp = BookProvider();
    bp.tambahBuku(
      const BookModel(
        id: '1',
        judul: 'The Unknown',
        penulis: 'Riley Sager',
        kategori: 'Horror',
        tahunTerbit: 2021,
      ),
    );
    bp.tambahBuku(
      const BookModel(
        id: '2',
        judul: 'Clean Code',
        penulis: 'Robert C. Martin',
        kategori: 'Teknologi',
        tahunTerbit: 2008,
      ),
    );
    bp.tambahBuku(
      const BookModel(
        id: '3',
        judul: 'The Lean Startup',
        penulis: 'Eric Ries',
        kategori: 'Bisnis',
        tahunTerbit: 2011,
      ),
    );
    await tester.pumpWidget(createSearchWidget(initialQuery: 'the', provider: bp));

    await tester.tap(find.text('Authors'));
    await tester.pumpAndSettle();

    expect(find.text('Riley Sager'), findsOneWidget);
    expect(find.text('Robert C. Martin'), findsOneWidget);
    expect(find.text('Eric Ries'), findsOneWidget);
  });

  testWidgets('Menekan tombol clear menghapus pencarian dan kembali ke browse awal',
      (WidgetTester tester) async {
    await tester.pumpWidget(createSearchWidget(initialQuery: 'the unknown'));

    expect(find.text('Search result'), findsOneWidget);

    await tester.tap(find.byIcon(CupertinoIcons.clear_thick_circled));
    await tester.pumpAndSettle();

    expect(find.text('Search'), findsNWidgets(2));
    expect(find.text('Trending'), findsOneWidget);
  });

  testWidgets('Membuka modal filter dan menekan panah dropdown menampilkan pilihan filter',
      (WidgetTester tester) async {
    await tester.pumpWidget(createSearchWidget());

    await tester.tap(find.byIcon(CupertinoIcons.slider_horizontal_3));
    await tester.pumpAndSettle();

    expect(find.text('Filter'), findsOneWidget);
    expect(find.text('Genre'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Rating'), findsOneWidget);
    expect(find.text('Apply filter'), findsOneWidget);

    await tester.tap(find.text('Genre'));
    await tester.pumpAndSettle();

    expect(find.text('Romance'), findsOneWidget);
    expect(find.text('Horror'), findsOneWidget);
    expect(find.text('Thriller'), findsOneWidget);
    expect(find.text('Fantasy'), findsOneWidget);
    expect(find.text('Sci-Fi'), findsOneWidget);
    expect(find.text('Historical'), findsOneWidget);
    expect(find.text('Self-Help'), findsOneWidget);

    await tester.tap(find.text('Romance'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Apply filter'));
    await tester.tap(find.text('Apply filter'));
    await tester.pumpAndSettle();

    expect(find.text('Filter'), findsNothing);
    expect(find.text('Romance'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
  });
}

