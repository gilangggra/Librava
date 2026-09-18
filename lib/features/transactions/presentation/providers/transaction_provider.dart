import 'package:flutter/foundation.dart';
import '../../domain/models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final List<TransactionModel> _daftarTransaksi = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<TransactionModel> get semuaTransaksi =>
      List.unmodifiable(_daftarTransaksi);

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

  TransactionModel ajukanPinjam({
    required String bukuId,
    required String judulBuku,
    required String pemohonNama,
    String pemilikNama = 'Andi (dummy)',
    int durasiHari = 7,
    double depositSimulasi = 20000.0,
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
    );

    _daftarTransaksi.add(transaksiBaru);
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
    );

    _daftarTransaksi.add(transaksiBaru);
    notifyListeners();
    return transaksiBaru;
  }

  bool ubahStatusTransaksi(String idTransaksi, String statusBaru) {
    final index = _daftarTransaksi.indexWhere((trx) => trx.id == idTransaksi);
    if (index != -1) {
      _daftarTransaksi[index] =
          _daftarTransaksi[index].copyWith(status: statusBaru);
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
}
