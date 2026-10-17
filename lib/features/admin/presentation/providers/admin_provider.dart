import 'package:flutter/material.dart';
import '../../data/services/admin_api_service.dart';
import '../../domain/models/admin_book_model.dart';
import '../../domain/models/admin_dashboard_model.dart';
import '../../domain/models/admin_transaction_model.dart';
import '../../domain/models/admin_user_model.dart';

class AdminProvider extends ChangeNotifier {
  final AdminApiService _apiService;

  AdminDashboardModel _dashboard = const AdminDashboardModel(
    totalStudents: 0,
    totalBooks: 0,
    totalRequests: 0,
    totalTransactions: 0,
    recentActivity: [],
    recentTransactions: [],
  );

  bool _isLoading = false;
  String? _errorMessage;

  List<AdminUserModel> _daftarMahasiswa = [];
  bool _isLoadingMahasiswa = false;
  String? _errorMahasiswa;
  String _kataKunci = '';

  List<AdminBookModel> _daftarBuku = [];
  bool _isLoadingBuku = false;
  String? _errorBuku;
  String _kataKunciBuku = '';

  List<AdminTransactionModel> _daftarTransaksi = [];
  bool _isLoadingTransaksi = false;
  String? _errorTransaksi;
  String _kataKunciTransaksi = '';
  String _kataKunciRequest = '';

  AdminProvider({
    AdminApiService? apiService,
    AdminDashboardModel? initialDashboard,
  })  : _apiService = apiService ?? AdminApiService(),
        _dashboard = initialDashboard ??
            const AdminDashboardModel(
              totalStudents: 0,
              totalBooks: 0,
              totalRequests: 0,
              totalTransactions: 0,
              recentActivity: [],
              recentTransactions: [],
            );

  AdminDashboardModel get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isLoadingMahasiswa => _isLoadingMahasiswa;
  String? get errorMahasiswa => _errorMahasiswa;
  String get kataKunci => _kataKunci;
  int get jumlahMahasiswa => _daftarMahasiswa.length;

  bool get isLoadingBuku => _isLoadingBuku;
  String? get errorBuku => _errorBuku;
  String get kataKunciBuku => _kataKunciBuku;
  int get jumlahBuku => _daftarBuku.length;

  bool get isLoadingTransaksi => _isLoadingTransaksi;
  String? get errorTransaksi => _errorTransaksi;
  String get kataKunciTransaksi => _kataKunciTransaksi;
  int get jumlahTransaksi => _daftarTransaksi.length;
  List<AdminTransactionModel> get daftarTransaksi => _daftarTransaksi;

  List<AdminTransactionModel> get daftarTransaksiTampil {
    final kata = _kataKunciTransaksi.trim().toLowerCase();
    if (kata.isEmpty) {
      return _daftarTransaksi;
    }
    return _daftarTransaksi.where((tx) {
      return tx.bookJudul.toLowerCase().contains(kata) ||
          tx.requesterNama.toLowerCase().contains(kata) ||
          tx.ownerNama.toLowerCase().contains(kata) ||
          tx.tipeTampil.toLowerCase().contains(kata);
    }).toList();
  }

  String get kataKunciRequest => _kataKunciRequest;

  List<AdminTransactionModel> get daftarRequestTampil {
    const statusRequest = ['MENUNGGU_KONFIRMASI', 'DISETUJUI', 'DITOLAK'];
    final semuaRequest = _daftarTransaksi
        .where((tx) => statusRequest.contains(tx.status))
        .toList();
    final kata = _kataKunciRequest.trim().toLowerCase();
    if (kata.isEmpty) {
      return semuaRequest;
    }
    return semuaRequest.where((tx) {
      return tx.bookJudul.toLowerCase().contains(kata) ||
          tx.requesterNama.toLowerCase().contains(kata) ||
          tx.ownerNama.toLowerCase().contains(kata) ||
          tx.tipeTampil.toLowerCase().contains(kata);
    }).toList();
  }

  List<AdminBookModel> get daftarBukuTampil {
    final kata = _kataKunciBuku.trim().toLowerCase();
    if (kata.isEmpty) {
      return _daftarBuku;
    }
    return _daftarBuku.where((buku) {
      return buku.judul.toLowerCase().contains(kata) ||
          buku.penulis.toLowerCase().contains(kata) ||
          buku.kategori.toLowerCase().contains(kata);
    }).toList();
  }

  List<AdminUserModel> get daftarMahasiswaTampil {
    final kata = _kataKunci.trim().toLowerCase();
    if (kata.isEmpty) {
      return _daftarMahasiswa;
    }
    return _daftarMahasiswa.where((user) {
      return user.nama.toLowerCase().contains(kata) ||
          user.email.toLowerCase().contains(kata) ||
          user.username.toLowerCase().contains(kata) ||
          (user.nim ?? '').toLowerCase().contains(kata);
    }).toList();
  }

  Future<void> fetchDashboard(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.getDashboard(token: token);
      _dashboard = result;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMahasiswa(String token) async {
    _isLoadingMahasiswa = true;
    _errorMahasiswa = null;
    notifyListeners();

    try {
      final semuaUser = await _apiService.getUsers(token: token);
      _daftarMahasiswa =
          semuaUser.where((user) => user.role == 'mahasiswa').toList();
    } catch (e) {
      final teks = e.toString();
      _errorMahasiswa = teks.startsWith('Exception: ')
          ? teks.replaceFirst('Exception: ', '')
          : 'Tidak dapat terhubung ke server. Coba lagi nanti.';
    }

    _isLoadingMahasiswa = false;
    notifyListeners();
  }

  void tandaiSesiTidakValid() {
    _errorMahasiswa = 'Sesi admin tidak ditemukan. Silakan login ulang.';
    notifyListeners();
  }

  void cariMahasiswa(String kata) {
    _kataKunci = kata;
    notifyListeners();
  }

  Future<void> fetchBuku(String token) async {
    _isLoadingBuku = true;
    _errorBuku = null;
    notifyListeners();

    try {
      _daftarBuku = await _apiService.getBooks(token: token);
    } catch (e) {
      final teks = e.toString();
      _errorBuku = teks.startsWith('Exception: ')
          ? teks.replaceFirst('Exception: ', '')
          : 'Tidak dapat terhubung ke server. Coba lagi nanti.';
    }

    _isLoadingBuku = false;
    notifyListeners();
  }

  void tandaiSesiBukuTidakValid() {
    _errorBuku = 'Sesi admin tidak ditemukan. Silakan login ulang.';
    notifyListeners();
  }

  void cariBuku(String kata) {
    _kataKunciBuku = kata;
    notifyListeners();
  }

  Future<void> fetchTransaksi(String token) async {
    _isLoadingTransaksi = true;
    _errorTransaksi = null;
    notifyListeners();

    try {
      _daftarTransaksi = await _apiService.getTransactions(token: token);
    } catch (e) {
      final teks = e.toString();
      _errorTransaksi = teks.startsWith('Exception: ')
          ? teks.replaceFirst('Exception: ', '')
          : 'Tidak dapat terhubung ke server. Coba lagi nanti.';
    }

    _isLoadingTransaksi = false;
    notifyListeners();
  }

  void tandaiSesiTransaksiTidakValid() {
    _errorTransaksi = 'Sesi admin tidak ditemukan. Silakan login ulang.';
    notifyListeners();
  }

  void cariTransaksi(String kata) {
    _kataKunciTransaksi = kata;
    notifyListeners();
  }

  void cariRequest(String kata) {
    _kataKunciRequest = kata;
    notifyListeners();
  }

  List<AdminBookModel> _daftarBukuPending = [];
  bool _isLoadingBukuPending = false;
  String? _errorBukuPending;

  List<AdminBookModel> get daftarBukuPending => _daftarBukuPending;
  bool get isLoadingBukuPending => _isLoadingBukuPending;
  String? get errorBukuPending => _errorBukuPending;
  int get jumlahBukuPending => _daftarBukuPending.length;

  Future<void> fetchBukuPending(String token) async {
    _isLoadingBukuPending = true;
    _errorBukuPending = null;
    notifyListeners();

    try {
      _daftarBukuPending = await _apiService.getPendingBooks(token: token);
    } catch (e) {
      final teks = e.toString();
      _errorBukuPending = teks.startsWith('Exception: ')
          ? teks.replaceFirst('Exception: ', '')
          : 'Gagal memuat antrean moderasi buku.';
    }

    _isLoadingBukuPending = false;
    notifyListeners();
  }

  Future<bool> moderateBook({
    required String token,
    required String bookId,
    required String action,
    String? catatan,
  }) async {
    try {
      final updated = await _apiService.moderateBook(
        token: token,
        bookId: bookId,
        action: action,
        catatan: catatan,
      );

      _daftarBukuPending.removeWhere((b) => b.id == bookId);
      if (action == 'APPROVE') {
        _daftarBuku.removeWhere((b) => b.id == bookId);
        _daftarBuku.insert(0, updated);
      }
      notifyListeners();
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
