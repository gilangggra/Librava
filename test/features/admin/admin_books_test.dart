import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:librava/features/admin/data/services/admin_api_service.dart';
import 'package:librava/features/admin/domain/models/admin_book_model.dart';
import 'package:librava/features/admin/presentation/providers/admin_provider.dart';
import 'package:librava/features/admin/presentation/screens/admin_book_detail_page.dart';
import 'package:librava/features/admin/presentation/screens/admin_books_page.dart';
import 'package:librava/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

MockClient buatBackendBukuPalsu({bool gagal = false}) {
  return MockClient((request) async {
    if (gagal) {
      return http.Response(
        jsonEncode({'success': false, 'message': 'Server sedang bermasalah'}),
        500,
      );
    }
    if (request.url.path.endsWith('/books')) {
      return http.Response(
        jsonEncode({
          'success': true,
          'data': [
            {
              'id': 1,
              'judul': 'The Unknown',
              'penulis': 'Riley Sager',
              'penerbit': 'Dutton',
              'kategori': 'Horror/Thriller',
              'status': 'Tersedia',
              'deskripsi': 'A chilling mystery unfolds.',
              'foto_buku': null,
              'owner_nama': 'Budi Santoso',
            },
            {
              'id': 2,
              'judul': 'Atomic Habits',
              'penulis': 'James Clear',
              'kategori': 'Self Help',
              'status': 'Dipinjam',
              'deskripsi': '',
              'foto_buku': null,
              'owner_nama': 'Sari Dewi',
            },
          ],
          'meta': {'total': 2},
        }),
        200,
      );
    }
    return http.Response(jsonEncode({'success': false}), 404);
  });
}

Widget bungkusHalaman(AdminProvider adminProvider, Widget halaman) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider.value(value: adminProvider),
    ],
    child: MaterialApp(home: halaman),
  );
}

void main() {
  group('AdminBookModel Unit Tests', () {
    test('memecah kategori menjadi daftar genre', () {
      const buku = AdminBookModel(
        id: '1',
        judul: 'The Unknown',
        penulis: 'Riley Sager',
        kategori: 'Horror/Thriller',
      );
      expect(buku.daftarGenre, ['Horror', 'Thriller']);
      expect(buku.genreTampil, 'Horror/Thriller');
    });

    test('menerjemahkan status ke bahasa Inggris', () {
      const tersedia = AdminBookModel(id: '1', judul: 'A', penulis: 'B');
      const dipinjam = AdminBookModel(
        id: '2',
        judul: 'A',
        penulis: 'B',
        status: 'Dipinjam',
      );
      expect(tersedia.statusTampil, 'Available');
      expect(dipinjam.statusTampil, 'Borrowed');
    });

    test('kategori kosong menghasilkan strip', () {
      const buku = AdminBookModel(id: '1', judul: 'A', penulis: 'B');
      expect(buku.daftarGenre, isEmpty);
      expect(buku.genreTampil, '-');
    });
  });

  group('AdminProvider Buku Unit Tests', () {
    test('fetchBuku mengisi daftar dan pencarian bekerja', () async {
      final provider = AdminProvider(
        apiService: AdminApiService(client: buatBackendBukuPalsu()),
      );
      await provider.fetchBuku('token_admin');

      expect(provider.jumlahBuku, 2);
      expect(provider.errorBuku, isNull);

      provider.cariBuku('atomic');
      expect(provider.daftarBukuTampil.length, 1);
      expect(provider.daftarBukuTampil.first.judul, 'Atomic Habits');

      provider.cariBuku('horror');
      expect(provider.daftarBukuTampil.first.judul, 'The Unknown');
    });

    test('fetchBuku menyimpan pesan error saat server gagal', () async {
      final provider = AdminProvider(
        apiService: AdminApiService(client: buatBackendBukuPalsu(gagal: true)),
      );
      await provider.fetchBuku('token_admin');

      expect(provider.jumlahBuku, 0);
      expect(provider.errorBuku, 'Server sedang bermasalah');
    });
  });

  group('AdminBooksPage Widget Tests', () {
    testWidgets('menampilkan daftar buku, pencarian, dan membuka detail',
        (tester) async {
      final adminProvider = AdminProvider(
        apiService: AdminApiService(client: buatBackendBukuPalsu()),
      );
      await adminProvider.fetchBuku('token_admin');

      await tester.pumpWidget(
        bungkusHalaman(adminProvider, const AdminBooksPage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Book data'), findsOneWidget);
      expect(find.text('The Unknown'), findsOneWidget);
      expect(find.text('Atomic Habits'), findsOneWidget);
      expect(find.text('Horror'), findsOneWidget);
      expect(find.text('Thriller'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'unknown');
      await tester.pumpAndSettle();
      expect(find.text('Atomic Habits'), findsNothing);

      await tester.tap(find.byIcon(CupertinoIcons.chevron_right));
      await tester.pumpAndSettle();

      expect(find.text('Book view'), findsOneWidget);
      expect(find.text('Horror/Thriller'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      expect(find.text('Dutton'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('A chilling mystery unfolds.'), findsOneWidget);
    });

    testWidgets('menampilkan pesan error dan tombol coba lagi', (tester) async {
      final adminProvider = AdminProvider(
        apiService: AdminApiService(client: buatBackendBukuPalsu(gagal: true)),
      );
      await adminProvider.fetchBuku('token_admin');

      await tester.pumpWidget(
        bungkusHalaman(adminProvider, const AdminBooksPage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Data buku gagal dimuat'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);
    });
  });

  group('AdminBookDetailPage Widget Tests', () {
    testWidgets('menampilkan strip dan teks cadangan untuk data kosong',
        (tester) async {
      const buku = AdminBookModel(id: '9', judul: 'Buku Tanpa Info', penulis: '');

      await tester.pumpWidget(
        bungkusHalaman(
          AdminProvider(),
          const AdminBookDetailPage(buku: buku),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Buku Tanpa Info'), findsOneWidget);
      expect(find.text('-'), findsWidgets);
      expect(find.text('Belum ada deskripsi untuk buku ini.'), findsOneWidget);
    });
  });
}
