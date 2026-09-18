import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/auth/presentation/providers/auth_provider.dart';

void main() {
  group('AuthProvider Unit Tests', () {
    late AuthProvider provider;

    setUp(() {
      provider = AuthProvider();
    });

    test('Inisialisasi awal belum login dan currentUser null', () {
      expect(provider.isLoggedIn, false);
      expect(provider.currentUser, isNull);
      expect(provider.isLoading, false);
    });

    test('daftar berhasil membuat user baru dan login', () async {
      final sukses = await provider.daftar(
        nama: 'Gilang Ramadan',
        email: 'gilang@telkomuniversity.ac.id',
        password: 'password123',
      );

      expect(sukses, true);
      expect(provider.isLoggedIn, true);
      expect(provider.currentUser?.nama, 'Gilang Ramadan');
      expect(provider.currentUser?.email, 'gilang@telkomuniversity.ac.id');
    });

    test('masuk berhasil login dengan akun', () async {
      final sukses = await provider.masuk(
        email: 'syahdan@telkomuniversity.ac.id',
        password: 'password123',
      );

      expect(sukses, true);
      expect(provider.isLoggedIn, true);
      expect(provider.currentUser?.email, 'syahdan@telkomuniversity.ac.id');
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
  });
}
