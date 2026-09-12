import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/transactions/domain/models/transaction_model.dart';
import 'package:librava/features/transactions/presentation/providers/transaction_provider.dart';

void main() {
  group('TransactionModel Unit Tests', () {
    test('fromJson dan toJson bekerja dengan tepat', () {
      final sampleJson = {
        'id': 'trx_001',
        'bukuId': 'bk_001',
        'judulBuku': 'Clean Code',
        'pemohonNama': 'Gilang Ramadan',
        'jenisTransaksi': 'pinjam',
        'durasiHari': 7,
        'bukuBarter': '',
        'depositSimulasi': 20000.0,
        'status': 'pending',
        'tanggal': '2026-09-12',
      };

      final transaksi = TransactionModel.fromJson(sampleJson);
      expect(transaksi.id, 'trx_001');
      expect(transaksi.judulBuku, 'Clean Code');
      expect(transaksi.pemohonNama, 'Gilang Ramadan');
      expect(transaksi.jenisTransaksi, 'pinjam');
      expect(transaksi.depositSimulasi, 20000.0);

      final exportedJson = transaksi.toJson();
      expect(exportedJson['id'], 'trx_001');
      expect(exportedJson['jenisTransaksi'], 'pinjam');
      expect(exportedJson['depositSimulasi'], 20000.0);
    });
  });

  group('TransactionProvider Unit Tests', () {
    late TransactionProvider provider;

    setUp(() {
      provider = TransactionProvider();
    });

    test('Inisialisasi awal provider tidak memiliki transaksi', () {
      expect(provider.semuaTransaksi.isEmpty, true);
      expect(provider.transaksiPending.isEmpty, true);
      expect(provider.transaksiDisetujui.isEmpty, true);
    });

    test('ajukanPinjam berhasil menambahkan transaksi pinjam dengan status pending', () {
      final trx = provider.ajukanPinjam(
        bukuId: 'bk_001',
        judulBuku: 'Clean Code',
        pemohonNama: 'Gilang Ramadan',
        durasiHari: 7,
        depositSimulasi: 25000.0,
      );

      expect(provider.semuaTransaksi.length, 1);
      expect(trx.jenisTransaksi, 'pinjam');
      expect(trx.status, 'pending');
      expect(trx.depositSimulasi, 25000.0);
      expect(provider.transaksiPending.length, 1);
    });

    test('ajukanBarter berhasil menambahkan transaksi barter dengan buku penukar', () {
      final trx = provider.ajukanBarter(
        bukuId: 'bk_002',
        judulBuku: 'Flutter Apprentice',
        pemohonNama: 'Syahdan',
        bukuBarter: 'Refactoring (Martin Fowler)',
        durasiHari: 14,
      );

      expect(provider.semuaTransaksi.length, 1);
      expect(trx.jenisTransaksi, 'barter');
      expect(trx.bukuBarter, 'Refactoring (Martin Fowler)');
      expect(trx.status, 'pending');
    });

    test('ubahStatusTransaksi berhasil mengubah status dari pending menjadi disetujui', () {
      final trx = provider.ajukanPinjam(
        bukuId: 'bk_001',
        judulBuku: 'Clean Code',
        pemohonNama: 'Gilang Ramadan',
      );

      expect(provider.transaksiPending.length, 1);
      expect(provider.transaksiDisetujui.length, 0);

      final sukses = provider.ubahStatusTransaksi(trx.id, 'disetujui');

      expect(sukses, true);
      expect(provider.transaksiPending.length, 0);
      expect(provider.transaksiDisetujui.length, 1);
      expect(provider.semuaTransaksi.first.status, 'disetujui');
    });
  });
}
