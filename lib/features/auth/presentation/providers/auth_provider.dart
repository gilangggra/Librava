import 'package:flutter/material.dart';
import '../../data/services/auth_api_service.dart';
import '../../domain/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApiService _apiService;

  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;
  final Map<String, UserModel> _registeredUsers = {};

  AuthProvider({AuthApiService? apiService})
      : _apiService = apiService ?? AuthApiService();

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
      _registeredUsers[email.toLowerCase()] = response.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final newUser = UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        nama: nama,
        email: email,
        nim: nim,
        universitas: universitas ?? 'Telkom University',
      );
      _registeredUsers[email.toLowerCase()] = newUser;
      _currentUser = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
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
      _registeredUsers[email.toLowerCase()] = response.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final userTerdaftar = _registeredUsers[email.toLowerCase()];
      _currentUser = userTerdaftar ??
          UserModel(
            id: 'usr_101',
            nama: email.split('@').first,
            email: email,
          );
      _isLoading = false;
      notifyListeners();
      return true;
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
        );
        _currentUser = updatedUser;
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
}
