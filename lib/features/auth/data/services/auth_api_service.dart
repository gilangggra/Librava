import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_constants.dart';
import '../../domain/models/user_model.dart';

class AuthResponse {
  final UserModel user;
  final String token;

  const AuthResponse({
    required this.user,
    required this.token,
  });
}

class AuthApiService {
  final http.Client _client;

  AuthApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.authLogin}');
    final response = await _client
        .post(
          url,
          headers: ApiConstants.headers(),
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 8));

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = responseData['data'] as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;
      return AuthResponse(user: user, token: token);
    } else {
      final errorMessage =
          responseData['message'] ?? 'Login gagal (${response.statusCode})';
      throw Exception(errorMessage);
    }
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String namaLengkap,
    String? nim,
    String? universitas,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.authRegister}');
    final Map<String, dynamic> registerData = {
      'email': email,
      'password': password,
      'nama_lengkap': namaLengkap,
    };
    if (nim != null && nim.isNotEmpty) {
      registerData['nim'] = nim;
    }
    if (universitas != null && universitas.isNotEmpty) {
      registerData['universitas'] = universitas;
    }

    final response = await _client
        .post(
          url,
          headers: ApiConstants.headers(),
          body: jsonEncode(registerData),
        )
        .timeout(const Duration(seconds: 8));

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = responseData['data'] as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;
      return AuthResponse(user: user, token: token);
    } else {
      final errorMessage =
          responseData['message'] ?? 'Registrasi gagal (${response.statusCode})';
      throw Exception(errorMessage);
    }
  }

  Future<UserModel> getProfile(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.authProfile}');
    final response = await _client
        .get(
          url,
          headers: ApiConstants.headers(token),
        )
        .timeout(const Duration(seconds: 8));

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = responseData['data'] as Map<String, dynamic>;
      return UserModel.fromJson(data['user'] ?? data);
    } else {
      final errorMessage =
          responseData['message'] ?? 'Gagal memuat profil (${response.statusCode})';
      throw Exception(errorMessage);
    }
  }

  Future<UserModel> updateProfile({
    required String token,
    String? namaLengkap,
    String? nim,
    String? universitas,
    String? fotoProfil,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.authProfile}');
    final Map<String, dynamic> updateData = {};
    if (namaLengkap != null && namaLengkap.isNotEmpty) {
      updateData['nama_lengkap'] = namaLengkap;
    }
    if (nim != null && nim.isNotEmpty) {
      updateData['nim'] = nim;
    }
    if (universitas != null && universitas.isNotEmpty) {
      updateData['universitas'] = universitas;
    }
    if (fotoProfil != null && fotoProfil.isNotEmpty) {
      updateData['foto_profil'] = fotoProfil;
    }

    final response = await _client
        .put(
          url,
          headers: ApiConstants.headers(token),
          body: jsonEncode(updateData),
        )
        .timeout(const Duration(seconds: 8));

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = responseData['data'] as Map<String, dynamic>;
      return UserModel.fromJson(data['user'] ?? data);
    } else {
      final errorMessage =
          responseData['message'] ?? 'Gagal update profil (${response.statusCode})';
      throw Exception(errorMessage);
    }
  }
}
