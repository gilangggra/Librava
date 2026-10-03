import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:librava/features/admin/data/services/admin_api_service.dart';
import 'package:librava/features/admin/domain/models/admin_dashboard_model.dart';
import 'package:librava/features/admin/domain/models/admin_user_model.dart';
import 'package:librava/features/admin/presentation/providers/admin_provider.dart';
import 'package:librava/features/admin/presentation/screens/admin_dashboard_page.dart';
import 'package:librava/features/admin/presentation/screens/admin_users_page.dart';
import 'package:librava/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

MockClient buatBackendAdminPalsu() {
  return MockClient((request) async {
    if (request.url.path.endsWith('/admin/users')) {
      return http.Response(
        jsonEncode({
          'success': true,
          'data': [
            {
              'id': 1,
              'email': 'admin@librava.com',
              'nama_lengkap': 'Librava Admin',
              'role': 'admin',
            },
            {
              'id': 2,
              'email': 'andireads@gmail.com',
              'nama_lengkap': 'Andi Baker',
              'nim': '1301210003',
              'role': 'mahasiswa',
              'created_at': '2026-09-26T05:23:31.702Z',
            },
            {
              'id': 3,
              'email': 'sari@student.telkomuniversity.ac.id',
              'nama_lengkap': 'Sari Dewi',
              'nim': '1301210002',
              'role': 'mahasiswa',
            },
          ],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    return http.Response('{}', 404);
  });
}

void main() {
  group('AdminDashboardModel Unit Tests', () {
    test('default model initializes with expected values', () {
      const model = AdminDashboardModel();
      expect(model.totalStudents, 320);
      expect(model.totalBooks, 1245);
      expect(model.totalRequests, 86);
      expect(model.totalTransactions, 62);
    });

    test('fromApiJson parses API payload correctly', () {
      final json = {
        'users': {'mahasiswa': 400},
        'books': {'total': 1500},
        'transactions': {
          'menunggu_konfirmasi': 90,
          'total': 75,
        },
        'recent_transactions': [
          {
            'id': 1,
            'book_judul': 'The Unknown',
            'tipe_transaksi': 'barter',
            'requester_nama': 'Andi Pratama',
            'status': 'MENUNGGU_KONFIRMASI',
          }
        ]
      };

      final model = AdminDashboardModel.fromApiJson(json);
      expect(model.totalStudents, 400);
      expect(model.totalBooks, 1500);
      expect(model.totalRequests, 90);
      expect(model.totalTransactions, 75);
      expect(model.recentActivity.isNotEmpty, true);
    });
  });

  group('AdminUserModel Unit Tests', () {
    test('username diambil dari bagian depan email', () {
      final user = AdminUserModel.fromJson({
        'id': 2,
        'email': 'andireads@gmail.com',
        'nama_lengkap': 'Andi Baker',
        'created_at': '2026-09-26T05:23:31.702Z',
      });
      expect(user.username, '@andireads');
      expect(user.tanggalDaftar, '2026-09-26');
      expect(user.punyaNim, false);
    });
  });

  group('AdminProvider Unit Tests', () {
    test('fetchMahasiswa hanya menyimpan user dengan role mahasiswa', () async {
      final provider = AdminProvider(
        apiService: AdminApiService(client: buatBackendAdminPalsu()),
      );

      await provider.fetchMahasiswa('token_admin');

      expect(provider.errorMahasiswa, isNull);
      expect(provider.jumlahMahasiswa, 2);
      expect(
        provider.daftarMahasiswaTampil.any((u) => u.role == 'admin'),
        false,
      );
    });

    test('cariMahasiswa menyaring berdasarkan nama, email, atau NIM', () async {
      final provider = AdminProvider(
        apiService: AdminApiService(client: buatBackendAdminPalsu()),
      );
      await provider.fetchMahasiswa('token_admin');

      provider.cariMahasiswa('sari');
      expect(provider.daftarMahasiswaTampil.length, 1);
      expect(provider.daftarMahasiswaTampil.first.nama, 'Sari Dewi');

      provider.cariMahasiswa('1301210003');
      expect(provider.daftarMahasiswaTampil.first.nama, 'Andi Baker');

      provider.cariMahasiswa('tidak-ada');
      expect(provider.daftarMahasiswaTampil, isEmpty);
    });

    test('fetchMahasiswa mengisi pesan error saat server mati', () async {
      final provider = AdminProvider(
        apiService: AdminApiService(
          client: MockClient((request) async {
            throw http.ClientException('Connection refused');
          }),
        ),
      );

      await provider.fetchMahasiswa('token_admin');

      expect(provider.jumlahMahasiswa, 0);
      expect(provider.errorMahasiswa, contains('server'));
    });
  });

  group('AdminDashboardPage Widget Tests', () {
    testWidgets('renders all metric cards, recent activity, recent transactions, and bottom nav', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => AdminProvider()),
          ],
          child: const MaterialApp(
            home: AdminDashboardPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Admin dashboard'), findsOneWidget);
      expect(find.text('Total students'), findsOneWidget);
      expect(find.text('Total books'), findsOneWidget);
      expect(find.text('Total requests'), findsOneWidget);
      expect(find.text('Total transactions'), findsOneWidget);
      expect(find.text('Recent activity'), findsOneWidget);
      expect(find.text('Recent transactions'), findsOneWidget);
      expect(find.text('The Unknown'), findsAtLeastNWidgets(1));
      expect(find.text('Fruit Fly'), findsAtLeastNWidgets(1));
    });
  });

  group('AdminUsersPage Widget Tests', () {
    testWidgets('menampilkan daftar mahasiswa, pencarian, dan detail', (tester) async {
      final adminProvider = AdminProvider(
        apiService: AdminApiService(client: buatBackendAdminPalsu()),
      );
      await adminProvider.fetchMahasiswa('token_admin');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider.value(value: adminProvider),
          ],
          child: const MaterialApp(
            home: AdminUsersPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('User data'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Andi Baker'), findsOneWidget);
      expect(find.text('@andireads'), findsOneWidget);
      expect(find.text('andireads@gmail.com'), findsOneWidget);
      expect(find.text('Sari Dewi'), findsOneWidget);
      expect(find.text('Librava Admin'), findsNothing);

      await tester.enterText(find.byType(TextField), 'sari');
      await tester.pumpAndSettle();
      expect(find.text('Sari Dewi'), findsOneWidget);
      expect(find.text('Andi Baker'), findsNothing);

      await tester.tap(find.text('Sari Dewi'));
      await tester.pumpAndSettle();
      expect(find.text('User view'), findsOneWidget);
      expect(find.text('University'), findsOneWidget);
      expect(find.text('1301210002'), findsOneWidget);

      await tester.tap(find.byIcon(CupertinoIcons.chevron_left));
      await tester.pumpAndSettle();
      expect(find.text('User data'), findsOneWidget);
    });
  });
}
