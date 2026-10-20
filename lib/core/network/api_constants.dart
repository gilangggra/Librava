import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String productionUrl =
      'https://librava-production-d1b8.up.railway.app/api';
  static const String defaultLocalUrl = 'http://localhost:5000/api';
  static const String defaultAndroidEmulatorUrl = 'http://10.0.2.2:5000/api';

  /// Saklar mode: jika true, aplikasi Flutter terhubung langsung ke backend Railway Cloud
  static const bool useProduction = true;

  /// Base URL aktif (mendukung override via --dart-define=API_BASE_URL=...)
  static String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: useProduction
        ? productionUrl
        : (kIsWeb ? defaultLocalUrl : defaultAndroidEmulatorUrl),
  );

  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authProfile = '/auth/profile';
  static const String authGoogle = '/auth/google';
  static const String books = '/books';
  static const String myBooks = '/books/user/my-books';
  static const String events = '/events';
  static const String myEvents = '/events/user/my-events';
  static const String transactions = '/transactions';
  static const String chats = '/chats';
  static const String reviews = '/reviews';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminTransactions = '/admin/transactions';
  static const String adminPendingBooks = '/admin/books/pending';

  static String bookReviews(dynamic bookId) => '/books/$bookId/reviews';
  static String eventRegister(dynamic eventId) => '/events/$eventId/register';
  static String adminModerateBook(dynamic bookId) =>
      '/admin/books/$bookId/moderasi';

  static Map<String, String> headers([String? token]) {
    final Map<String, String> headerMap = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headerMap['Authorization'] = 'Bearer $token';
    }
    return headerMap;
  }
}
