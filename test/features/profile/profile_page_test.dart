import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/auth/presentation/providers/auth_provider.dart';
import 'package:librava/features/profile/presentation/screens/edit_profile_page.dart';
import 'package:librava/features/profile/presentation/screens/profile_page.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('ProfilePage dapat dimuat dan dirender dengan baik',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: ProfilePage(),
        ),
      ),
    );

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('User'), findsOneWidget);
    expect(find.text('A casual reader'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Books Read'), findsOneWidget);
    expect(find.text('Books Borrowed'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Recent activity'), findsOneWidget);
    expect(find.text('The Unknown'), findsOneWidget);
    expect(find.text('Fruit Fly'), findsOneWidget);
  });

  testWidgets('Tombol Edit profile membuka halaman EditProfilePage',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: ProfilePage(),
        ),
      ),
    );

    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();

    expect(find.byType(EditProfilePage), findsOneWidget);
    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.text('Edit Foto'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Bio'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('EditProfilePage dapat mengedit dan menyimpan profil',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: EditProfilePage(),
        ),
      ),
    );

    expect(find.text('Save'), findsOneWidget);
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pump();
  });
}
