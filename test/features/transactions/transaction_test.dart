import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/transactions/domain/models/transaction_model.dart';
import 'package:librava/features/transactions/presentation/providers/transaction_provider.dart';

void main() {
  group('TransactionModel Unit Tests', () {
    test('fromJson dan toJson bekerja dengan tepat untuk semua properti', () {
      final sampleJson = {
        'id': 'trx_001',
        'bukuId': 'bk_001',
        'judulBuku': 'Algoritma Pemrograman',
        'pemohonNama': 'Gilang Ramadan',
        'pemilikNama': 'Andi (dummy)',
        'jenisTransaksi': 'pinjam',
        'durasiHari': 7,
        'bukuBarter': '',
        'depositSimulasi': 20000.0,
        'status': 'pending',
        'lokasiPertemuan': 'Open Library Telkom University',
        'tanggal': '2026-09-15',
        'tanggalPengembalian': '2026-09-22',
      };

      final transaksi = TransactionModel.fromJson(sampleJson);
      expect(transaksi.id, 'trx_001');
      expect(transaksi.judulBuku, 'Algoritma Pemrograman');
      expect(transaksi.pemohonNama, 'Gilang Ramadan');
      expect(transaksi.pemilikNama, 'Andi (dummy)');
      expect(transaksi.lokasiPertemuan, 'Open Library Telkom University');
      expect(transaksi.tanggalPengembalian, '2026-09-22');

      final exportedJson = transaksi.toJson();
      expect(exportedJson['id'], 'trx_001');
      expect(exportedJson['pemilikNama'], 'Andi (dummy)');
      expect(exportedJson['depositSimulasi'], 20000.0);
      expect(exportedJson['lokasiPertemuan'], 'Open Library Telkom University');
    });

    test('copyWith memperbarui nilai spesifik tanpa merusak nilai lain', () {
      const awal = TransactionModel(
        id: 'trx_100',
        bukuId: 'bk_001',
        judulBuku: 'Algoritma Pemrograman',
        pemohonNama: 'Gilang Ramadan',
        jenisTransaksi: 'pinjam',
        tanggal: '2026-09-15',
      );

      final diubah = awal.copyWith(
        status: 'disetujui',
        lokasiPertemuan: 'Gedung Tokong Nanas',
      );

      expect(diubah.status, 'disetujui');
      expect(diubah.lokasiPertemuan, 'Gedung Tokong Nanas');
      expect(diubah.judulBuku, 'Algoritma Pemrograman');
      expect(diubah.pemilikNama, 'Andi (dummy)');
    });
  });

  group('TransactionProvider Unit Tests (Simulasi MVP 15 Langkah)', () {
    late TransactionProvider provider;

    setUp(() {
      provider = TransactionProvider();
    });

    test('Inisialisasi awal provider dalam keadaan kosong', () {
      expect(provider.semuaTransaksi.isEmpty, true);
      expect(provider.transaksiPending.isEmpty, true);
      expect(provider.transaksiDisetujui.isEmpty, true);
      expect(provider.transaksiAktif.isEmpty, true);
      expect(provider.riwayatSelesai.isEmpty, true);
    });

    test('Alur Lengkap Transaksi Sukses (Happy Path Pinjam)', () async {
      final trx = provider.ajukanPinjam(
        bukuId: 'bk_001',
        judulBuku: 'Algoritma Pemrograman',
        pemohonNama: 'Gilang Ramadan',
        durasiHari: 7,
        depositSimulasi: 20000.0,
      );

      expect(trx.status, 'pending');
      expect(provider.transaksiPending.length, 1);
      expect(provider.transaksiAktif.length, 1);

      final responBerhasil = await provider.simulasiResponPemilik(
        trx.id,
        disetujui: true,
        delay: Duration.zero,
      );
      expect(responBerhasil, true);

      final trxDisetujui = provider.getTransaksiById(trx.id);
      expect(trxDisetujui?.status, 'disetujui');
      expect(provider.transaksiDisetujui.length, 1);

      final bayarBerhasil = provider.bayarDepositSimulasi(trx.id, 20000.0);
      expect(bayarBerhasil, true);
      expect(provider.getTransaksiById(trx.id)?.status, 'deposit_dibayar');

      final lokasiBerhasil = provider.tentukanLokasiPertemuan(
        trx.id,
        'Open Library Telkom University',
      );
      expect(lokasiBerhasil, true);
      expect(
        provider.getTransaksiById(trx.id)?.lokasiPertemuan,
        'Open Library Telkom University',
      );

      final serahTerimaBerhasil = provider.konfirmasiSerahTerima(trx.id);
      expect(serahTerimaBerhasil, true);
      expect(provider.getTransaksiById(trx.id)?.status, 'sedang_dipinjam');
      expect(provider.transaksiAktif.length, 1);

      final selesaiBerhasil = provider.selesaikanTransaksi(
        trx.id,
        tanggalPengembalian: '2026-09-22',
      );
      expect(selesaiBerhasil, true);

      final trxSelesai = provider.getTransaksiById(trx.id);
      expect(trxSelesai?.status, 'selesai');
      expect(trxSelesai?.tanggalPengembalian, '2026-09-22');

      expect(provider.transaksiAktif.length, 0);
      expect(provider.riwayatSelesai.length, 1);
    });

    test('Alur Penolakan Transaksi (Reject Path Barter)', () async {
      final trx = provider.ajukanBarter(
        bukuId: 'bk_002',
        judulBuku: 'Struktur Data',
        pemohonNama: 'Gilang Ramadan',
        bukuBarter: 'Basis Data Praktis',
        durasiHari: 14,
      );

      expect(trx.status, 'pending');
      expect(trx.bukuBarter, 'Basis Data Praktis');

      final responTolak = await provider.simulasiResponPemilik(
        trx.id,
        disetujui: false,
        delay: Duration.zero,
      );
      expect(responTolak, true);

      final trxDitolak = provider.getTransaksiById(trx.id);
      expect(trxDitolak?.status, 'ditolak');

      expect(provider.transaksiAktif.length, 0);
      expect(provider.riwayatSelesai.length, 1);
    });

    test('Validasi: Bayar deposit gagal jika status belum disetujui', () {
      final trx = provider.ajukanPinjam(
        bukuId: 'bk_001',
        judulBuku: 'Algoritma Pemrograman',
        pemohonNama: 'Gilang Ramadan',
      );

      final bayarGagal = provider.bayarDepositSimulasi(trx.id, 20000.0);
      expect(bayarGagal, false);
      expect(provider.getTransaksiById(trx.id)?.status, 'pending');
    });

    test('getTransaksiById mengembalikan null jika id tidak ditemukan', () {
      final trx = provider.getTransaksiById('id_tidak_ada');
      expect(trx, isNull);
    });
  });
}
