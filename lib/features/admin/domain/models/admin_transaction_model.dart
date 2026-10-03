class AdminTransactionModel {
  final String id;
  final String tipeTransaksi;
  final String status;
  final double depositDummy;
  final String? lokasiPertemuan;
  final String? waktuPertemuan;
  final String createdAt;
  final String updatedAt;
  final String requesterNama;
  final String requesterEmail;
  final String ownerNama;
  final String ownerEmail;
  final String bookJudul;
  final String? bookFoto;
  final String? bookPenulis;
  final int? barterBookId;

  const AdminTransactionModel({
    required this.id,
    required this.tipeTransaksi,
    required this.status,
    this.depositDummy = 0,
    this.lokasiPertemuan,
    this.waktuPertemuan,
    this.createdAt = '',
    this.updatedAt = '',
    this.requesterNama = '',
    this.requesterEmail = '',
    this.ownerNama = '',
    this.ownerEmail = '',
    this.bookJudul = '',
    this.bookFoto,
    this.bookPenulis,
    this.barterBookId,
  });

  factory AdminTransactionModel.fromJson(Map<String, dynamic> json) {
    return AdminTransactionModel(
      id: json['id']?.toString() ?? '',
      tipeTransaksi: json['tipe_transaksi']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      depositDummy: (json['deposit_dummy'] as num?)?.toDouble() ?? 0,
      lokasiPertemuan: json['lokasi_pertemuan']?.toString(),
      waktuPertemuan: json['waktu_pertemuan']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      requesterNama: json['requester_nama']?.toString() ?? '',
      requesterEmail: json['requester_email']?.toString() ?? '',
      ownerNama: json['owner_nama']?.toString() ?? '',
      ownerEmail: json['owner_email']?.toString() ?? '',
      bookJudul: json['book_judul']?.toString() ?? '',
      bookFoto: json['book_foto']?.toString(),
      bookPenulis: json['book_penulis']?.toString(),
      barterBookId: (json['barter_book_id'] as num?)?.toInt(),
    );
  }

  String get tipeTampil {
    if (tipeTransaksi == 'PINJAM') return 'Borrow';
    if (tipeTransaksi == 'BARTER') return 'Barter';
    return tipeTransaksi;
  }

  String get statusTampil {
    switch (status) {
      case 'MENUNGGU_KONFIRMASI':
        return 'Pending';
      case 'DISETUJUI':
        return 'Accepted';
      case 'DALAM_PROSES':
        return 'In Progress';
      case 'SELESAI':
        return 'Completed';
      case 'DITOLAK':
        return 'Rejected';
      case 'DIBATALKAN':
        return 'Cancelled';
      default:
        return 'Incompleted';
    }
  }

  bool get isSelesai => status == 'SELESAI';

  String get tanggalDibuat {
    if (createdAt.isEmpty) return '-';
    return createdAt.split('T').first;
  }

  String get depositFormatted {
    if (depositDummy == 0) return '-';
    final angka = depositDummy.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return '$angka Rupiah';
  }
}
