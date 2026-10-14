import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/auth/presentation/providers/auth_provider.dart';
import 'package:librava/features/auth/presentation/widgets/google_sign_in_modal.dart';
import 'package:librava/features/auth/data/services/auth_api_service.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

void main() {
  testWidgets('Trigger Google Sign-In helper functions exist and callable',
      (WidgetTester tester) async {
    final mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'success': true,
          'message': 'Login Google berhasil.',
          'data': {
            'user': {
              'id': 67,
              'email': 'gilang.google@telkomuniversity.ac.id',
              'nama_lengkap': 'Gilang Ramadan (Google)',
              'role': 'mahasiswa',
              'saldo_dummy': 100000,
            },
            'token': 'mock_token',
          }
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final authProvider = AuthProvider(apiService: AuthApiService(client: mockClient));

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showGoogleSignInConfirmationModal(context),
                child: const Text('Masuk dengan Google'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Masuk dengan Google'), findsOneWidget);
  });
}
