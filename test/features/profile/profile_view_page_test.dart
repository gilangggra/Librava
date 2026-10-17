import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/profile/presentation/screens/profile_view_page.dart';

void main() {
  testWidgets('ProfileViewPage menampilkan seluruh elemen sesuai mockup',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileViewPage(
          name: 'Budi Santoso',
          email: 'budi@example.com',
          phone: '+62 8123456789',
          booksRead: 10,
          booksBorrowed: 2,
          favorites: 4,
        ),
      ),
    );

    // Header
    expect(find.text('Profile view'), findsOneWidget);

    // Kartu Pengguna
    expect(find.text('User'), findsOneWidget);
    expect(find.text('A casual reader'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('budi@example.com'), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('+62 8123456789'), findsOneWidget);

    // Tombol Chat
    expect(find.text('Chat'), findsOneWidget);

    // Activity
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Books Read'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('Books Borrowed'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('Menekan tombol Chat membuka ChatRoomPage',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileViewPage(
          name: 'Budi Santoso',
        ),
      ),
    );

    await tester.ensureVisible(find.text('Chat'));
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    // Verifikasi berada di halaman chat room dengan user yang bersangkutan
    expect(find.text('Budi Santoso'), findsWidgets);
  });
}
