import 'dart:convert';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';
import '../../../../core/network/api_constants.dart';
import '../../domain/models/event_model.dart';

class EventApiService {
  final http.Client _client;

  EventApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Mengambil daftar event aktif dari Backend
  Future<List<EventModel>> getEvents({
    String? search,
    String? kategori,
  }) async {
    final queryParams = <String, String>{};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (kategori != null && kategori != 'Semua' && kategori.trim().isNotEmpty) {
      queryParams['kategori'] = kategori.trim();
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.events}')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await _client
        .get(uri, headers: ApiConstants.headers())
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        body['success'] == true) {
      final List<dynamic> data = body['data'] as List<dynamic>? ?? [];
      return data
          .map((item) => EventModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception(
      body['message'] ?? 'Gagal mengambil daftar event (${response.statusCode})',
    );
  }

  /// Mengambil detail satu event berdasarkan ID
  Future<EventModel> getEventById(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.events}/$id');

    final response = await _client
        .get(uri, headers: ApiConstants.headers())
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        body['success'] == true) {
      return EventModel.fromJson(body['data'] as Map<String, dynamic>);
    }

    throw Exception(
      body['message'] ?? 'Gagal mengambil detail event (${response.statusCode})',
    );
  }

  /// Mendaftarkan mahasiswa ke event
  Future<bool> registerEvent({
    required String token,
    required int eventId,
  }) async {
    final uri =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.eventRegister(eventId)}');

    final response = await _client
        .post(
          uri,
          headers: ApiConstants.headers(token),
        )
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 201 ||
        (response.statusCode == 200 && body['success'] == true)) {
      return true;
    }

    // Mengambil pesan error dari backend (misal: "Kuota event sudah penuh")
    throw Exception(
      body['message'] ?? 'Gagal mendaftar event (${response.statusCode})',
    );
  }

  /// Menambahkan event baru ke backend database
  Future<EventModel> createEvent({
    required String token,
    required String judul,
    required String deskripsi,
    String? kategori,
    required String lokasi,
    required DateTime tanggalMulai,
    DateTime? tanggalSelesai,
    int kuota = 100,
    String? fotoEvent,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.events}');

    final response = await _client
        .post(
          uri,
          headers: ApiConstants.headers(token),
          body: jsonEncode({
            'judul': judul,
            'deskripsi': deskripsi,
            'kategori': kategori ?? 'Komunitas',
            'lokasi': lokasi,
            'tanggal_mulai': tanggalMulai.toIso8601String(),
            if (tanggalSelesai != null)
              'tanggal_selesai': tanggalSelesai.toIso8601String(),
            'kuota': kuota,
            if (fotoEvent != null && fotoEvent.isNotEmpty)
              'foto_event': fotoEvent,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        body['success'] == true) {
      return EventModel.fromJson(body['data'] as Map<String, dynamic>);
    }

    throw Exception(
      body['message'] ?? 'Gagal membuat event (${response.statusCode})',
    );
  }

  /// Mengunggah gambar/banner event ke backend (POST /api/upload/image)
  Future<String> uploadBannerImage({
    required String token,
    required List<int> bytes,
    required String filename,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/upload/image');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    final ext = filename.toLowerCase().split('.').last;
    final subType = (ext == 'png' || ext == 'webp') ? ext : 'jpeg';

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: filename,
        contentType: MediaType('image', subType),
      ),
    );

    final streamedResponse =
        await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);
    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        body['success'] == true &&
        body['data'] != null) {
      return (body['data']['url'] ?? body['data']['path']) as String;
    }

    throw Exception(
      body['message'] ?? 'Gagal mengunggah banner event (${response.statusCode})',
    );
  }
}

