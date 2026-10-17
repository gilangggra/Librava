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

  Future<
      ({
        int totalUnread,
        Map<String, int> unreadMap,
        Map<String, ({String text, String sentAt, String? senderNama})> latestMessages
      })> getConversationsSummary({
    required String token,
  }) async {
    try {
      final uri =
          Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chats}/summary');

      final response = await _client
          .get(uri, headers: ApiConstants.headers(token))
          .timeout(const Duration(seconds: 10));

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = responseData['data'] as Map<String, dynamic>? ?? {};
        final totalUnread = (data['totalUnread'] as num?)?.toInt() ?? 0;
        final rawUnreadMap = data['unreadMap'] as Map<String, dynamic>? ?? {};
        final unreadMap =
            rawUnreadMap.map((k, v) => MapEntry(k, (v as num).toInt()));

        final rawLatest =
            data['latestMessages'] as Map<String, dynamic>? ?? {};
        final latestMessages = rawLatest.map((k, v) {
          final val = v as Map<String, dynamic>;
          return MapEntry(
            k,
            (
              text: val['pesan'] as String? ?? '',
              sentAt: val['sent_at']?.toString() ?? '',
              senderNama: val['sender_nama'] as String?,
            ),
          );
        });

        return (
          totalUnread: totalUnread,
          unreadMap: unreadMap,
          latestMessages: latestMessages,
        );
      }
    } catch (_) {}
    return (
      totalUnread: 0,
      unreadMap: <String, int>{},
      latestMessages: <String, ({String text, String sentAt, String? senderNama})>{},
    );
  }
}
