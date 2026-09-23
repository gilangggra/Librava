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
