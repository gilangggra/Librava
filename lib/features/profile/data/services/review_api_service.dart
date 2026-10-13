import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_constants.dart';
import '../../domain/models/user_review_model.dart';

class ReviewApiService {
  final http.Client _client;

  ReviewApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Mengambil daftar ulasan dan rating rata-rata dari seorang pengguna (GET /api/reviews/user/:userId)
  Future<UserReviewsData> getUserReviews(int userId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.reviews}/user/$userId');

    final response = await _client
        .get(uri, headers: ApiConstants.headers())
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = responseData['data'] as Map<String, dynamic>? ?? {};
      return UserReviewsData.fromJson(data);
    } else {
      final msg = responseData['message'] ?? 'Gagal memuat ulasan pengguna (${response.statusCode})';
      throw Exception(msg);
    }
  }

  /// Mengirimkan rating & review ke rekan transaksi (POST /api/reviews)
  Future<bool> submitTransactionReview({
    required String token,
    required int transactionId,
    required int rating,
    String? komentar,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.reviews}');

    final body = {
      'transaction_id': transactionId,
      'rating': rating,
      if (komentar != null && komentar.isNotEmpty) 'komentar': komentar,
    };

    final response = await _client
        .post(
          uri,
          headers: ApiConstants.headers(token),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      final msg = responseData['message'] ?? 'Gagal mengirim ulasan (${response.statusCode})';
      throw Exception(msg);
    }
  }
}
