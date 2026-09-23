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
        'coverBuku': 'assets/images/book_the_unknown.jpg',
      };

      final transaksi = TransactionModel.fromJson(sampleJson);
      expect(transaksi.id, 'trx_001');
      expect(transaksi.judulBuku, 'Algoritma Pemrograman');
      expect(transaksi.pemohonNama, 'Gilang Ramadan');
      expect(transaksi.pemilikNama, 'Andi (dummy)');
      expect(transaksi.lokasiPertemuan, 'Open Library Telkom University');
      expect(transaksi.tanggalPengembalian, '2026-09-22');
      expect(transaksi.coverBuku, 'assets/images/book_the_unknown.jpg');

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

  group('TransactionProvider Unit Tests (SRS FR-REQ-02 to FR-TRX-02)', () {
    late TransactionProvider provider;

    setUp(() {
      provider = TransactionProvider(isiDataAwal: false);
    });

    test('Inisialisasi awal provider tanpa data awal dalam keadaan kosong', () {
      expect(provider.semuaTransaksi.isEmpty, true);
      expect(provider.requestMasuk.isEmpty, true);
      expect(provider.requestSaya.isEmpty, true);
      expect(provider.transaksiPending.isEmpty, true);
      expect(provider.transaksiDisetujui.isEmpty, true);
      expect(provider.transaksiAktif.isEmpty, true);
      expect(provider.riwayatSelesai.isEmpty, true);
    });

    test('FR-REQ-02: Matching Buku mengembalikan ketersediaan dan pemilik dummy', () {
      final matching = provider.matchingBuku('bk_001');
      expect(matching['tersedia'], true);
      expect(matching['pemilikNama'], 'Andi (dummy)');
      expect(matching['lokasi'], 'Telkom University');
    });

    test('FR-REQ-03 & FR-REQ-04: Terima Request & Lihat Detail Request Masuk', () {
      final providerWithData = TransactionProvider(isiDataAwal: true);

      expect(providerWithData.requestMasuk.length, greaterThanOrEqualTo(1));
      final incoming = providerWithData.requestMasuk.first;
      expect(incoming.pemilikNama, 'Gilang Ramadan');
      expect(incoming.pemohonNama, 'Budi Santoso');
      expect(incoming.status, 'pending');

      final detail = providerWithData.getTransaksiById(incoming.id);
      expect(detail, isNotNull);
      expect(detail?.judulBuku, 'Clean Code');
    });

    test('FR-REQ-05: Kelola Request (Terima dan Tolak)', () {
      final trx1 = provider.ajukanPinjam(
        bukuId: 'bk_001',
        judulBuku: 'Clean Code',
        pemohonNama: 'Budi Santoso',
        pemilikNama: 'Gilang Ramadan',
      );
      final terimaSukses = provider.terimaRequest(trx1.id);
      expect(terimaSukses, true);
      expect(provider.getTransaksiById(trx1.id)?.status, 'disetujui');

      final trx2 = provider.ajukanPinjam(
        bukuId: 'bk_002',
        judulBuku: 'Refactoring',
        pemohonNama: 'Ahmad',
        pemilikNama: 'Gilang Ramadan',
      );
      final tolakSukses = provider.tolakRequest(trx2.id);
      expect(tolakSukses, true);
      expect(provider.getTransaksiById(trx2.id)?.status, 'ditolak');
    });

    test('FR-REQ-06: Status Request dan Label Ramah Pengguna', () {
      expect(provider.getStatusLabel('pending'), 'Menunggu Konfirmasi');
      expect(provider.getStatusLabel('disetujui'), 'Disetujui (Perlu Deposit)');
      expect(provider.getStatusLabel('ditolak'), 'Ditolak');
      expect(provider.getStatusLabel('deposit_dibayar'), 'Deposit Dibayar (Pilih Lokasi)');
      expect(provider.getStatusLabel('lokasi_ditentukan'), 'Lokasi Ditentukan (Menunggu Serah Terima)');
      expect(provider.getStatusLabel('sedang_dipinjam'), 'Sedang Dipinjam');
      expect(provider.getStatusLabel('selesai'), 'Selesai');
    });

    test('FR-DEP-01, FR-LOC-01, FR-TRX-01, FR-TRX-02: Siklus Transaksi End-to-End', () {
      final trx = provider.ajukanPinjam(
        bukuId: 'bk_002',
        judulBuku: 'Algoritma Pemrograman',
        pemohonNama: 'Gilang Ramadan',
        pemilikNama: 'Andi (dummy)',
        durasiHari: 7,
      );

      provider.terimaRequest(trx.id);
      expect(provider.getTransaksiById(trx.id)?.status, 'disetujui');

      final depositOk = provider.bayarDepositSimulasi(trx.id, 20000.0);
      expect(depositOk, true);
      expect(provider.getTransaksiById(trx.id)?.status, 'deposit_dibayar');

      final lokasiOk = provider.tentukanLokasiPertemuan(
        trx.id,
        'Open Library Telkom University',
      );
      expect(lokasiOk, true);
      expect(provider.getTransaksiById(trx.id)?.status, 'lokasi_ditentukan');
      expect(
        provider.getTransaksiById(trx.id)?.lokasiPertemuan,
        'Open Library Telkom University',
      );

      final serahTerimaOk = provider.konfirmasiSerahTerima(trx.id);
      expect(serahTerimaOk, true);
      expect(provider.getTransaksiById(trx.id)?.status, 'sedang_dipinjam');

      final selesaiOk = provider.selesaikanTransaksi(
        trx.id,
        tanggalPengembalian: '2026-09-30',
      );
      expect(selesaiOk, true);
      expect(provider.getTransaksiById(trx.id)?.status, 'selesai');
      expect(provider.riwayatSelesai.length, 1);
    });
  });
}
