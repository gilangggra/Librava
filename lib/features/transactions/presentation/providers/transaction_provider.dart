import 'package:flutter/foundation.dart';
import '../../data/services/transaction_api_service.dart';
import '../../domain/models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionApiService _apiService;
  final List<TransactionModel> _daftarTransaksi = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserId;

  TransactionProvider({
    TransactionApiService? apiService,
    bool isiDataAwal = true,
  }) : _apiService = apiService ?? TransactionApiService() {
    if (isiDataAwal) {
      _inisialisasiDataAwal();
    }
  }

  void _inisialisasiDataAwal() {
    _daftarTransaksi.addAll([
      const TransactionModel(
        id: 'trx_masuk_001',
        bukuId: 'bk_001',
        judulBuku: 'Clean Code',
        pemohonNama: 'Budi Santoso',
        pemilikNama: 'Gilang Ramadan',
        jenisTransaksi: 'pinjam',
        durasiHari: 7,
        depositSimulasi: 20000.0,
        status: 'pending',
        tanggal: '2026-09-20',
        coverBuku: 'assets/images/book_the_unknown.jpg',
      ),
      const TransactionModel(
        id: 'trx_saya_001',
        bukuId: 'bk_002',
        judulBuku: 'Algoritma Pemrograman',
        pemohonNama: 'Gilang Ramadan',
        pemilikNama: 'Andi (dummy)',
        jenisTransaksi: 'pinjam',
        durasiHari: 14,
        depositSimulasi: 20000.0,
        status: 'disetujui',
        tanggal: '2026-09-22',
        coverBuku: 'assets/images/book_the_unknown.jpg',
      ),
      const TransactionModel(
        id: 'trx_riwayat_001',
        bukuId: 'bk_003',
        judulBuku: 'Flutter Apprentice',
        pemohonNama: 'Gilang Ramadan',
        pemilikNama: 'Andi (dummy)',
        jenisTransaksi: 'barter',
        bukuBarter: 'Design Patterns',
        durasiHari: 14,
        depositSimulasi: 0.0,
        status: 'selesai',
        lokasiPertemuan: 'Open Library Telkom University',
        tanggal: '2026-09-10',
        tanggalPengembalian: '2026-09-24',
        coverBuku: 'assets/images/book_fruit_fly.jpg',
      ),
    ]);
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<TransactionModel> get semuaTransaksi =>
      List.unmodifiable(_daftarTransaksi);

  List<TransactionModel> get requestMasuk {
    if (_currentUserId != null) {
      return _daftarTransaksi
          .where((trx) => trx.pemilikNama != trx.pemohonNama &&
              !_isRequester(trx))
          .toList();
    }
    return _daftarTransaksi
        .where((trx) => trx.pemilikNama == 'Gilang Ramadan')
        .toList();
  }

  List<TransactionModel> get requestSaya {
    if (_currentUserId != null) {
      return _daftarTransaksi
          .where((trx) => _isRequester(trx))
          .toList();
    }
    return _daftarTransaksi
        .where((trx) => trx.pemohonNama == 'Gilang Ramadan')
        .toList();
  }

  bool _isRequester(TransactionModel trx) {
    return trx.pemohonNama != trx.pemilikNama;
  }

  List<TransactionModel> get transaksiPending {
    return _daftarTransaksi.where((trx) => trx.status == 'pending').toList();
  }

  List<TransactionModel> get transaksiDisetujui {
    return _daftarTransaksi.where((trx) => trx.status == 'disetujui').toList();
  }

  List<TransactionModel> get transaksiAktif {
    return _daftarTransaksi
        .where((trx) => trx.status != 'selesai' && trx.status != 'ditolak')
        .toList();
  }

  List<TransactionModel> get riwayatSelesai {
    return _daftarTransaksi
        .where((trx) => trx.status == 'selesai' || trx.status == 'ditolak')
        .toList();
  }

  TransactionModel? getTransaksiById(String idTransaksi) {
    try {
      return _daftarTransaksi.firstWhere((trx) => trx.id == idTransaksi);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> matchingBuku(String bukuId) {
    return {
      'bukuId': bukuId,
      'tersedia': true,
      'pemilikNama': 'Andi (dummy)',
      'lokasi': 'Telkom University',
    };
  }

  String getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'disetujui':
        return 'Disetujui (Perlu Deposit)';
      case 'ditolak':
        return 'Ditolak';
      case 'dibatalkan':
        return 'Dibatalkan';
      case 'deposit_dibayar':
        return 'Deposit Dibayar (Pilih Lokasi)';
      case 'lokasi_ditentukan':
        return 'Lokasi Ditentukan (Menunggu Serah Terima)';
      case 'sedang_dipinjam':
        return 'Sedang Dipinjam';
      case 'selesai':
        return 'Selesai';
      default:
        return status;
    }
  }

  Future<void> fetchTransaksi(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _apiService.getTransactions(token: token);
      _daftarTransaksi.clear();
      _daftarTransaksi.addAll(list);
    } catch (_) {
      if (_daftarTransaksi.isEmpty) {
        _inisialisasiDataAwal();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<TransactionModel?> fetchTransaksiById(
      String token, String id) async {
    try {
      final intId = int.tryParse(id);
      if (intId == null) return getTransaksiById(id);
      final trx = await _apiService.getTransactionById(
          token: token, id: intId);
      final idx = _daftarTransaksi.indexWhere((t) => t.id == id);
      if (idx != -1) {
        _daftarTransaksi[idx] = trx;
      } else {
        _daftarTransaksi.add(trx);
      }
      notifyListeners();
      return trx;
    } catch (_) {
      return getTransaksiById(id);
    }
  }

  Future<TransactionModel?> ajukanPinjamApi({
    required String token,
    required int bookId,
    double depositDummy = 20000.0,
    int durasiHari = 7,
    String judulBuku = '',
    String pemilikNama = '',
    String coverBuku = 'assets/images/book_the_unknown.jpg',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final trx = await _apiService.createTransaction(
        token: token,
        bookId: bookId,
        tipeTransaksi: 'BORROW',
        depositDummy: depositDummy,
      );
      _daftarTransaksi.insert(0, trx);
      _isLoading = false;
      notifyListeners();
      return trx;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<TransactionModel?> ajukanBarterApi({
    required String token,
    required int bookId,
    required int barterBookId,
    String judulBuku = '',
    String pemilikNama = '',
    String coverBuku = 'assets/images/book_the_unknown.jpg',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final trx = await _apiService.createTransaction(
        token: token,
        bookId: bookId,
        tipeTransaksi: 'BARTER',
        barterBookId: barterBookId,
      );
      _daftarTransaksi.insert(0, trx);
      _isLoading = false;
      notifyListeners();
      return trx;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateStatusApi(String token, String id, String backendStatus) async {
    _isLoading = true;
    notifyListeners();

    try {
      final intId = int.tryParse(id);
      if (intId == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final updated = await _apiService.updateStatus(
        token: token,
        id: intId,
        status: backendStatus,
      );
      final idx = _daftarTransaksi.indexWhere((t) => t.id == id);
      if (idx != -1) {
        _daftarTransaksi[idx] = updated;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> setMeetingApi(
      String token, String id, String lokasi, String? waktu) async {
    _isLoading = true;
    notifyListeners();

    try {
      final intId = int.tryParse(id);
      if (intId == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final updated = await _apiService.setMeeting(
        token: token,
        id: intId,
        lokasiPertemuan: lokasi,
        waktuPertemuan: waktu,
      );
      final idx = _daftarTransaksi.indexWhere((t) => t.id == id);
      if (idx != -1) {
        _daftarTransaksi[idx] = updated;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirmHandoverApi(String token, String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final intId = int.tryParse(id);
      if (intId == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final updated = await _apiService.confirmHandover(
        token: token,
        id: intId,
      );
      final idx = _daftarTransaksi.indexWhere((t) => t.id == id);
      if (idx != -1) {
        _daftarTransaksi[idx] = updated;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  TransactionModel ajukanPinjam({
    required String bukuId,
    required String judulBuku,
    required String pemohonNama,
    String pemilikNama = 'Andi (dummy)',
    int durasiHari = 7,
    double depositSimulasi = 20000.0,
    String coverBuku = 'assets/images/book_the_unknown.jpg',
  }) {
    final transaksiBaru = TransactionModel(
      id: 'trx_${DateTime.now().millisecondsSinceEpoch}',
      bukuId: bukuId,
      judulBuku: judulBuku,
      pemohonNama: pemohonNama,
      pemilikNama: pemilikNama,
      jenisTransaksi: 'pinjam',
      durasiHari: durasiHari,
      depositSimulasi: depositSimulasi,
      status: 'pending',
      tanggal: DateTime.now().toIso8601String().split('T').first,
      coverBuku: coverBuku,
    );

    _daftarTransaksi.insert(0, transaksiBaru);
    notifyListeners();
    return transaksiBaru;
  }

  TransactionModel ajukanBarter({
    required String bukuId,
    required String judulBuku,
    required String pemohonNama,
    required String bukuBarter,
    String pemilikNama = 'Andi (dummy)',
    int durasiHari = 14,
    String coverBuku = 'assets/images/book_the_unknown.jpg',
  }) {
    final transaksiBaru = TransactionModel(
      id: 'trx_${DateTime.now().millisecondsSinceEpoch}',
      bukuId: bukuId,
      judulBuku: judulBuku,
      pemohonNama: pemohonNama,
      pemilikNama: pemilikNama,
      jenisTransaksi: 'barter',
      bukuBarter: bukuBarter,
      durasiHari: durasiHari,
      status: 'pending',
      tanggal: DateTime.now().toIso8601String().split('T').first,
      coverBuku: coverBuku,
    );

    _daftarTransaksi.insert(0, transaksiBaru);
    notifyListeners();
    return transaksiBaru;
  }

  bool terimaRequest(String idTransaksi) {
    final index = _daftarTransaksi.indexWhere((trx) => trx.id == idTransaksi);
    if (index != -1 && _daftarTransaksi[index].status == 'pending') {
      _daftarTransaksi[index] =
          _daftarTransaksi[index].copyWith(status: 'disetujui');
      notifyListeners();
      return true;
    }
    return false;
  }

  bool tolakRequest(String idTransaksi) {
    final index = _daftarTransaksi.indexWhere((trx) => trx.id == idTransaksi);
    if (index != -1 && _daftarTransaksi[index].status == 'pending') {
      _daftarTransaksi[index] =
          _daftarTransaksi[index].copyWith(status: 'ditolak');
      notifyListeners();
      return true;
    }
    return false;
  }

  bool bayarDepositSimulasi(String idTransaksi, double nominal) {
    final index = _daftarTransaksi.indexWhere((trx) => trx.id == idTransaksi);
    if (index != -1 && _daftarTransaksi[index].status == 'disetujui') {
      _daftarTransaksi[index] = _daftarTransaksi[index].copyWith(
        depositSimulasi: nominal,
        status: 'deposit_dibayar',
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  bool tentukanLokasiPertemuan(String idTransaksi, String lokasi) {
    final index = _daftarTransaksi.indexWhere((trx) => trx.id == idTransaksi);
    if (index != -1) {
      _daftarTransaksi[index] = _daftarTransaksi[index].copyWith(
        lokasiPertemuan: lokasi,
        status: 'lokasi_ditentukan',
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  bool konfirmasiSerahTerima(String idTransaksi) {
    final index = _daftarTransaksi.indexWhere((trx) => trx.id == idTransaksi);
    if (index != -1) {
      _daftarTransaksi[index] = _daftarTransaksi[index].copyWith(
        status: 'sedang_dipinjam',
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  bool selesaikanTransaksi(
    String idTransaksi, {
    String? tanggalPengembalian,
  }) {
    final index = _daftarTransaksi.indexWhere((trx) => trx.id == idTransaksi);
    if (index != -1) {
      final tgl = tanggalPengembalian ??
          DateTime.now().toIso8601String().split('T').first;
      _daftarTransaksi[index] = _daftarTransaksi[index].copyWith(
        status: 'selesai',
        tanggalPengembalian: tgl,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> simulasiResponPemilik(
    String idTransaksi, {
    required bool disetujui,
    Duration delay = const Duration(seconds: 1),
  }) async {
    final index = _daftarTransaksi.indexWhere((trx) => trx.id == idTransaksi);
    if (index == -1) return false;

    _isLoading = true;
    notifyListeners();

    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }

    final statusBaru = disetujui ? 'disetujui' : 'ditolak';
    _daftarTransaksi[index] =
        _daftarTransaksi[index].copyWith(status: statusBaru);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void resetSemuaTransaksi() {
    _daftarTransaksi.clear();
    notifyListeners();
  }
}
