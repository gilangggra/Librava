import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_constants.dart';
import '../../domain/models/book_model.dart';

class BookListResult {
  final List<BookModel> books;
  final int total;

  const BookListResult({required this.books, required this.total});
}

class BookApiService {
  final http.Client _client;

  BookApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<BookListResult> getBooks({
    String? search,
    String? kategori,
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (kategori != null && kategori != 'Semua' && kategori.isNotEmpty) {
      queryParams['kategori'] = kategori;
    }
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.books}')
        .replace(queryParameters: queryParams);

    final response = await _client
        .get(uri, headers: ApiConstants.headers())
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final rawBooks = responseData['data'] as List<dynamic>? ?? [];
      final books = rawBooks
          .map((b) => BookModel.fromApiJson(b as Map<String, dynamic>))
          .toList();
      final meta = responseData['meta'] as Map<String, dynamic>? ?? {};
      final total = (meta['total'] as num?)?.toInt() ?? books.length;
      return BookListResult(books: books, total: total);
    } else {
      final errorMessage =
          responseData['message'] ?? 'Gagal memuat buku (${response.statusCode})';
      throw Exception(errorMessage);
    }
  }

  Future<BookModel> getBookById(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.books}/$id');
    final response = await _client
        .get(uri, headers: ApiConstants.headers())
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return BookModel.fromApiJson(responseData['data'] as Map<String, dynamic>);
    } else {
      final errorMessage =
          responseData['message'] ?? 'Gagal memuat detail buku (${response.statusCode})';
      throw Exception(errorMessage);
    }
  }

  Future<BookListResult> getMyBooks(String token) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.myBooks}');
    final response = await _client
        .get(uri, headers: ApiConstants.headers(token))
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final rawBooks = responseData['data'] as List<dynamic>? ?? [];
      final books = rawBooks
          .map((b) => BookModel.fromApiJson(b as Map<String, dynamic>))
          .toList();
      final meta = responseData['meta'] as Map<String, dynamic>? ?? {};
      final total = (meta['total'] as num?)?.toInt() ?? books.length;
      return BookListResult(books: books, total: total);
    } else {
      final errorMessage =
          responseData['message'] ?? 'Gagal memuat buku saya (${response.statusCode})';
      throw Exception(errorMessage);
    }
  }

  Future<BookModel> createBook({
    required String token,
    required String judul,
    required String penulis,
    String? penerbit,
    String? isbn,
    String? deskripsi,
    String? kategori,
    String? fotoBuku,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.books}');
    final body = <String, dynamic>{
      'judul': judul,
      'penulis': penulis,
    };
    if (penerbit != null && penerbit.isNotEmpty) body['penerbit'] = penerbit;
    if (isbn != null && isbn.isNotEmpty) body['isbn'] = isbn;
    if (deskripsi != null && deskripsi.isNotEmpty) body['deskripsi'] = deskripsi;
    if (kategori != null && kategori.isNotEmpty) body['kategori'] = kategori;
    if (fotoBuku != null && fotoBuku.isNotEmpty) body['foto_buku'] = fotoBuku;

    final response = await _client
        .post(
          uri,
          headers: ApiConstants.headers(token),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return BookModel.fromApiJson(responseData['data'] as Map<String, dynamic>);
    } else {
      final errorMessage =
          responseData['message'] ?? 'Gagal menambahkan buku (${response.statusCode})';
      throw Exception(errorMessage);
    }
  }

  Future<BookModel> updateBook({
    required String token,
    required int bookId,
    String? judul,
    String? penulis,
    String? penerbit,
    String? deskripsi,
    String? kategori,
    String? status,
    String? fotoBuku,
  }) async {
    final uri =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.books}/$bookId');
    final body = <String, dynamic>{};
    if (judul != null && judul.isNotEmpty) body['judul'] = judul;
    if (penulis != null && penulis.isNotEmpty) body['penulis'] = penulis;
    if (penerbit != null && penerbit.isNotEmpty) body['penerbit'] = penerbit;
    if (deskripsi != null && deskripsi.isNotEmpty) body['deskripsi'] = deskripsi;
    if (kategori != null && kategori.isNotEmpty) body['kategori'] = kategori;
    if (status != null && status.isNotEmpty) body['status'] = status;
    if (fotoBuku != null && fotoBuku.isNotEmpty) body['foto_buku'] = fotoBuku;

    final response = await _client
        .put(
          uri,
          headers: ApiConstants.headers(token),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return BookModel.fromApiJson(responseData['data'] as Map<String, dynamic>);
    } else {
      final errorMessage =
          responseData['message'] ?? 'Gagal memperbarui buku (${response.statusCode})';
      throw Exception(errorMessage);
    }
  }

  Future<void> deleteBook({required String token, required int bookId}) async {
    final uri =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.books}/$bookId');
    final response = await _client
        .delete(uri, headers: ApiConstants.headers(token))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final errorMessage =
          responseData['message'] ?? 'Gagal menghapus buku (${response.statusCode})';
      throw Exception(errorMessage);
    }
  }
}
