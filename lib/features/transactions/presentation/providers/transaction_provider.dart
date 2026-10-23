import '../../../chat/data/services/chat_api_service.dart';
import 'package:flutter/foundation.dart';
import '../../data/services/transaction_api_service.dart';
import '../../domain/models/transaction_model.dart';
import '../../../profile/data/services/review_api_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionApiService _apiService;
  final List<TransactionModel> _daftarTransaksi = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserId;
  String? _currentUserName;

  TransactionProvider({
    TransactionApiService? apiService,
    bool isiDataAwal = false,
  }) : _apiService = apiService ?? TransactionApiService() {
    if (isiDataAwal) {
      _daftarTransaksi.add(
        const TransactionModel(
          id: 'trx_test_01',
          bukuId: 'bk_001',
          judulBuku: 'Clean Code',
          pemohonNama: 'Budi Santoso',
          pemilikNama: 'Gilang Ramadan',
          jenisTransaksi: 'pinjam',
          durasiHari: 7,
          depositSimulasi: 20000.0,
          status: 'pending',
          tanggal: '2026-09-15',
          coverBuku: 'assets/images/book_the_unknown.jpg',
        ),
      );
    }
  }

  void setCurrentUser({String? id, String? name}) {
    _currentUserId = id;
    _currentUserName = name;
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;

  List<TransactionModel> get semuaTransaksi =>
      List.unmodifiable(_daftarTransaksi);

  List<TransactionModel> get requestMasuk {
    if (_currentUserName != null && _currentUserName!.isNotEmpty) {
      return _daftarTransaksi
          .where((trx) =>
              trx.pemilikNama.toLowerCase() == _currentUserName!.toLowerCase() &&
              trx.pemohonNama.toLowerCase() != _currentUserName!.toLowerCase())
          .toList();
    }
    return _daftarTransaksi
        .where((trx) =>
            trx.pemilikNama == 'Gilang Ramadan' ||
            (trx.pemilikNama != trx.pemohonNama && trx.pemilikNama.isNotEmpty))
        .toList();
  }

  List<TransactionModel> get requestSaya {
    if (_currentUserName != null && _currentUserName!.isNotEmpty) {
      return _daftarTransaksi
          .where((trx) =>
              trx.pemohonNama.toLowerCase() == _currentUserName!.toLowerCase())
          .toList();
    }
    return _daftarTransaksi
        .where((trx) => trx.pemohonNama == 'Gilang Ramadan')
        .toList();
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
      'pemilikNama': 'Pemilik Buku',
      'lokasi': 'Telkom University',
    };
  }

  String getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Waiting for Confirmation';
      case 'disetujui':
        return 'Approved (Deposit Required)';
      case 'ditolak':
        return 'Rejected';
      case 'dibatalkan':
        return 'Cancelled';
      case 'deposit_dibayar':
        return 'Deposit Paid (Select Location)';
      case 'lokasi_ditentukan':
        return 'Location Set (Waiting for Handover)';
      case 'sedang_dipinjam':
        return 'Borrowed';
      case 'selesai':
        return 'Completed';
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
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<TransactionModel?> fetchTransaksiById(
      String token, String id) async {
    try {
      final intId = int.tryParse(id);
      if (intId == null) return getTransaksiById(id);
      var trx = await _apiService.getTransactionById(
          token: token, id: intId);
      if (trx.lokasiPertemuan.trim().isEmpty) {
        final loc = await checkHandoverFromChat(token, intId);
        if (loc != null && loc.isNotEmpty) {
          trx = trx.copyWith(lokasiPertemuan: loc);
        }
      }
      final idx = _daftarTransaksi.indexWhere((t) => t.id.trim() == id.trim());
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
      final idx = _daftarTransaksi.indexWhere((t) => t.id.trim() == id.trim());
      if (idx != -1) {
        _daftarTransaksi[idx] = updated;
      } else {
        _daftarTransaksi.add(updated);
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
    updateLokasiTransaksi(id: id, lokasi: lokasi);
    notifyListeners();

    final intId = int.tryParse(id);
    if (intId != null) {
      try {
        final chatService = ChatApiService();
        await chatService.sendMessage(
          token: token,
          transactionId: intId,
          pesan: '[HANDOVER_LOCATION]: ' + lokasi,
        );
      } catch (_) {}
    }

    try {
      if (intId != null) {
        final updated = await _apiService.setMeeting(
          token: token,
          id: intId,
          lokasiPertemuan: lokasi,
          waktuPertemuan: waktu,
        );
        final idx = _daftarTransaksi.indexWhere((t) => t.id.trim() == id.trim());
        if (idx != -1) {
          _daftarTransaksi[idx] = updated;
        } else {
          _daftarTransaksi.add(updated);
        }
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return true;
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

  Future<bool> confirmReturnApi(String token, String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final intId = int.tryParse(id);
      if (intId == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final updated = await _apiService.confirmReturn(
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

  Future<bool> submitReviewApi({
    required String token,
    required String transactionId,
    required int rating,
    String? komentar,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final intTxId = int.tryParse(transactionId);
      if (intTxId == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final reviewService = ReviewApiService();
      final success = await reviewService.submitTransactionReview(
        token: token,
        transactionId: intTxId,
        rating: rating,
        komentar: komentar,
      );
      _isLoading = false;
      notifyListeners();
      return success;
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
    String pemilikNama = 'Pemilik Buku',
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
    String pemilikNama = 'Pemilik Buku',
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

  Future<String?> checkHandoverFromChat(String token, int txId) async {
    try {
      final chatService = ChatApiService();
      final msgs = await chatService.getMessages(token: token, transactionId: txId);
      for (final m in msgs.reversed) {
        if (m.pesan.startsWith('[HANDOVER_LOCATION]:')) {
          final loc = m.pesan.replaceFirst('[HANDOVER_LOCATION]:', '').trim();
          if (loc.isNotEmpty) {
            updateLokasiTransaksi(id: txId.toString(), lokasi: loc);
            return loc;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  void updateLokasiTransaksi({
    String? id,
    String? bukuId,
    String? judulBuku,
    required String lokasi,
  }) {
    for (int i = 0; i < _daftarTransaksi.length; i++) {
      final trx = _daftarTransaksi[i];
      final matchId = id != null && id.trim().isNotEmpty && trx.id.trim().toLowerCase() == id.trim().toLowerCase();
      final matchBuku = bukuId != null && bukuId.trim().isNotEmpty && trx.bukuId.trim().toLowerCase() == bukuId.trim().toLowerCase();
      final matchJudul = judulBuku != null && judulBuku.trim().isNotEmpty && trx.judulBuku.trim().toLowerCase() == judulBuku.trim().toLowerCase();
      if (matchId || matchBuku || matchJudul) {
        _daftarTransaksi[i] = trx.copyWith(
          lokasiPertemuan: lokasi,
          status: 'lokasi_ditentukan',
        );
      }
    }
    notifyListeners();
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

  void tambahTransaksi(TransactionModel trx) {
    _daftarTransaksi.add(trx);
    notifyListeners();
  }
}
