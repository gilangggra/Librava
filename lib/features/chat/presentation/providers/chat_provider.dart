import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/services/chat_api_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatApiService _apiService;
  Timer? _pollingTimer;

  int _totalUnread = 0;
  Map<String, int> _unreadMap = {};
  Map<String, ({String text, String sentAt, String? senderNama})> _latestMessages = {};
  bool _isLoading = false;

  ChatProvider({ChatApiService? apiService})
      : _apiService = apiService ?? ChatApiService();

  int get totalUnread => _totalUnread;
  Map<String, int> get unreadMap => Map.unmodifiable(_unreadMap);
  bool get isLoading => _isLoading;

  int unreadFor(String transactionId) => _unreadMap[transactionId] ?? 0;

  ({String text, String sentAt, String? senderNama})? latestMessageFor(
          String transactionId) =>
      _latestMessages[transactionId];

  Future<void> fetchSummary(String token) async {
    _isLoading = true;
    try {
      final summary = await _apiService.getConversationsSummary(token: token);
      _totalUnread = summary.totalUnread;
      _unreadMap = summary.unreadMap;
      _latestMessages = summary.latestMessages;
      notifyListeners();
    } catch (_) {
    } finally {
      _isLoading = false;
    }
  }

  void startPolling(String token, {Duration interval = const Duration(seconds: 5)}) {
    _pollingTimer?.cancel();
    fetchSummary(token);
    _pollingTimer = Timer.periodic(interval, (_) {
      fetchSummary(token);
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void markAsRead(String transactionId) {
    if (_unreadMap.containsKey(transactionId)) {
      final count = _unreadMap[transactionId] ?? 0;
      _totalUnread = (_totalUnread - count).clamp(0, 9999);
      _unreadMap[transactionId] = 0;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
