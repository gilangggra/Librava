import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:librava/features/auth/data/services/auth_api_service.dart';
import 'package:librava/features/auth/domain/models/user_model.dart';
import 'package:librava/features/auth/presentation/providers/auth_provider.dart';

void main() {
  group('UserModel Serialization', () {
    test('UserModel dapat mem-parse JSON dari respons backend dengan tepat', () {
      final json = {
        'id': 42,
        'nama_lengkap': 'Gilang Ramadan',
        'email': 'gilang@example.com',
        'nim': '1301213000',
        'universitas': 'Telkom University',
        'foto_profil': 'https://example.com/avatar.jpg',
        'role': 'mahasiswa',
        'saldo_dummy': 150000,
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '42');
      expect(user.nama, 'Gilang Ramadan');
      expect(user.email, 'gilang@example.com');
      expect(user.nim, '1301213000');
      expect(user.universitas, 'Telkom University');
      expect(user.fotoProfil, 'https://example.com/avatar.jpg');
      expect(user.role, 'mahasiswa');
      expect(user.saldoDummy, 150000.0);
    });

    test('UserModel.toJson menghasilkan struktur JSON yang sesuai', () {
      const user = UserModel(
        id: '1',
        nama: 'Budi Santoso',
        email: 'budi@example.com',
        nim: '1301210001',
      );

      final json = user.toJson();

      expect(json['id'], '1');
      expect(json['nama_lengkap'], 'Budi Santoso');
      expect(json['email'], 'budi@example.com');
      expect(json['nim'], '1301210001');
    });
  });

  group('AuthApiService Tests', () {
    test('login berhasil mengembalikan AuthResponse saat respons 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Login berhasil.',
            'data': {
              'user': {
                'id': 1,
                'email': 'test@example.com',
                'nama_lengkap': 'Test User',
                'nim': '1301210002',
                'universitas': 'Telkom University',
                'role': 'mahasiswa',
                'saldo_dummy': 100000,
              },
              'token': 'mock_jwt_token_12345',
            }
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = AuthApiService(client: mockClient);
      final response = await service.login(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(response.token, 'mock_jwt_token_12345');
      expect(response.user.email, 'test@example.com');
      expect(response.user.nama, 'Test User');
    });

    test('login melempar Exception saat respons 401', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Email atau password salah.',
          }),
          401,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = AuthApiService(client: mockClient);

      expect(
        () => service.login(
          email: 'wrong@example.com',
          password: 'wrongpassword',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('AuthProvider berhasil login menggunakan AuthApiService nyata/mock', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Login berhasil.',
            'data': {
              'user': {
                'id': 99,
                'email': 'provider@example.com',
                'nama_lengkap': 'Provider User',
                'role': 'mahasiswa',
                'saldo_dummy': 100000,
              },
              'token': 'jwt_provider_token',
            }
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiService = AuthApiService(client: mockClient);
      final authProvider = AuthProvider(apiService: apiService);

      final success = await authProvider.masuk(
        email: 'provider@example.com',
        password: 'secret',
      );

      expect(success, true);
      expect(authProvider.isLoggedIn, true);
      expect(authProvider.token, 'jwt_provider_token');
      expect(authProvider.currentUser?.nama, 'Provider User');
    });
  });
}
