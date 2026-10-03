import 'package:flutter/material.dart';
import '../../data/services/auth_api_service.dart';
import '../../domain/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApiService _apiService;

  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthApiService? apiService})
      : _apiService = apiService ?? AuthApiService();

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String _ambilPesanError(Object error, String pesanDefault) {
    final teks = error.toString();
    if (teks.startsWith('Exception: ')) {
      final pesanServer = teks.replaceFirst('Exception: ', '').trim();
      if (pesanServer.isNotEmpty) {
        return pesanServer;
      }
      return pesanDefault;
    }
    return 'Tidak dapat terhubung ke server. Coba lagi nanti.';
  }

  Future<bool> daftar({
    required String nama,
    required String email,
    required String password,
    String? nim,
    String? universitas,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.register(
        email: email,
        password: password,
        namaLengkap: nama,
        nim: nim,
        universitas: universitas,
      );
      _currentUser = response.user;
      _token = response.token;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _ambilPesanError(e, 'Registrasi gagal. Silakan coba lagi.');
      _currentUser = null;
      _token = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> masuk({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );
      _currentUser = response.user;
      _token = response.token;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final pesan = e.toString().toLowerCase();
      if (pesan.contains('email atau password salah')) {
        _errorMessage = 'Email atau kata sandi salah. Silakan periksa kembali.';
      } else {
        _errorMessage = _ambilPesanError(e, 'Login gagal. Silakan coba lagi.');
      }
      _currentUser = null;
      _token = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String passwordBaru,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> updateProfil({
    String? nama,
    String? email,
    String? username,
    String? bio,
    String? phone,
    String? universitas,
    String? nim,
    String? fotoProfil,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (_token != null && _token!.isNotEmpty) {
      try {
        final updatedUser = await _apiService.updateProfile(
          token: _token!,
          namaLengkap: nama,
          universitas: universitas,
          nim: nim,
          fotoProfil: fotoProfil,
          username: username,
          bio: bio,
          phone: phone,
        );
        _currentUser = updatedUser.copyWith(
          email: email,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 500));

    _currentUser = _currentUser!.copyWith(
      nama: (nama != null && nama.trim().isNotEmpty)
          ? nama.trim()
          : _currentUser!.nama,
      email: (email != null && email.trim().isNotEmpty)
          ? email.trim()
          : _currentUser!.email,
      username: (username != null && username.trim().isNotEmpty)
          ? username.trim()
          : _currentUser!.username,
      bio: (bio != null && bio.trim().isNotEmpty)
          ? bio.trim()
          : _currentUser!.bio,
      phone: (phone != null && phone.trim().isNotEmpty)
          ? phone.trim()
          : _currentUser!.phone,
      universitas: (universitas != null && universitas.trim().isNotEmpty)
          ? universitas.trim()
          : _currentUser!.universitas,
      nim: (nim != null && nim.trim().isNotEmpty)
          ? nim.trim()
          : _currentUser!.nim,
      fotoProfil: (fotoProfil != null && fotoProfil.trim().isNotEmpty)
          ? fotoProfil.trim()
          : _currentUser!.fotoProfil,
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void keluar() {
    _currentUser = null;
    _token = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> segarkanProfil() async {
    if (_token != null && _token!.isNotEmpty) {
      try {
        final profile = await _apiService.getProfile(_token!);
        _currentUser = profile;
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<UserModel?> ambilProfilPenggunaLain(String userId) async {
    try {
      return await _apiService.getUserProfileById(userId, token: _token);
    } catch (_) {
      return null;
    }
  }
}
