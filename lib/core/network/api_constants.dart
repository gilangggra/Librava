import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String defaultLocalUrl = 'http://localhost:5000/api';
  static const String defaultAndroidEmulatorUrl = 'http://10.0.2.2:5000/api';

  static String baseUrl =
      kIsWeb ? defaultLocalUrl : defaultAndroidEmulatorUrl;

  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authProfile = '/auth/profile';
  static const String books = '/books';
  static const String myBooks = '/books/user/my-books';
  static const String transactions = '/transactions';
  static const String chats = '/chats';
  static const String reviews = '/reviews';

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
