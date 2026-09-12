import 'package:flutter/foundation.dart';
import '../../domain/models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final List<TransactionModel> _daftarTransaksi = [];

  List<TransactionModel> get semuaTransaksi => List.unmodifiable(_daftarTransaksi);

  List<TransactionModel> get transaksiPending {
    return _daftarTransaksi.where((trx) => trx.status == 'pending').toList();
  }

  List<TransactionModel> get transaksiDisetujui {
    return _daftarTransaksi.where((trx) => trx.status == 'disetujui').toList();
  }

  TransactionModel ajukanPinjam({
    required String bukuId,
    required String judulBuku,
    required String pemohonNama,
    int durasiHari = 7,
    double depositSimulasi = 20000.0,
  }) {
    final transaksiBaru = TransactionModel(
      id: 'trx_${DateTime.now().millisecondsSinceEpoch}',
      bukuId: bukuId,
      judulBuku: judulBuku,
      pemohonNama: pemohonNama,
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
    int durasiHari = 14,
  }) {
    final transaksiBaru = TransactionModel(
      id: 'trx_${DateTime.now().millisecondsSinceEpoch}',
      bukuId: bukuId,
      judulBuku: judulBuku,
      pemohonNama: pemohonNama,
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
      _daftarTransaksi[index] = _daftarTransaksi[index].copyWith(status: statusBaru);
      notifyListeners();
      return true;
    }
    return false;
  }
}
