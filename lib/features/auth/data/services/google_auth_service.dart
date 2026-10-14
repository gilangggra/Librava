import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static const String webClientId =
      '383070989283-h09vqtv7il9s1j4l66bnn7uhtsqj087c.apps.googleusercontent.com';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? webClientId : null,
    scopes: const <String>[
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  /// Membuka popup autentikasi Akun Google ASLI (Google Official Sign-In)
  /// Mengembalikan real ID Token atau Access Token dari server Google
  static Future<String?> signInWithRealGoogle() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (_) {}

    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    if (account == null) {
      // Pengguna membatalkan / menutup popup Google
      return null;
    }

    final GoogleSignInAuthentication auth = await account.authentication;
    final token = auth.idToken ?? auth.accessToken;
    return token;
  }
}
