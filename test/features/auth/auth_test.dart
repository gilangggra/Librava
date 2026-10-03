import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:librava/features/auth/data/services/auth_api_service.dart';
import 'package:librava/features/auth/presentation/providers/auth_provider.dart';

MockClient buatBackendPalsu() {
  final Map<String, Map<String, String>> database = {
    'syahdan@telkomuniversity.ac.id': {
      'password': 'password123',
      'nama': 'Syahdan',
    },
    'gilang@telkomuniversity.ac.id': {
      'password': 'password123',
      'nama': 'Gilang Ramadan',
    },
  };

  http.Response sukses(String email, String nama) {
    return http.Response(
      jsonEncode({
        'success': true,
        'data': {
          'user': {
            'id': email.hashCode,
            'email': email,
            'nama_lengkap': nama,
            'role': 'mahasiswa',
          },
          'token': 'token_$email',
        },
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  return MockClient((request) async {
    final path = request.url.path;

    if (path.endsWith('/register')) {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final email = (body['email'] as String).toLowerCase();
      if (database.containsKey(email)) {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Email sudah terdaftar. Silakan gunakan email lain.',
          }),
          400,
          headers: {'content-type': 'application/json'},
        );
      }
      database[email] = {
        'password': body['password'] as String,
        'nama': body['nama_lengkap'] as String,
      };
      return sukses(email, body['nama_lengkap'] as String);
    }

    if (path.endsWith('/login')) {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final email = (body['email'] as String).toLowerCase();
      final akun = database[email];
      if (akun == null || akun['password'] != body['password']) {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Email atau password salah.',
          }),
          401,
          headers: {'content-type': 'application/json'},
        );
      }
      return sukses(email, akun['nama']!);
    }

    return http.Response(
      jsonEncode({'success': false, 'message': 'Not found'}),
      404,
      headers: {'content-type': 'application/json'},
    );
  });
}

void main() {
  group('AuthProvider Unit Tests', () {
    late AuthProvider provider;

    setUp(() {
      provider = AuthProvider(
        apiService: AuthApiService(client: buatBackendPalsu()),
      );
    });

    test('Inisialisasi awal belum login dan currentUser null', () {
      expect(provider.isLoggedIn, false);
      expect(provider.currentUser, isNull);
      expect(provider.isLoading, false);
    });

    test('daftar berhasil membuat user baru dan login', () async {
      final sukses = await provider.daftar(
        nama: 'Gilang Ramadan',
        email: 'gilang.baru@telkomuniversity.ac.id',
        password: 'password123',
      );

      expect(sukses, true);
      expect(provider.isLoggedIn, true);
      expect(provider.currentUser?.nama, 'Gilang Ramadan');
      expect(provider.currentUser?.email, 'gilang.baru@telkomuniversity.ac.id');
    });

    test('daftar gagal jika email sudah terdaftar di database', () async {
      final sukses = await provider.daftar(
        nama: 'Syahdan Kedua',
        email: 'syahdan@telkomuniversity.ac.id',
        password: 'password123',
      );

      expect(sukses, false);
      expect(provider.isLoggedIn, false);
      expect(provider.errorMessage, contains('sudah terdaftar'));
    });

    test('daftar gagal jika server tidak bisa dihubungi', () async {
      final providerOffline = AuthProvider(
        apiService: AuthApiService(
          client: MockClient((request) async {
            throw http.ClientException('Connection refused');
          }),
        ),
      );

      final sukses = await providerOffline.daftar(
        nama: 'Tanpa Server',
        email: 'offline@example.com',
        password: 'password123',
      );

      expect(sukses, false);
      expect(providerOffline.isLoggedIn, false);
      expect(providerOffline.errorMessage, contains('server'));
    });

    test('masuk berhasil login dengan email dan password yang benar', () async {
      final sukses = await provider.masuk(
        email: 'syahdan@telkomuniversity.ac.id',
        password: 'password123',
      );

      expect(sukses, true);
      expect(provider.isLoggedIn, true);
      expect(provider.currentUser?.email, 'syahdan@telkomuniversity.ac.id');
    });

    test('masuk gagal jika password salah', () async {
      final sukses = await provider.masuk(
        email: 'syahdan@telkomuniversity.ac.id',
        password: 'passwordSALAH',
      );

      expect(sukses, false);
      expect(provider.isLoggedIn, false);
      expect(provider.errorMessage, contains('salah'));
    });

    test('masuk gagal jika email tidak terdaftar', () async {
      final sukses = await provider.masuk(
        email: 'tidakada@telkomuniversity.ac.id',
        password: 'password123',
      );

      expect(sukses, false);
      expect(provider.isLoggedIn, false);
    });

    test('updateProfil berhasil memperbarui nama dan universitas', () async {
      await provider.masuk(
        email: 'gilang@telkomuniversity.ac.id',
        password: 'password123',
      );

      final suksesUpdate = await provider.updateProfil(
        nama: 'Gilang Ramadan Baru',
        universitas: 'Universitas Telkom Bandung',
      );

      expect(suksesUpdate, true);
      expect(provider.currentUser?.nama, 'Gilang Ramadan Baru');
      expect(provider.currentUser?.universitas, 'Universitas Telkom Bandung');
    });

    test('updateProfil gagal jika belum login', () async {
      final suksesUpdate = await provider.updateProfil(
        nama: 'Nama Baru',
      );

      expect(suksesUpdate, false);
    });

    test('keluar berhasil mereset status login', () async {
      await provider.masuk(
        email: 'gilang@telkomuniversity.ac.id',
        password: 'password123',
      );

      expect(provider.isLoggedIn, true);

      provider.keluar();

      expect(provider.isLoggedIn, false);
      expect(provider.currentUser, isNull);
    });

    test('masuk dengan akun yang didaftarkan mempertahankan nama lengkap asli', () async {
      await provider.daftar(
        nama: 'Ujang Knalpot',
        email: 'ujang@example.com',
        password: 'password123',
      );
      provider.keluar();

      final loginSukses = await provider.masuk(
        email: 'ujang@example.com',
        password: 'password123',
      );

      expect(loginSukses, true);
      expect(provider.currentUser?.nama, 'Ujang Knalpot');
    });

    test('resetPassword berhasil mengubah status loading dan mengembalikan true', () async {
      final suksesReset = await provider.resetPassword(
        email: 'ujang@example.com',
        passwordBaru: 'newpassword123',
      );

      expect(suksesReset, true);
      expect(provider.isLoading, false);
    });
  });
}
