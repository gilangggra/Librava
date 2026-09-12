class TransactionModel {
  final String id;
  final String bukuId;
  final String judulBuku;
  final String pemohonNama;
  final String jenisTransaksi;
  final int durasiHari;
  final String bukuBarter;
  final double depositSimulasi;
  final String status;
  final String tanggal;

  const TransactionModel({
    required this.id,
    required this.bukuId,
    required this.judulBuku,
    required this.pemohonNama,
    required this.jenisTransaksi,
    this.durasiHari = 7,
    this.bukuBarter = '',
    this.depositSimulasi = 0.0,
    this.status = 'pending',
    required this.tanggal,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      bukuId: json['bukuId'] ?? '',
      judulBuku: json['judulBuku'] ?? '',
      pemohonNama: json['pemohonNama'] ?? '',
      jenisTransaksi: json['jenisTransaksi'] ?? 'pinjam',
      durasiHari: json['durasiHari'] ?? 7,
      bukuBarter: json['bukuBarter'] ?? '',
      depositSimulasi: (json['depositSimulasi'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      tanggal: json['tanggal'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bukuId': bukuId,
      'judulBuku': judulBuku,
      'pemohonNama': pemohonNama,
      'jenisTransaksi': jenisTransaksi,
      'durasiHari': durasiHari,
      'bukuBarter': bukuBarter,
      'depositSimulasi': depositSimulasi,
      'status': status,
      'tanggal': tanggal,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? bukuId,
    String? judulBuku,
    String? pemohonNama,
    String? jenisTransaksi,
    int? durasiHari,
    String? bukuBarter,
    double? depositSimulasi,
    String? status,
    String? tanggal,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      bukuId: bukuId ?? this.bukuId,
      judulBuku: judulBuku ?? this.judulBuku,
      pemohonNama: pemohonNama ?? this.pemohonNama,
      jenisTransaksi: jenisTransaksi ?? this.jenisTransaksi,
      durasiHari: durasiHari ?? this.durasiHari,
      bukuBarter: bukuBarter ?? this.bukuBarter,
      depositSimulasi: depositSimulasi ?? this.depositSimulasi,
      status: status ?? this.status,
      tanggal: tanggal ?? this.tanggal,
    );
  }
}
