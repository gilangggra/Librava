import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_constants.dart';
import '../../domain/models/chat_message_model.dart';

class ChatApiService {
  final http.Client _client;

  ChatApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<ChatMessageModel>> getMessages({
    required String token,
    required int transactionId,
  }) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.chats}/$transactionId');

    final response = await _client
        .get(uri, headers: ApiConstants.headers(token))
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final rawList = responseData['data'] as List<dynamic>? ?? [];
      return rawList
          .map((m) => ChatMessageModel.fromJson(m as Map<String, dynamic>))
          .toList();
    } else {
      final errorMessage = responseData['message'] ??
          'Gagal mengambil pesan (${response.statusCode})';
      throw Exception(errorMessage);
    }
  }

  Future<ChatMessageModel> sendMessage({
    required String token,
    required int transactionId,
    required String pesan,
  }) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.chats}/$transactionId');

    final response = await _client
        .post(
          uri,
          headers: ApiConstants.headers(token),
          body: jsonEncode({'pesan': pesan}),
        )
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ChatMessageModel.fromJson(
          responseData['data'] as Map<String, dynamic>);
    } else {
      final errorMessage = responseData['message'] ??
          'Gagal mengirim pesan (${response.statusCode})';
      throw Exception(errorMessage);
    }
  }
}
