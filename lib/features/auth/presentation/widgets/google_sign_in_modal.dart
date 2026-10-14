import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/google_auth_service.dart';
import '../providers/auth_provider.dart';
import '../../../home/presentation/screens/home_page.dart';

/// Membuka alur autentikasi Akun Google ASLI (Official Google Sign-In via accounts.google.com)
Future<void> showGoogleSignInConfirmationModal(BuildContext context) {
  return handleRealGoogleSignIn(context);
}

/// Menangani autentikasi Akun Google Asli dengan Google Identity Services
Future<void> handleRealGoogleSignIn(BuildContext context) async {
  final authProvider = context.read<AuthProvider>();
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  // Dialog indikator saat jendela Google Sign-In resmi dibuka
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Image.asset(
                'assets/images/google_logo.png',
                width: 28,
                height: 28,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.8,
                color: Color(0xFF4285F4),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Menghubungkan ke Akun Google...',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Silakan pilih akun Google asli Anda pada pop-up resmi Google.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  String? token;
  dynamic googleError;

  try {
    token = await GoogleAuthService.signInWithRealGoogle();
  } catch (e) {
    googleError = e;
  }

  if (!context.mounted) return;
  // Tutup dialog indikator
  Navigator.of(context, rootNavigator: true).pop();

  if (token != null) {
    // Pengguna berhasil memilih dan mengonfirmasi akun Google asli
    final berhasil = await authProvider.masukDenganGoogle(idToken: token);
    if (!context.mounted) return;

    if (berhasil) {
      final nama = authProvider.currentUser?.nama ?? 'Pengguna Google';
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Selamat datang, $nama! Berhasil masuk dengan Akun Google resmi.'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
      return;
    } else {
      final pesan = authProvider.errorMessage ??
          'Verifikasi token Akun Google ke server Librava gagal.';
      messenger.showSnackBar(
        SnackBar(
          content: Text(pesan),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
  }

  // Jika token null dan ada error dari Google SDK (misal domain localhost belum di-whitelist di GCP)
  if (googleError != null && context.mounted) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Image.asset('assets/images/google_logo.png', width: 22, height: 22),
            const SizedBox(width: 10),
            const Text(
              'Google Sign-In Asli',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status respons dari Google Identity Services:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                '$googleError',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF334155),
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Catatan: Jika origin browser Anda belum didaftarkan di Google Cloud Console Client ID, Anda dapat mencoba lagi atau masuk memakai Akun Pengujian Mahasiswa.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.35),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              handleRealGoogleSignIn(context); // Coba lagi
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4285F4),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Coba Lagi'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok =
                  await authProvider.masukDenganGoogle(idToken: 'demo_google_token');
              if (!context.mounted) return;
              if (ok) {
                final nama = authProvider.currentUser?.nama ?? 'Gilang Ramadan';
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Selamat datang, $nama! (Akun Pengujian)'),
                    backgroundColor: const Color(0xFF16A34A),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Gunakan Akun Pengujian',
              style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
