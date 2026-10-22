import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_constants.dart';
import '../../domain/models/admin_book_model.dart';
import '../../domain/models/admin_dashboard_model.dart';
import '../../domain/models/admin_transaction_model.dart';
import '../../domain/models/admin_user_model.dart';

class AdminApiService {
  final http.Client _client;
  String? _cachedAdminToken;

  AdminApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Mengambil token admin yang valid. Jika token null/kosong (misal saat browser refresh),
  /// sistem otomatis login dengan akun default admin ke backend Railway.
  Future<String?> getValidAdminToken([String? token]) async {
    if (token != null && token.isNotEmpty) {
      _cachedAdminToken = token;
      return token;
    }
    if (_cachedAdminToken != null && _cachedAdminToken!.isNotEmpty) {
      return _cachedAdminToken;
    }
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.authLogin}'),
            headers: ApiConstants.headers(),
            body: jsonEncode({
              'email': 'admin@librava.com',
              'password': 'password123456',
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final obtained = body['data']?['token'] as String?;
        if (obtained != null && obtained.isNotEmpty) {
          _cachedAdminToken = obtained;
          return obtained;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<AdminDashboardModel> getDashboard({String? token}) async {
    final activeToken = await getValidAdminToken(token);
    final response = await _client
        .get(
          Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminDashboard}'),
          headers: ApiConstants.headers(activeToken),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true && body['data'] != null) {
        return AdminDashboardModel.fromApiJson(body['data']);
      }
    }
    throw Exception('Gagal mengambil data dashboard (${response.statusCode})');
  }

  Future<List<AdminUserModel>> getUsers({String? token}) async {
    final activeToken = await getValidAdminToken(token);
    final response = await _client
        .get(
          Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminUsers}'),
          headers: ApiConstants.headers(activeToken),
        )
        .timeout(const Duration(seconds: 8));

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      final List<dynamic> data = body['data'] as List<dynamic>? ?? [];
      return data
          .map((item) => AdminUserModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception(
      body['message'] ?? 'Gagal mengambil data mahasiswa (${response.statusCode})',
    );
  }

  Future<List<AdminBookModel>> getBooks({String? token}) async {
    final activeToken = await getValidAdminToken(token);
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.books}')
        .replace(queryParameters: {'limit': '100', 'offset': '0'});

    final response = await _client
        .get(uri, headers: ApiConstants.headers(activeToken))
        .timeout(const Duration(seconds: 8));

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] != false) {
      final List<dynamic> data = body['data'] as List<dynamic>? ?? [];
      return data
          .map((item) => AdminBookModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception(
      body['message'] ?? 'Gagal mengambil data buku (${response.statusCode})',
    );
  }

  Future<List<AdminTransactionModel>> getTransactions({String? token}) async {
    final activeToken = await getValidAdminToken(token);
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminTransactions}');

    final response = await _client
        .get(uri, headers: ApiConstants.headers(activeToken))
        .timeout(const Duration(seconds: 8));

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] != false) {
      final List<dynamic> data = body['data'] as List<dynamic>? ?? [];
      return data
          .map((item) => AdminTransactionModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception(
      body['message'] ?? 'Gagal mengambil data transaksi (${response.statusCode})',
    );
  }

  Future<List<AdminBookModel>> getPendingBooks({String? token}) async {
    final activeToken = await getValidAdminToken(token);
    final uri =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminPendingBooks}');

    final response = await _client
        .get(uri, headers: ApiConstants.headers(activeToken))
        .timeout(const Duration(seconds: 8));

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] != false) {
      final List<dynamic> data = body['data'] as List<dynamic>? ?? [];
      return data
          .map((item) => AdminBookModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception(
      body['message'] ??
          'Gagal mengambil antrean moderasi buku (${response.statusCode})',
    );
  }

  Future<AdminBookModel> moderateBook({
    String? token,
    required String bookId,
    required String action,
    String? catatan,
  }) async {
    final activeToken = await getValidAdminToken(token);
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.adminModerateBook(bookId)}');

    final payload = <String, dynamic>{
      'action': action,
    };
    if (catatan != null && catatan.trim().isNotEmpty) {
      payload['catatan'] = catatan.trim();
    }

    final response = await _client
        .patch(
          uri,
          headers: ApiConstants.headers(activeToken),
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 8));

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] != false) {
      return AdminBookModel.fromJson(body['data'] as Map<String, dynamic>);
    }

    throw Exception(
      body['message'] ??
          'Failed to update book moderation (${response.statusCode})',
    );
  }
}
