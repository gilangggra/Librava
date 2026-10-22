import 'package:flutter/material.dart';
import '../../data/services/event_api_service.dart';
import '../../domain/models/event_model.dart';

class EventProvider extends ChangeNotifier {
  final EventApiService _apiService;

  List<EventModel> _events = [];
  List<EventModel> _myEvents = [];
  final Set<int> _registeredEventIds = {};
  bool _isLoading = false;
  String? _errorMessage;
  bool _isRegistering = false;

  EventProvider({EventApiService? apiService})
      : _apiService = apiService ?? EventApiService() {
    _initFallbackEvents();
    fetchEvents();
  }

  List<EventModel> get events => _events;
  List<EventModel> get myEvents => _myEvents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isRegistering => _isRegistering;
  int get totalEvents => _events.length;

  void _initFallbackEvents() {
    final now = DateTime.now();
    _events = [
      EventModel(
        id: 1,
        judul: 'Book Exchange Day',
        deskripsi:
            'Bring your books and trade with fellow students on campus!',
        kategori: 'Pameran',
        lokasi: 'Open Library Lt. 3',
        tanggalMulai: now.add(const Duration(days: 2)),
        tanggalSelesai: now.add(const Duration(days: 4)),
        kuota: 80,
        fotoEvent: 'assets/images/event_library.jpg',
        jumlahPendaftar: 32,
      ),
      EventModel(
        id: 2,
        judul: 'Reading Meetup',
        deskripsi:
            'Temu komunitas pembaca buku dan diskusi seru tentang karya sastra modern favorit.',
        kategori: 'Diskusi',
        lokasi: 'Ruang Kolaborasi B',
        tanggalMulai: now.add(const Duration(days: 5)),
        tanggalSelesai: now.add(const Duration(days: 5, hours: 3)),
        kuota: 40,
        fotoEvent: 'assets/images/event_reading_meetup.jpg',
        jumlahPendaftar: 18,
      ),
      EventModel(
        id: 3,
        judul: 'Book Discussion Panel',
        deskripsi:
            'Sesi bedah buku bersama penulis terkemuka membahas kebiasaan membaca produktif.',
        kategori: 'Seminar',
        lokasi: 'Auditorium Gd. Damar',
        tanggalMulai: now.add(const Duration(days: 8)),
        tanggalSelesai: now.add(const Duration(days: 8, hours: 4)),
        kuota: 150,
        fotoEvent: 'assets/images/event_book_discussion.jpg',
        jumlahPendaftar: 95,
      ),
    ];
  }

  /// Memeriksa apakah user sudah terdaftar di event tertentu
  bool isUserRegistered(int eventId) =>
      _registeredEventIds.contains(eventId) ||
      _myEvents.any((e) => e.id == eventId);

  /// Mengambil data event dari backend API
  Future<void> fetchEvents({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final hasilApi = await _apiService.getEvents();
      if (hasilApi.isNotEmpty) {
        _events = hasilApi;
      }
    } catch (e) {
      final teks = e.toString();
      _errorMessage = teks.startsWith('Exception: ')
          ? teks.replaceFirst('Exception: ', '')
          : 'Gagal mengambil data event dari server.';
      if (_events.isEmpty) {
        _initFallbackEvents();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Mengambil daftar event yang telah didaftarkan mahasiswa dari backend
  Future<void> fetchMyEvents(String token) async {
    try {
      final list = await _apiService.getMyEvents(token: token);
      _myEvents = list;
      for (final ev in list) {
        _registeredEventIds.add(ev.id);
      }
      notifyListeners();
    } catch (_) {}
  }

  /// Mendaftarkan pengguna ke dalam event
  Future<void> registerEvent({
    required String token,
    required int eventId,
  }) async {
    _isRegistering = true;
    notifyListeners();

    try {
      await _apiService.registerEvent(token: token, eventId: eventId);
      _registeredEventIds.add(eventId);

      // Perbarui jumlah pendaftar di state lokal secara instan
      final index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        final current = _events[index];
        final updated = current.copyWith(
          jumlahPendaftar: current.jumlahPendaftar + 1,
        );
        _events[index] = updated;
        if (!_myEvents.any((e) => e.id == eventId)) {
          _myEvents.insert(0, updated);
        }
      }
    } catch (e) {
      if (e.toString().contains('sudah terdaftar')) {
        _registeredEventIds.add(eventId);
      }
      rethrow;
    } finally {
      _isRegistering = false;
      notifyListeners();
    }
  }

  /// Membuat dan mempublikasikan event baru ke server
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
    String? status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newEvent = await _apiService.createEvent(
        token: token,
        judul: judul,
        deskripsi: deskripsi,
        kategori: kategori,
        lokasi: lokasi,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
        kuota: kuota,
        fotoEvent: fotoEvent,
        status: status,
      );

      _events.insert(0, newEvent);
      return newEvent;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mengunggah gambar/banner event ke backend
  Future<String> uploadBannerImage({
    required String token,
    required List<int> bytes,
    required String filename,
  }) async {
    return await _apiService.uploadBannerImage(
      token: token,
      bytes: bytes,
      filename: filename,
    );
  }

  /// Menghapus event oleh admin
  Future<void> deleteEvent({
    required String token,
    required int eventId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.deleteEvent(token: token, eventId: eventId);
      _events.removeWhere((e) => e.id == eventId);
      _myEvents.removeWhere((e) => e.id == eventId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memperbarui status event di backend database dan state lokal
  Future<EventModel> updateEventStatus({
    required String token,
    required int eventId,
    required String status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _apiService.updateEventStatus(
        token: token,
        eventId: eventId,
        status: status,
      );

      final index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        _events[index] = updated;
      }
      final myIndex = _myEvents.indexWhere((e) => e.id == eventId);
      if (myIndex != -1) {
        _myEvents[myIndex] = updated;
      }
      return updated;
    } catch (e) {
      final teks = e.toString();
      _errorMessage = teks.startsWith('Exception: ')
          ? teks.replaceFirst('Exception: ', '')
          : 'Gagal memperbarui status event.';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

