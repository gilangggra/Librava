import 'package:flutter/material.dart';
import '../../domain/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<bool> daftar({
    required String nama,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      nama: nama,
      email: email,
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> masuk({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _currentUser = UserModel(
      id: 'usr_101',
      nama: email.split('@').first,
      email: email,
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void keluar() {
    _currentUser = null;
    notifyListeners();
  }
}
