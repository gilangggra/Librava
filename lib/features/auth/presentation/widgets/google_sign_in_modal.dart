import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/google_auth_service.dart';
import '../providers/auth_provider.dart';
import '../../../home/presentation/screens/home_page.dart';

bool _isGoogleSigningIn = false;

/// Membuka alur autentikasi Akun Google langsung tanpa modal dialog perantara
Future<void> showGoogleSignInConfirmationModal(BuildContext context) {
  return handleRealGoogleSignIn(context);
}

/// Menangani autentikasi Akun Google Asli secara langsung dengan Google Identity Services
Future<void> handleRealGoogleSignIn(BuildContext context) async {
  if (_isGoogleSigningIn) return;
  _isGoogleSigningIn = true;

  try {
    final authProvider = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    String? token;
    dynamic googleError;

    try {
      token = await GoogleAuthService.signInWithRealGoogle();
    } catch (e) {
      googleError = e;
    }

    if (!context.mounted) return;

    if (token != null) {
      // Pengguna berhasil memilih dan mengonfirmasi akun Google asli
      final berhasil = await authProvider.masukDenganGoogle(idToken: token);
      if (!context.mounted) return;

      if (berhasil) {
        final nama = authProvider.currentUser?.nama ?? 'Google User';
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Welcome, $nama! Successfully signed in with Google.'),
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
            'Failed to verify Google token with Librava server.';
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

    // Jika terjadi error teknis selain pembatalan pengguna
    if (googleError != null && context.mounted) {
      final errStr = googleError.toString().toLowerCase();
      // Abaikan jika user hanya menutup atau membatalkan popup
      if (errStr.contains('popup_closed') ||
          errStr.contains('cancel') ||
          errStr.contains('closed') ||
          errStr.contains('abort') ||
          errStr.contains('dismissed')) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to connect to Google: $googleError'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } finally {
    _isGoogleSigningIn = false;
  }
}
