class BookModel {
  final String id;
  final String judul;
  final String penulis;
  final String kategori;
  final int tahunTerbit;
  final bool tersedia;
  final double rating;
  final String deskripsi;
  final String? fotoBuku;
  final String? pemilikId;
  final String? pemilikNama;
  final String? pemilikUniversitas;
  final String statusModerasi;
  final String? catatanModerasi;

  const BookModel({
    required this.id,
    required this.judul,
    required this.penulis,
    required this.kategori,
    required this.tahunTerbit,
    this.tersedia = true,
    this.rating = 0.0,
    this.deskripsi = '',
    this.fotoBuku,
    this.pemilikId,
    this.pemilikNama,
    this.pemilikUniversitas,
    this.statusModerasi = 'DISETUJUI',
    this.catatanModerasi,
  });

  bool get isPending => statusModerasi.toUpperCase() == 'PENDING';
  bool get isDisetujui => statusModerasi.toUpperCase() == 'DISETUJUI';
  bool get isDitolak => statusModerasi.toUpperCase() == 'DITOLAK';

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] ?? '',
      judul: json['judul'] ?? '',
      penulis: json['penulis'] ?? '',
      kategori: json['kategori'] ?? 'Umum',
      tahunTerbit: json['tahunTerbit'] ?? 0,
      tersedia: json['tersedia'] ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      deskripsi: json['deskripsi'] ?? '',
      pemilikId: json['pemilikId'] ?? json['owner_id']?.toString(),
      pemilikNama: json['pemilikNama'] ?? json['owner_nama'],
      statusModerasi: json['statusModerasi'] ?? 'DISETUJUI',
      catatanModerasi: json['catatanModerasi'],
    );
  }

  factory BookModel.fromApiJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'Tersedia';
    final tersedia = statusStr == 'Tersedia';
    return BookModel(
      id: json['id']?.toString() ?? '',
      judul: json['judul'] as String? ?? '',
      penulis: json['penulis'] as String? ?? '',
      kategori: json['kategori'] as String? ?? 'Umum',
      tahunTerbit: 0,
      tersedia: tersedia,
      rating: 0.0,
      deskripsi: json['deskripsi'] as String? ?? '',
      fotoBuku: json['foto_buku'] as String?,
      pemilikId: json['owner_id']?.toString(),
      pemilikNama: json['owner_nama'] as String?,
      pemilikUniversitas: json['owner_universitas'] as String?,
      statusModerasi: json['status_moderasi'] as String? ?? 'DISETUJUI',
      catatanModerasi: json['catatan_moderasi'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'penulis': penulis,
      'kategori': kategori,
      'tahunTerbit': tahunTerbit,
      'tersedia': tersedia,
      'rating': rating,
      'deskripsi': deskripsi,
      'pemilikId': pemilikId,
      'pemilikNama': pemilikNama,
      'status_moderasi': statusModerasi,
      'catatan_moderasi': catatanModerasi,
    };
  }

  BookModel copyWith({
    String? id,
    String? judul,
    String? penulis,
    String? kategori,
    int? tahunTerbit,
    bool? tersedia,
    double? rating,
    String? deskripsi,
    String? fotoBuku,
    String? pemilikId,
    String? pemilikNama,
    String? pemilikUniversitas,
    String? statusModerasi,
    String? catatanModerasi,
  }) {
    return BookModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      penulis: penulis ?? this.penulis,
      kategori: kategori ?? this.kategori,
      tahunTerbit: tahunTerbit ?? this.tahunTerbit,
      tersedia: tersedia ?? this.tersedia,
      rating: rating ?? this.rating,
      deskripsi: deskripsi ?? this.deskripsi,
      fotoBuku: fotoBuku ?? this.fotoBuku,
      pemilikId: pemilikId ?? this.pemilikId,
      pemilikNama: pemilikNama ?? this.pemilikNama,
      pemilikUniversitas: pemilikUniversitas ?? this.pemilikUniversitas,
      statusModerasi: statusModerasi ?? this.statusModerasi,
      catatanModerasi: catatanModerasi ?? this.catatanModerasi,
    );
  }

  @override
  String toString() {
    return 'BookModel(id: $id, judul: $judul, penulis: $penulis, kategori: $kategori, tahun: $tahunTerbit, tersedia: $tersedia, rating: $rating, moderasi: $statusModerasi)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
