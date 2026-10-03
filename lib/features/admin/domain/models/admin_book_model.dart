class AdminBookModel {
  final String id;
  final String judul;
  final String penulis;
  final String penerbit;
  final String isbn;
  final String kategori;
  final String status;
  final String deskripsi;
  final String? fotoBuku;
  final String pemilikNama;
  final String pemilikUniversitas;

  const AdminBookModel({
    required this.id,
    required this.judul,
    required this.penulis,
    this.penerbit = '',
    this.isbn = '',
    this.kategori = '',
    this.status = 'Tersedia',
    this.deskripsi = '',
    this.fotoBuku,
    this.pemilikNama = '',
    this.pemilikUniversitas = '',
  });

  factory AdminBookModel.fromJson(Map<String, dynamic> json) {
    return AdminBookModel(
      id: json['id']?.toString() ?? '',
      judul: json['judul'] as String? ?? '',
      penulis: json['penulis'] as String? ?? '',
      penerbit: json['penerbit'] as String? ?? '',
      isbn: json['isbn'] as String? ?? '',
      kategori: json['kategori'] as String? ?? '',
      status: json['status'] as String? ?? 'Tersedia',
      deskripsi: json['deskripsi'] as String? ?? '',
      fotoBuku: json['foto_buku'] as String?,
      pemilikNama: json['owner_nama'] as String? ?? '',
      pemilikUniversitas: json['owner_universitas'] as String? ?? '',
    );
  }

  List<String> get daftarGenre {
    if (kategori.trim().isEmpty) {
      return [];
    }
    return kategori
        .split(RegExp(r'[/,]'))
        .map((genre) => genre.trim())
        .where((genre) => genre.isNotEmpty)
        .toList();
  }

  String get genreTampil {
    final genre = daftarGenre;
    return genre.isEmpty ? '-' : genre.join('/');
  }

  String get statusTampil {
    if (status == 'Tersedia') {
      return 'Available';
    } else if (status == 'Dipinjam') {
      return 'Borrowed';
    } else if (status == 'Dibarter') {
      return 'Bartered';
    }
    return status;
  }

  bool get punyaFotoOnline {
    final foto = fotoBuku ?? '';
    return foto.startsWith('http://') || foto.startsWith('https://');
  }

  bool get punyaFotoAsset {
    final foto = fotoBuku ?? '';
    return foto.startsWith('assets/');
  }
}
