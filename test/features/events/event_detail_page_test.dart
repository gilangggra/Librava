import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/auth/domain/models/user_model.dart';
import 'package:librava/features/auth/presentation/providers/auth_provider.dart';
import 'package:librava/features/events/data/services/event_api_service.dart';
import 'package:librava/features/events/domain/models/event_model.dart';
import 'package:librava/features/events/presentation/providers/event_provider.dart';
import 'package:librava/features/events/presentation/screens/event_detail_page.dart';
import 'package:provider/provider.dart';

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
  group('EventDetailPage Admin Approval Button Visibility Tests', () {
    testWidgets('ketika status event APPROVED, tombol Approve TIDAK ada dan banner disetujui muncul', (tester) async {
      final fakeAdmin = FakeAuthProvider(
        user: const UserModel(
          id: '1',
          email: 'admin@librava.com',
          nama: 'Admin Librava',
          role: 'admin',
        ),
        token: 'fake_jwt_token',
      );

      final eventProvider = EventProvider(apiService: EventApiService());

      final approvedEvent = EventModel(
        id: 101,
        judul: 'Book Fair Telkom University 2026',
        deskripsi: 'Pameran buku terbesar di kampus Tel-U.',
        lokasi: 'Gedung Manterawu',
        tanggalMulai: DateTime.now().add(const Duration(days: 2)),
        status: 'APPROVED',
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: fakeAdmin),
            ChangeNotifierProvider<EventProvider>.value(value: eventProvider),
          ],
          child: MaterialApp(
            home: EventDetailPage(event: approvedEvent, isAdmin: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Memastikan tombol 'Approve' TIDAK ADA
      expect(find.widgetWithText(ElevatedButton, 'Approve'), findsNothing);

      // Memastikan banner 'Event Approved' ada
      expect(find.text('Event Approved'), findsOneWidget);
    });

    testWidgets('ketika status event PENDING, tombol Approve dan Reject MUNCUL untuk aksi admin', (tester) async {
      final fakeAdmin = FakeAuthProvider(
        user: const UserModel(
          id: '1',
          email: 'admin@librava.com',
          nama: 'Admin Librava',
          role: 'admin',
        ),
        token: 'fake_jwt_token',
      );

      final eventProvider = EventProvider(apiService: EventApiService());

      final pendingEvent = EventModel(
        id: 102,
        judul: 'Workshop Penulisan Ilmiah Mahasiswa',
        deskripsi: 'Pelatihan menulis karya ilmiah.',
        lokasi: 'Ruang Seminar Perpustakaan',
        tanggalMulai: DateTime.now().add(const Duration(days: 5)),
        status: 'PENDING',
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: fakeAdmin),
            ChangeNotifierProvider<EventProvider>.value(value: eventProvider),
          ],
          child: MaterialApp(
            home: EventDetailPage(event: pendingEvent, isAdmin: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Memastikan tombol Approve dan Reject ada
      expect(find.widgetWithText(ElevatedButton, 'Approve'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Reject'), findsOneWidget);
    });
  });
}
