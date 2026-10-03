import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_constants.dart';
import '../../domain/models/transaction_model.dart';

class TransactionApiService {
  final http.Client _client;

  TransactionApiService({http.Client? client})
      : _client = client ?? http.Client();

  Future<List<TransactionModel>> getTransactions({
    required String token,
    String? role,
    String? status,
  }) async {
    final queryParams = <String, String>{};
    if (role != null && role.isNotEmpty) queryParams['role'] = role;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final uri =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.transactions}')
            .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await _client
        .get(uri, headers: ApiConstants.headers(token))
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final rawList = responseData['data'] as List<dynamic>? ?? [];
      return rawList
          .map((t) => TransactionModel.fromApiJson(t as Map<String, dynamic>))
          .toList();
    } else {
      final errorMessage = responseData['message'] ??
          'Gagal memuat transaksi (${response.statusCode})';
      throw Exception(errorMessage);
    }
  }

  Future<TransactionModel> getTransactionById({
    required String token,
    required int id,
  }) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.transactions}/$id');

    final response = await _client
        .get(uri, headers: ApiConstants.headers(token))
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return TransactionModel.fromApiJson(
          responseData['data'] as Map<String, dynamic>);
    } else {
      final errorMessage = responseData['message'] ??
          'Gagal memuat detail transaksi (${response.statusCode})';
      throw Exception(errorMessage);
    }
  }

  Future<TransactionModel> createTransaction({
    required String token,
    required int bookId,
    required String tipeTransaksi,
    int? barterBookId,
    double depositDummy = 0,
    String? lokasiPertemuan,
    String? waktuPertemuan,
  }) async {
    final uri =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.transactions}');

    final body = <String, dynamic>{
      'book_id': bookId,
      'tipe_transaksi': tipeTransaksi,
      'deposit_dummy': depositDummy,
    };
    if (barterBookId != null) body['barter_book_id'] = barterBookId;
    if (lokasiPertemuan != null && lokasiPertemuan.isNotEmpty) {
      body['lokasi_pertemuan'] = lokasiPertemuan;
    }
    if (waktuPertemuan != null && waktuPertemuan.isNotEmpty) {
      body['waktu_pertemuan'] = waktuPertemuan;
    }

    final response = await _client
        .post(
          uri,
          headers: ApiConstants.headers(token),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return TransactionModel.fromApiJson(
          responseData['data'] as Map<String, dynamic>);
    } else {
      final errorMessage = responseData['message'] ??
          'Gagal membuat transaksi (${response.statusCode})';
      throw Exception(errorMessage);
    }
  }

  Future<TransactionModel> updateStatus({
    required String token,
    required int id,
    required String status,
  }) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.transactions}/$id/status');

    final response = await _client
        .put(
          uri,
          headers: ApiConstants.headers(token),
          body: jsonEncode({'status': status}),
        )
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return TransactionModel.fromApiJson(
          responseData['data'] as Map<String, dynamic>);
    } else {
      final errorMessage = responseData['message'] ??
          'Gagal memperbarui status (${response.statusCode})';
      throw Exception(errorMessage);
    }
  }

  Future<TransactionModel> setMeeting({
    required String token,
    required int id,
    required String lokasiPertemuan,
    String? waktuPertemuan,
  }) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.transactions}/$id/meeting');

    final body = <String, dynamic>{'lokasi_pertemuan': lokasiPertemuan};
    if (waktuPertemuan != null && waktuPertemuan.isNotEmpty) {
      body['waktu_pertemuan'] = waktuPertemuan;
    }

    final response = await _client
        .put(
          uri,
          headers: ApiConstants.headers(token),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return TransactionModel.fromApiJson(
          responseData['data'] as Map<String, dynamic>);
    } else {
      final errorMessage = responseData['message'] ??
          'Gagal menentukan lokasi (${response.statusCode})';
      throw Exception(errorMessage);
    }
  }

  Future<TransactionModel> confirmHandover({
    required String token,
    required int id,
  }) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.transactions}/$id/handover');

    final response = await _client
        .put(uri, headers: ApiConstants.headers(token))
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return TransactionModel.fromApiJson(
          responseData['data'] as Map<String, dynamic>);
    } else {
      final errorMessage = responseData['message'] ??
          'Gagal konfirmasi serah terima (${response.statusCode})';
      throw Exception(errorMessage);
    }
  }

  Future<TransactionModel> confirmReturn({
    required String token,
    required int id,
  }) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.transactions}/$id/return');

    final response = await _client
        .put(uri, headers: ApiConstants.headers(token))
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return TransactionModel.fromApiJson(
          responseData['data'] as Map<String, dynamic>);
    } else {
      final errorMessage = responseData['message'] ??
          'Gagal konfirmasi pengembalian (${response.statusCode})';
      throw Exception(errorMessage);
    }
  }
}
