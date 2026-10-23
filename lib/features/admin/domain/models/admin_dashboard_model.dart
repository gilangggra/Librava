import '../../../../core/utils/book_cover_helper.dart';

class AdminActivityItem {
  final String id;
  final String title;
  final String author;
  final String coverPath;
  final String type;
  final String personName;
  final String status;

  const AdminActivityItem({
    required this.id,
    required this.title,
    required this.author,
    required this.coverPath,
    required this.type,
    required this.personName,
    required this.status,
  });

  factory AdminActivityItem.fromJson(Map<String, dynamic> json) {
    return AdminActivityItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['book_judul'] ?? 'Buku Kampus',
      author: json['author'] ?? 'Penulis',
      coverPath: json['coverPath'] ?? json['cover_path'] ?? 'assets/images/bookshelf.jpg',
      type: json['type'] ?? json['tipe_transaksi'] ?? 'Pinjam',
      personName: json['personName'] ?? json['requester_nama'] ?? json['owner_nama'] ?? 'Mahasiswa',
      status: json['status'] ?? 'Pending',
    );
  }
}

class AdminTransactionItem {
  final String id;
  final String title;
  final String author;
  final String coverPath;
  final String type;
  final String personName;
  final String status;

  const AdminTransactionItem({
    required this.id,
    required this.title,
    required this.author,
    required this.coverPath,
    required this.type,
    required this.personName,
    required this.status,
  });

  factory AdminTransactionItem.fromJson(Map<String, dynamic> json) {
    return AdminTransactionItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['book_judul'] ?? 'Buku Kampus',
      author: json['author'] ?? 'Penulis',
      coverPath: json['coverPath'] ?? json['cover_path'] ?? 'assets/images/bookshelf.jpg',
      type: json['type'] ?? json['tipe_transaksi'] ?? 'Pinjam',
      personName: json['personName'] ?? json['requester_nama'] ?? json['owner_nama'] ?? 'Mahasiswa',
      status: json['status'] ?? 'Incompleted',
    );
  }
}

class AdminDashboardModel {
  final int totalStudents;
  final int totalBooks;
  final int totalRequests;
  final int totalTransactions;
  final List<AdminActivityItem> recentActivity;
  final List<AdminTransactionItem> recentTransactions;

  const AdminDashboardModel({
    this.totalStudents = 0,
    this.totalBooks = 0,
    this.totalRequests = 0,
    this.totalTransactions = 0,
    this.recentActivity = const [],
    this.recentTransactions = const [],
  });

  factory AdminDashboardModel.fromApiJson(Map<String, dynamic> json) {
    final usersData = json['users'] as Map<String, dynamic>?;
    final booksData = json['books'] as Map<String, dynamic>?;
    final txData = json['transactions'] as Map<String, dynamic>?;
    final rawRecentTx = json['recent_transactions'] as List<dynamic>? ?? [];

    final studentsCount = (usersData?['mahasiswa'] as num?)?.toInt() ??
        (usersData?['total'] as num?)?.toInt() ??
        0;
    final booksCount = (booksData?['total'] as num?)?.toInt() ?? 0;
    final requestsCount =
        (txData?['menunggu_konfirmasi'] as num?)?.toInt() ?? 0;
    final txCount = (txData?['total'] as num?)?.toInt() ?? 0;

    final List<AdminActivityItem> activities = [];
    final List<AdminTransactionItem> transactions = [];

    for (final item in rawRecentTx) {
      if (item is Map<String, dynamic>) {
        final bookTitle = item['book_judul']?.toString() ?? 'Buku Kampus';
        final rawType =
            item['tipe_transaksi']?.toString().toLowerCase() ?? 'pinjam';
        final type = rawType == 'barter' ? 'Barter' : 'Borrow';
        final person = item['requester_nama']?.toString() ??
            item['owner_nama']?.toString() ??
            'Mahasiswa';
        final normStatus = (item['status']?.toString() ?? 'MENUNGGU_KONFIRMASI').trim().toUpperCase();

        String activityStatus = 'Pending';
        if (normStatus == 'DISETUJUI' ||
            normStatus == 'ACCEPTED' ||
            normStatus == 'DALAM_PROSES' ||
            normStatus == 'DEPOSIT_DIBAYAR' ||
            normStatus == 'LOKASI_DITENTUKAN') {
          activityStatus = 'Accepted';
        } else if (normStatus == 'SEDANG_DIPINJAM' || normStatus == 'ON_LOAN') {
          activityStatus = 'On Loan';
        } else if (normStatus == 'SELESAI' || normStatus == 'COMPLETED') {
          activityStatus = 'Completed';
        } else if (normStatus == 'DITOLAK' ||
            normStatus == 'REJECTED' ||
            normStatus == 'DIBATALKAN' ||
            normStatus == 'CANCELLED') {
          activityStatus = 'Rejected';
        }

        String txStatus = 'In Progress';
        if (normStatus == 'SELESAI' || normStatus == 'COMPLETED') {
          txStatus = 'Completed';
        } else if (normStatus == 'SEDANG_DIPINJAM' || normStatus == 'ON_LOAN') {
          txStatus = 'On Loan';
        } else if (normStatus == 'MENUNGGU_KONFIRMASI' || normStatus == 'PENDING') {
          txStatus = 'Pending';
        } else if (normStatus == 'DITOLAK' ||
            normStatus == 'REJECTED' ||
            normStatus == 'DIBATALKAN' ||
            normStatus == 'CANCELLED') {
          txStatus = 'Rejected';
        }

        final String cover = BookCoverHelper.getCover(
          fotoBuku: item['book_foto']?.toString(),
          judul: bookTitle,
        );

        final rawAuthor = (item['book_penulis']?.toString() ?? '').trim();
        final author = rawAuthor.isNotEmpty ? rawAuthor : 'Penulis Kampus';

        activities.add(AdminActivityItem(
          id: item['id']?.toString() ?? '',
          title: bookTitle,
          author: author,
          coverPath: cover,
          type: type,
          personName: person.split(' ').first,
          status: activityStatus,
        ));

        transactions.add(AdminTransactionItem(
          id: item['id']?.toString() ?? '',
          title: bookTitle,
          author: author,
          coverPath: cover,
          type: type,
          personName: person.split(' ').first,
          status: txStatus,
        ));
      }
    }

    return AdminDashboardModel(
      totalStudents: studentsCount,
      totalBooks: booksCount,
      totalRequests: requestsCount,
      totalTransactions: txCount,
      recentActivity: activities,
      recentTransactions: transactions,
    );
  }
}
