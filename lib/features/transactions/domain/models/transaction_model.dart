import '../../../../core/utils/book_cover_helper.dart';

class TransactionModel {
  final String id;
  final String bukuId;
  final String judulBuku;
  final String penulisBuku;
  final String pemohonId;
  final String pemohonNama;
  final String pemilikId;
  final String pemilikNama;
  final String jenisTransaksi;
  final int durasiHari;
  final String bukuBarter;
  final String barterPenulis;
  final String barterCover;
  final double depositSimulasi;
  final String status;
  final String lokasiPertemuan;
  final String tanggal;
  final String tanggalPengembalian;
  final String coverBuku;
  final DateTime? dueDate;
  final DateTime? requesterConfirmedAt;
  final DateTime? ownerConfirmedAt;

  const TransactionModel({
    required this.id,
    required this.bukuId,
    required this.judulBuku,
    this.penulisBuku = 'Penulis',
    this.pemohonId = '',
    required this.pemohonNama,
    this.pemilikId = '',
    this.pemilikNama = 'Pemilik Buku',
    required this.jenisTransaksi,
    this.durasiHari = 7,
    this.bukuBarter = '',
    this.barterPenulis = '',
    this.barterCover = '',
    this.depositSimulasi = 0.0,
    this.status = 'pending',
    this.lokasiPertemuan = '',
    required this.tanggal,
    this.tanggalPengembalian = '',
    this.coverBuku = 'assets/images/book_the_unknown.jpg',
    this.dueDate,
    this.requesterConfirmedAt,
    this.ownerConfirmedAt,
  });

  DateTime? get effectiveDueDate {
    if (dueDate != null) return dueDate;
    if (jenisTransaksi.toLowerCase() == 'pinjam' && tanggal.isNotEmpty && durasiHari > 0) {
      try {
        final tgl = DateTime.parse(tanggal);
        return tgl.add(Duration(days: durasiHari));
      } catch (_) {}
    }
    return null;
  }

  bool get isOverdue {
    if (jenisTransaksi.toLowerCase() != 'pinjam') return false;
    final s = status.toLowerCase();
    // Overdue HANYA berlaku saat buku sedang aktif dipinjam oleh peminjam
    if (s != 'sedang_dipinjam') {
      return false;
    }
    final due = effectiveDueDate;
    if (due == null) return false;
    return DateTime.now().isAfter(due);
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDueDate;
    if (json['dueDate'] != null) {
      parsedDueDate = DateTime.tryParse(json['dueDate'].toString());
    } else if (json['due_date'] != null) {
      parsedDueDate = DateTime.tryParse(json['due_date'].toString());
    }

    return TransactionModel(
      id: json['id'] ?? '',
      bukuId: json['bukuId'] ?? '',
      judulBuku: json['judulBuku'] ?? '',
      pemohonNama: json['pemohonNama'] ?? '',
      pemilikNama: json['pemilikNama'] ?? 'Pemilik Buku',
      jenisTransaksi: json['jenisTransaksi'] ?? 'pinjam',
      durasiHari: json['durasiHari'] ?? 7,
      bukuBarter: json['bukuBarter'] ?? '',
      depositSimulasi: (json['depositSimulasi'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      lokasiPertemuan: json['lokasiPertemuan'] ?? '',
      tanggal: json['tanggal'] ?? '',
      tanggalPengembalian: json['tanggalPengembalian'] ?? '',
      coverBuku: json['coverBuku'] ?? 'assets/images/book_the_unknown.jpg',
      dueDate: parsedDueDate,
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
      case 'SEDANG_DIPINJAM':
        normalizedStatus = 'sedang_dipinjam';
        break;
      case 'SELESAI':
        normalizedStatus = 'selesai';
        break;
      default:
        normalizedStatus = rawStatus.toLowerCase();
    }

    final rawTipe = (json['tipe_transaksi'] as String? ?? 'BORROW').trim().toUpperCase();
    final String jenis = rawTipe == 'BARTER' ? 'barter' : 'pinjam';

    final createdAt = json['created_at'] as String?;
    final tanggal = createdAt != null ? createdAt.split('T').first : '';

    final returnedAt = json['returned_at'] as String?;
    final tanggalPengembalian = returnedAt != null ? returnedAt.split('T').first : '';

    final rawDueDate = json['due_date'] as String?;
    DateTime? dueDate;
    if (rawDueDate != null) {
      dueDate = DateTime.tryParse(rawDueDate);
    }

    final rawReqConf = json['requester_confirmed_at'] as String?;
    DateTime? requesterConfirmedAt;
    if (rawReqConf != null) {
      requesterConfirmedAt = DateTime.tryParse(rawReqConf);
    }

    final rawOwnConf = json['owner_confirmed_at'] as String?;
    DateTime? ownerConfirmedAt;
    if (rawOwnConf != null) {
      ownerConfirmedAt = DateTime.tryParse(rawOwnConf);
    }

    return TransactionModel(
      id: json['id']?.toString() ?? '',
      bukuId: json['book_id']?.toString() ?? '',
      judulBuku: json['book_judul'] as String? ?? '',
      penulisBuku: json['book_penulis'] as String? ?? 'Penulis',
      pemohonId: json['requester_id']?.toString() ?? '',
      pemohonNama: json['requester_nama'] as String? ?? '',
      pemilikId: json['owner_id']?.toString() ?? '',
      pemilikNama: json['owner_nama'] as String? ?? '',
      jenisTransaksi: jenis,
      durasiHari: (json['durasi_hari'] as num?)?.toInt() ?? 7,
      bukuBarter: json['barter_book_judul'] as String? ?? '',
      barterPenulis: json['barter_book_penulis'] as String? ?? '',
      barterCover: BookCoverHelper.getCover(
        fotoBuku: json['barter_book_foto'] as String?,
        judul: json['barter_book_judul'] as String? ?? '',
      ),
      depositSimulasi: (json['deposit_dummy'] as num?)?.toDouble() ?? 0.0,
      status: normalizedStatus,
      lokasiPertemuan: json['lokasi_pertemuan'] as String? ?? '',
      tanggal: tanggal,
      tanggalPengembalian: tanggalPengembalian,
      coverBuku: BookCoverHelper.getCover(
        fotoBuku: json['book_foto'] as String?,
        judul: json['book_judul'] as String? ?? '',
      ),
      dueDate: dueDate,
      requesterConfirmedAt: requesterConfirmedAt,
      ownerConfirmedAt: ownerConfirmedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bukuId': bukuId,
      'judulBuku': judulBuku,
      'penulisBuku': penulisBuku,
      'pemohonId': pemohonId,
      'pemohonNama': pemohonNama,
      'pemilikId': pemilikId,
      'pemilikNama': pemilikNama,
      'jenisTransaksi': jenisTransaksi,
      'durasiHari': durasiHari,
      'bukuBarter': bukuBarter,
      'barterPenulis': barterPenulis,
      'barterCover': barterCover,
      'depositSimulasi': depositSimulasi,
      'status': status,
      'lokasiPertemuan': lokasiPertemuan,
      'tanggal': tanggal,
      'tanggalPengembalian': tanggalPengembalian,
      'coverBuku': coverBuku,
      'dueDate': dueDate?.toIso8601String(),
      'requester_confirmed_at': requesterConfirmedAt?.toIso8601String(),
      'owner_confirmed_at': ownerConfirmedAt?.toIso8601String(),
    };
  }

  TransactionModel copyWith({
    String? id,
    String? bukuId,
    String? judulBuku,
    String? penulisBuku,
    String? pemohonId,
    String? pemohonNama,
    String? pemilikId,
    String? pemilikNama,
    String? jenisTransaksi,
    int? durasiHari,
    String? bukuBarter,
    String? barterPenulis,
    String? barterCover,
    double? depositSimulasi,
    String? status,
    String? lokasiPertemuan,
    String? tanggal,
    String? tanggalPengembalian,
    String? coverBuku,
    DateTime? dueDate,
    DateTime? requesterConfirmedAt,
    DateTime? ownerConfirmedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      bukuId: bukuId ?? this.bukuId,
      judulBuku: judulBuku ?? this.judulBuku,
      penulisBuku: penulisBuku ?? this.penulisBuku,
      pemohonId: pemohonId ?? this.pemohonId,
      pemohonNama: pemohonNama ?? this.pemohonNama,
      pemilikId: pemilikId ?? this.pemilikId,
      pemilikNama: pemilikNama ?? this.pemilikNama,
      jenisTransaksi: jenisTransaksi ?? this.jenisTransaksi,
      durasiHari: durasiHari ?? this.durasiHari,
      bukuBarter: bukuBarter ?? this.bukuBarter,
      barterPenulis: barterPenulis ?? this.barterPenulis,
      barterCover: barterCover ?? this.barterCover,
      depositSimulasi: depositSimulasi ?? this.depositSimulasi,
      status: status ?? this.status,
      lokasiPertemuan: lokasiPertemuan ?? this.lokasiPertemuan,
      tanggal: tanggal ?? this.tanggal,
      tanggalPengembalian: tanggalPengembalian ?? this.tanggalPengembalian,
      coverBuku: coverBuku ?? this.coverBuku,
      dueDate: dueDate ?? this.dueDate,
      requesterConfirmedAt: requesterConfirmedAt ?? this.requesterConfirmedAt,
      ownerConfirmedAt: ownerConfirmedAt ?? this.ownerConfirmedAt,
    );
  }
}
