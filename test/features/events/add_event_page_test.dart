import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:librava/features/admin/presentation/widgets/admin_bottom_nav.dart';
import 'package:librava/features/auth/domain/models/user_model.dart';
import 'package:librava/features/auth/presentation/providers/auth_provider.dart';
import 'package:librava/features/events/data/services/event_api_service.dart';
import 'package:librava/features/events/presentation/providers/event_provider.dart';
import 'package:librava/features/events/presentation/screens/add_event_page.dart';
import 'package:provider/provider.dart';

MockClient buatMockEventApi({bool returnSuccess = true}) {
  return MockClient((request) async {
    if (request.url.path.endsWith('/events') && request.method == 'POST') {
      final body = jsonDecode(request.body);
      return http.Response(
        jsonEncode({
          'success': true,
          'message': 'Event berhasil dibuat.',
          'data': {
            'id': 99,
            'judul': body['judul'],
            'deskripsi': body['deskripsi'],
            'kategori': body['kategori'],
            'lokasi': body['lokasi'],
            'tanggal_mulai': body['tanggal_mulai'],
            'tanggal_selesai': body['tanggal_selesai'],
            'kuota': body['kuota'] ?? 100,
            'foto_event': body['foto_event'],
            'status': 'APPROVED',
            'created_by_id': 1,
            'jumlah_pendaftar': 0,
          },
        }),
        201,
        headers: {'content-type': 'application/json'},
      );
    }
    return http.Response('{"success": false}', 400);
  });
}

class FakeAuthProvider extends AuthProvider {
  final UserModel? _user;
  final String? _fakeToken;

  FakeAuthProvider({UserModel? user, String? token})
      : _user = user,
        _fakeToken = token;

  @override
  UserModel? get currentUser => _user;

  @override
  String? get token => _fakeToken;

  @override
  bool get isLoggedIn => _user != null;
}

void main() {
  group('AddEventPage Widget & Validation Tests', () {
    testWidgets('renders AdminBottomNav when opened with isAdmin: true', (tester) async {
      final fakeAdmin = FakeAuthProvider(
        user: const UserModel(
          id: '1',
          email: 'admin@librava.com',
          nama: 'Admin Librava',
          role: 'admin',
        ),
        token: 'fake_jwt_token',
      );

      final eventProvider = EventProvider(
        apiService: EventApiService(client: buatMockEventApi()),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: fakeAdmin),
            ChangeNotifierProvider<EventProvider>.value(value: eventProvider),
          ],
          child: const MaterialApp(
            home: AddEventPage(isAdmin: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Memastikan AdminBottomNav dirender, bukan student navigation
      expect(find.byType(AdminBottomNav), findsOneWidget);
      expect(find.text('Event title'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Publish event'), findsOneWidget);
    });

    testWidgets('validasi judul kosong menampilkan pesan error', (tester) async {
      final fakeAdmin = FakeAuthProvider(
        user: const UserModel(
          id: '1',
          email: 'admin@librava.com',
          nama: 'Admin Librava',
          role: 'admin',
        ),
        token: 'fake_jwt_token',
      );

      final eventProvider = EventProvider(
        apiService: EventApiService(client: buatMockEventApi()),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: fakeAdmin),
            ChangeNotifierProvider<EventProvider>.value(value: eventProvider),
          ],
          child: const MaterialApp(
            home: AddEventPage(isAdmin: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll sampai tombol terlihat, lalu tekan tombol publish saat judul masih kosong
      final publishBtn = find.text('Publish event');
      await tester.ensureVisible(publishBtn);
      await tester.pumpAndSettle();
      await tester.tap(publishBtn);
      await tester.pump();

      expect(find.text('Judul event tidak boleh kosong.'), findsOneWidget);
    });

    testWidgets('validasi banner kosong menampilkan pesan error', (tester) async {
      final fakeAdmin = FakeAuthProvider(
        user: const UserModel(
          id: '1',
          email: 'admin@librava.com',
          nama: 'Admin Librava',
          role: 'admin',
        ),
        token: 'fake_jwt_token',
      );

      final eventProvider = EventProvider(
        apiService: EventApiService(client: buatMockEventApi()),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: fakeAdmin),
            ChangeNotifierProvider<EventProvider>.value(value: eventProvider),
          ],
          child: const MaterialApp(
            home: AddEventPage(isAdmin: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Isi judul tapi biarkan banner kosong
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Seminar AI & Literasi 2026');
      await tester.pumpAndSettle();

      expect(find.text('Upload event banner'), findsOneWidget);

      // Mengetuk kotak banner langsung memanggil file picker tanpa membuka modal pilihan template
      await tester.tap(find.text('Upload event banner'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);

      final publishBtn = find.text('Publish event');
      await tester.ensureVisible(publishBtn);
      await tester.pumpAndSettle();
      await tester.tap(publishBtn);
      await tester.pump();

      expect(find.text('Banner event tidak boleh kosong. Silakan pilih atau unggah banner event.'), findsOneWidget);
    });

    testWidgets('validasi lokasi kosong menampilkan pesan error', (tester) async {
      final fakeAdmin = FakeAuthProvider(
        user: const UserModel(
          id: '1',
          email: 'admin@librava.com',
          nama: 'Admin Librava',
          role: 'admin',
        ),
        token: 'fake_jwt_token',
      );

      final eventProvider = EventProvider(
        apiService: EventApiService(client: buatMockEventApi()),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: fakeAdmin),
            ChangeNotifierProvider<EventProvider>.value(value: eventProvider),
          ],
          child: const MaterialApp(
            home: AddEventPage(
              isAdmin: true,
              initialBanner: 'assets/images/event_library.jpg',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Isi judul
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Seminar AI & Literasi 2026');
      await tester.pumpAndSettle();

      // Tekan tombol publish saat lokasi masih kosong
      final publishBtn = find.text('Publish event');
      await tester.ensureVisible(publishBtn);
      await tester.pumpAndSettle();
      await tester.tap(publishBtn);
      await tester.pump();

      expect(find.text('Lokasi event tidak boleh kosong.'), findsOneWidget);
    });

    testWidgets('validasi deskripsi kosong menampilkan pesan error', (tester) async {
      final fakeAdmin = FakeAuthProvider(
        user: const UserModel(
          id: '1',
          email: 'admin@librava.com',
          nama: 'Admin Librava',
          role: 'admin',
        ),
        token: 'fake_jwt_token',
      );

      final eventProvider = EventProvider(
        apiService: EventApiService(client: buatMockEventApi()),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: fakeAdmin),
            ChangeNotifierProvider<EventProvider>.value(value: eventProvider),
          ],
          child: const MaterialApp(
            home: AddEventPage(
              isAdmin: true,
              initialBanner: 'assets/images/event_library.jpg',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Isi judul & lokasi
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Seminar AI & Literasi 2026');
      await tester.enterText(textFields.at(1), 'Auditorium Telkom University');
      await tester.pumpAndSettle();

      // Tekan tombol publish saat deskripsi masih kosong
      final publishBtn = find.text('Publish event');
      await tester.ensureVisible(publishBtn);
      await tester.pumpAndSettle();
      await tester.tap(publishBtn);
      await tester.pump();

      expect(find.text('Deskripsi event tidak boleh kosong.'), findsOneWidget);
    });

    testWidgets('berhasil mempublikasikan event dan menampilkan notif "Event berhasil dibuat!"', (tester) async {
      final fakeAdmin = FakeAuthProvider(
        user: const UserModel(
          id: '1',
          email: 'admin@librava.com',
          nama: 'Admin Librava',
          role: 'admin',
        ),
        token: 'fake_jwt_token',
      );

      final eventProvider = EventProvider(
        apiService: EventApiService(client: buatMockEventApi()),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: fakeAdmin),
            ChangeNotifierProvider<EventProvider>.value(value: eventProvider),
          ],
          child: const MaterialApp(
            home: AddEventPage(
              isAdmin: true,
              initialBanner: 'assets/images/event_library.jpg',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Isi form lengkap
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Seminar AI & Literasi 2026');
      await tester.enterText(textFields.at(1), 'Auditorium Gedung Damar');
      await tester.enterText(textFields.at(2), 'Diskusi seru mengenai implementasi AI dalam dunia literasi.');
      await tester.pumpAndSettle();

      // Scroll sampai tombol terlihat dan publish event
      final publishBtn = find.text('Publish event');
      await tester.ensureVisible(publishBtn);
      await tester.pumpAndSettle();
      await tester.tap(publishBtn);
      await tester.pump(); // frame animasi mulai
      await tester.pump(const Duration(milliseconds: 100)); // async eventProvider selesai dan snackbar muncul

      // Verifikasi notif dan event berhasil ditambahkan ke EventProvider
      expect(find.text('Event berhasil dibuat!'), findsOneWidget);
      expect(eventProvider.events.any((e) => e.judul == 'Seminar AI & Literasi 2026'), isTrue);
    });
  });
}
