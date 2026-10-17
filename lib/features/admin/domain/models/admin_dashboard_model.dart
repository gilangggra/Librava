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
        final rawStatus = item['status']?.toString() ?? 'MENUNGGU_KONFIRMASI';

        String activityStatus = 'Pending';
        if (rawStatus == 'DISETUJUI' || rawStatus == 'DALAM_PROSES') {
          activityStatus = 'Accepted';
        } else if (rawStatus == 'SELESAI') {
          activityStatus = 'Completed';
        } else if (rawStatus == 'DITOLAK' || rawStatus == 'DIBATALKAN') {
          activityStatus = 'Rejected';
        }

        String txStatus = 'Incompleted';
        if (rawStatus == 'SELESAI') {
          txStatus = 'Completed';
        }

        String cover = (item['book_foto']?.toString() ?? '').trim();
        if (cover.isEmpty) {
          final lowTitle = bookTitle.toLowerCase();
          if (lowTitle.contains('fruit')) {
            cover = 'assets/images/book_fruit_fly.jpg';
          } else if (lowTitle.contains('adversary') ||
              lowTitle.contains('filosofi')) {
            cover = 'assets/images/book_adversary.jpg';
          } else if (lowTitle.contains('atomic')) {
            cover = 'assets/images/book_atomic_habits.jpg';
          } else if (lowTitle.contains('midnight')) {
            cover = 'assets/images/book_midnight_lib.jpg';
          } else {
            cover = 'assets/images/bookshelf.jpg';
          }
        }

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
