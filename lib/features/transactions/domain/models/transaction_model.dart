class TransactionModel {
  final String id;
  final String bukuId;
  final String judulBuku;
  final String pemohonNama;
  final String pemilikNama;
  final String jenisTransaksi;
  final int durasiHari;
  final String bukuBarter;
  final double depositSimulasi;
  final String status;
  final String lokasiPertemuan;
  final String tanggal;
  final String tanggalPengembalian;
  final String coverBuku;

  const TransactionModel({
    required this.id,
    required this.bukuId,
    required this.judulBuku,
    required this.pemohonNama,
    this.pemilikNama = 'Andi (dummy)',
    required this.jenisTransaksi,
    this.durasiHari = 7,
    this.bukuBarter = '',
    this.depositSimulasi = 0.0,
    this.status = 'pending',
    this.lokasiPertemuan = '',
    required this.tanggal,
    this.tanggalPengembalian = '',
    this.coverBuku = 'assets/images/book_the_unknown.jpg',
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      bukuId: json['bukuId'] ?? '',
      judulBuku: json['judulBuku'] ?? '',
      pemohonNama: json['pemohonNama'] ?? '',
      pemilikNama: json['pemilikNama'] ?? 'Andi (dummy)',
      jenisTransaksi: json['jenisTransaksi'] ?? 'pinjam',
      durasiHari: json['durasiHari'] ?? 7,
      bukuBarter: json['bukuBarter'] ?? '',
      depositSimulasi: (json['depositSimulasi'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      lokasiPertemuan: json['lokasiPertemuan'] ?? '',
      tanggal: json['tanggal'] ?? '',
      tanggalPengembalian: json['tanggalPengembalian'] ?? '',
      coverBuku: json['coverBuku'] ?? 'assets/images/book_the_unknown.jpg',
    );
  }

  factory TransactionModel.fromApiJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] as String? ?? 'MENUNGGU_KONFIRMASI');
    final String normalizedStatus;
    switch (rawStatus) {
      case 'MENUNGGU_KONFIRMASI':
        normalizedStatus = 'pending';
        break;
      case 'DISETUJUI':
        normalizedStatus = 'disetujui';
        break;
      case 'DITOLAK':
        normalizedStatus = 'ditolak';
        break;
      case 'DIBATALKAN':
        normalizedStatus = 'dibatalkan';
        break;
      case 'DALAM_PROSES':
        normalizedStatus = 'lokasi_ditentukan';
        break;
      case 'SELESAI':
        normalizedStatus = 'selesai';
        break;
      default:
        normalizedStatus = rawStatus.toLowerCase();
    }

    final rawTipe = (json['tipe_transaksi'] as String? ?? 'BORROW');
    final String jenis = rawTipe == 'BARTER' ? 'barter' : 'pinjam';

    final createdAt = json['created_at'] as String?;
    final tanggal = createdAt != null ? createdAt.split('T').first : '';

    final returnedAt = json['returned_at'] as String?;
    final tanggalPengembalian = returnedAt != null ? returnedAt.split('T').first : '';

    return TransactionModel(
      id: json['id']?.toString() ?? '',
      bukuId: json['book_id']?.toString() ?? '',
      judulBuku: json['book_judul'] as String? ?? '',
      pemohonNama: json['requester_nama'] as String? ?? '',
      pemilikNama: json['owner_nama'] as String? ?? '',
      jenisTransaksi: jenis,
      durasiHari: (json['durasi_hari'] as num?)?.toInt() ?? 7,
      bukuBarter: json['barter_book_judul'] as String? ?? '',
      depositSimulasi: (json['deposit_dummy'] as num?)?.toDouble() ?? 0.0,
      status: normalizedStatus,
      lokasiPertemuan: json['lokasi_pertemuan'] as String? ?? '',
      tanggal: tanggal,
      tanggalPengembalian: tanggalPengembalian,
      coverBuku: json['book_foto'] as String? ?? 'assets/images/book_the_unknown.jpg',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bukuId': bukuId,
      'judulBuku': judulBuku,
      'pemohonNama': pemohonNama,
      'pemilikNama': pemilikNama,
      'jenisTransaksi': jenisTransaksi,
      'durasiHari': durasiHari,
      'bukuBarter': bukuBarter,
      'depositSimulasi': depositSimulasi,
      'status': status,
      'lokasiPertemuan': lokasiPertemuan,
      'tanggal': tanggal,
      'tanggalPengembalian': tanggalPengembalian,
      'coverBuku': coverBuku,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? bukuId,
    String? judulBuku,
    String? pemohonNama,
    String? pemilikNama,
    String? jenisTransaksi,
    int? durasiHari,
    String? bukuBarter,
    double? depositSimulasi,
    String? status,
    String? lokasiPertemuan,
    String? tanggal,
    String? tanggalPengembalian,
    String? coverBuku,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      bukuId: bukuId ?? this.bukuId,
      judulBuku: judulBuku ?? this.judulBuku,
      pemohonNama: pemohonNama ?? this.pemohonNama,
      pemilikNama: pemilikNama ?? this.pemilikNama,
      jenisTransaksi: jenisTransaksi ?? this.jenisTransaksi,
      durasiHari: durasiHari ?? this.durasiHari,
      bukuBarter: bukuBarter ?? this.bukuBarter,
      depositSimulasi: depositSimulasi ?? this.depositSimulasi,
      status: status ?? this.status,
      lokasiPertemuan: lokasiPertemuan ?? this.lokasiPertemuan,
      tanggal: tanggal ?? this.tanggal,
      tanggalPengembalian: tanggalPengembalian ?? this.tanggalPengembalian,
      coverBuku: coverBuku ?? this.coverBuku,
    );
  }
}
