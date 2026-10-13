class EventModel {
  final int id;
  final String judul;
  final String deskripsi;
  final String kategori;
  final String lokasi;
  final DateTime tanggalMulai;
  final DateTime? tanggalSelesai;
  final int kuota;
  final String? fotoEvent;
  final int createdById;
  final int jumlahPendaftar;

  const EventModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    this.kategori = 'Umum',
    required this.lokasi,
    required this.tanggalMulai,
    this.tanggalSelesai,
    this.kuota = 100,
    this.fotoEvent,
    this.createdById = 1,
    this.jumlahPendaftar = 0,
  });

  /// Menghitung sisa kuota yang masih tersedia
  int get sisaKuota => (kuota - jumlahPendaftar).clamp(0, kuota);

  /// Mengecek apakah kuota pendaftaran sudah habis
  bool get isPenuh => sisaKuota <= 0;

  /// Membaca data JSON dari response API Backend
  factory EventModel.fromApiJson(Map<String, dynamic> json) =>
      EventModel.fromJson(json);

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      judul: json['judul'] as String? ?? 'Event Kampus',
      deskripsi: json['deskripsi'] as String? ?? '',
      kategori: json['kategori'] as String? ?? 'Umum',
      lokasi: json['lokasi'] as String? ?? 'Telkom University',
      tanggalMulai: json['tanggal_mulai'] != null
          ? DateTime.tryParse(json['tanggal_mulai'].toString()) ??
              DateTime.now()
          : DateTime.now(),
      tanggalSelesai: json['tanggal_selesai'] != null
          ? DateTime.tryParse(json['tanggal_selesai'].toString())
          : null,
      kuota: json['kuota'] is int
          ? json['kuota']
          : int.tryParse(json['kuota']?.toString() ?? '100') ?? 100,
      fotoEvent: json['foto_event'] as String?,
      createdById: json['created_by_id'] is int
          ? json['created_by_id']
          : int.tryParse(json['created_by_id']?.toString() ?? '1') ?? 1,
      jumlahPendaftar: json['jumlah_pendaftar'] is int
          ? json['jumlah_pendaftar']
          : int.tryParse(json['jumlah_pendaftar']?.toString() ?? '0') ?? 0,
    );
  }

  /// Konversi model ke Map JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'lokasi': lokasi,
      'tanggal_mulai': tanggalMulai.toIso8601String(),
      'tanggal_selesai': tanggalSelesai?.toIso8601String(),
      'kuota': kuota,
      'foto_event': fotoEvent,
      'created_by_id': createdById,
      'jumlah_pendaftar': jumlahPendaftar,
    };
  }

  EventModel copyWith({
    int? id,
    String? judul,
    String? deskripsi,
    String? kategori,
    String? lokasi,
    DateTime? tanggalMulai,
    DateTime? tanggalSelesai,
    int? kuota,
    String? fotoEvent,
    int? createdById,
    int? jumlahPendaftar,
  }) {
    return EventModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      kategori: kategori ?? this.kategori,
      lokasi: lokasi ?? this.lokasi,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalSelesai: tanggalSelesai ?? this.tanggalSelesai,
      kuota: kuota ?? this.kuota,
      fotoEvent: fotoEvent ?? this.fotoEvent,
      createdById: createdById ?? this.createdById,
      jumlahPendaftar: jumlahPendaftar ?? this.jumlahPendaftar,
    );
  }
}
