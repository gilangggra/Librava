class BookModel {
  final String id;
  final String judul;
  final String penulis;
  final String kategori;
  final int tahunTerbit;
  final bool tersedia;
  final double rating;
  final String deskripsi;

  const BookModel({
    required this.id,
    required this.judul,
    required this.penulis,
    required this.kategori,
    required this.tahunTerbit,
    this.tersedia = true,
    this.rating = 0.0,
    this.deskripsi = '',
  });

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
    );
  }

  @override
  String toString() {
    return 'BookModel(id: $id, judul: $judul, penulis: $penulis, kategori: $kategori, tahun: $tahunTerbit, tersedia: $tersedia, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
