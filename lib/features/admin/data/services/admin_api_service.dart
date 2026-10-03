import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_constants.dart';
import '../../domain/models/admin_book_model.dart';
import '../../domain/models/admin_dashboard_model.dart';
import '../../domain/models/admin_transaction_model.dart';
import '../../domain/models/admin_user_model.dart';

class AdminApiService {
  final http.Client _client;

  AdminApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<AdminDashboardModel> getDashboard({required String token}) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminDashboard}'),
            headers: ApiConstants.headers(token),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return AdminDashboardModel.fromApiJson(body['data']);
        }
      }
      return _getDefaultDashboard();
    } catch (_) {
      return _getDefaultDashboard();
    }
  }

  Future<List<AdminUserModel>> getUsers({required String token}) async {
    final response = await _client
        .get(
          Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminUsers}'),
          headers: ApiConstants.headers(token),
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

  Future<List<AdminBookModel>> getBooks({required String token}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.books}')
        .replace(queryParameters: {'limit': '100', 'offset': '0'});

    final response = await _client
        .get(uri, headers: ApiConstants.headers(token))
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

  Future<List<AdminTransactionModel>> getTransactions({required String token}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminTransactions}');

    final response = await _client
        .get(uri, headers: ApiConstants.headers(token))
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

  AdminDashboardModel _getDefaultDashboard() {
    return const AdminDashboardModel(
      totalStudents: 320,
      totalBooks: 1245,
      totalRequests: 86,
      totalTransactions: 62,
      recentActivity: [
        AdminActivityItem(
          id: 'act_1',
          title: 'The Unknown',
          author: 'Riley Sager',
          coverPath: 'assets/images/book_the_unknown.jpg',
          type: 'Barter',
          personName: 'Andi',
          status: 'Pending',
        ),
        AdminActivityItem(
          id: 'act_2',
          title: 'Fruit Fly',
          author: 'Kaiju Shirai',
          coverPath: 'assets/images/book_fruit_fly.jpg',
          type: 'Borrow',
          personName: 'Sarah',
          status: 'Accepted',
        ),
      ],
      recentTransactions: [
        AdminTransactionItem(
          id: 'trx_1',
          title: 'The Unknown',
          author: 'Riley Sager',
          coverPath: 'assets/images/book_the_unknown.jpg',
          type: 'Barter',
          personName: 'Andi',
          status: 'Incompleted',
        ),
        AdminTransactionItem(
          id: 'trx_2',
          title: 'Fruit Fly',
          author: 'Kaiju Shirai',
          coverPath: 'assets/images/book_fruit_fly.jpg',
          type: 'Borrow',
          personName: 'Sarah',
          status: 'Completed',
        ),
      ],
    );
  }
}
