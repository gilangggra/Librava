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
  final String? status;

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
    this.status,
  });

  /// Mengambil status event untuk badge tampilan: Approved, Pending, Rejected
  String get displayStatus {
    if (status != null && status!.trim().isNotEmpty) {
      final s = status!.toUpperCase();
      if (s.contains('REJECT')) return 'Rejected';
      if (s.contains('PEND')) return 'Pending';
      if (s.contains('APPR')) return 'Approved';
      return status!;
    }
    return 'Approved';
  }

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
      tanggalMulai: (json['tanggal_mulai'] ?? json['tanggalMulai']) != null
          ? DateTime.tryParse((json['tanggal_mulai'] ?? json['tanggalMulai']).toString()) ??
              DateTime.now()
          : DateTime.now(),
      tanggalSelesai: (json['tanggal_selesai'] ?? json['tanggalSelesai']) != null
          ? DateTime.tryParse((json['tanggal_selesai'] ?? json['tanggalSelesai']).toString())
          : null,
      kuota: json['kuota'] is int
          ? json['kuota']
          : int.tryParse(json['kuota']?.toString() ?? '100') ?? 100,
      fotoEvent: (json['foto_event'] ?? json['fotoEvent']) as String?,
      createdById: (json['created_by_id'] ?? json['createdById']) is int
          ? (json['created_by_id'] ?? json['createdById'])
          : int.tryParse((json['created_by_id'] ?? json['createdById'])?.toString() ?? '1') ?? 1,
      jumlahPendaftar: (json['jumlah_pendaftar'] ?? json['jumlahPendaftar']) is int
          ? (json['jumlah_pendaftar'] ?? json['jumlahPendaftar'])
          : int.tryParse((json['jumlah_pendaftar'] ?? json['jumlahPendaftar'])?.toString() ?? '0') ?? 0,
      status: json['status'] as String?,
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
      'status': status,
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
    String? status,
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
      status: status ?? this.status,
    );
  }
}
