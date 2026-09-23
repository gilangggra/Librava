import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/auth/presentation/providers/auth_provider.dart';
import 'package:librava/features/books/presentation/screens/my_book_page.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('MyBookPage dapat dimuat dan dirender dengan baik',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: MyBookPage(),
        ),
      ),
    );

    expect(find.text('My book'), findsOneWidget);
    expect(find.text('Check your book collection'), findsOneWidget);
    expect(find.text('My Collection'), findsOneWidget);
    expect(find.text('Borrowed'), findsOneWidget);
    expect(find.text('Lent out'), findsOneWidget);
  });

  testWidgets('Menekan tombol tambah buku membuka bottom sheet tambah buku',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: MyBookPage(),
        ),
      ),
    );

    await tester.tap(find.byIcon(CupertinoIcons.plus_circle));
    await tester.pumpAndSettle();

    expect(find.text('Tambah Koleksi Buku'), findsOneWidget);
    expect(find.text('Judul Buku'), findsOneWidget);
    expect(find.text('Penulis'), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('Simpan Buku'), findsOneWidget);
  });
}
