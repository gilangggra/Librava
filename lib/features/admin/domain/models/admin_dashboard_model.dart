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
      title: json['title'] ?? json['book_judul'] ?? 'The Unknown',
      author: json['author'] ?? 'Riley Sager',
      coverPath: json['coverPath'] ?? json['cover_path'] ?? 'assets/images/book_the_unknown.jpg',
      type: json['type'] ?? json['tipe_transaksi'] ?? 'Barter',
      personName: json['personName'] ?? json['requester_nama'] ?? json['owner_nama'] ?? 'Andi',
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
      title: json['title'] ?? json['book_judul'] ?? 'The Unknown',
      author: json['author'] ?? 'Riley Sager',
      coverPath: json['coverPath'] ?? json['cover_path'] ?? 'assets/images/book_the_unknown.jpg',
      type: json['type'] ?? json['tipe_transaksi'] ?? 'Barter',
      personName: json['personName'] ?? json['requester_nama'] ?? json['owner_nama'] ?? 'Andi',
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
    this.totalStudents = 320,
    this.totalBooks = 1245,
    this.totalRequests = 86,
    this.totalTransactions = 62,
    this.recentActivity = const [],
    this.recentTransactions = const [],
  });

  factory AdminDashboardModel.fromApiJson(Map<String, dynamic> json) {
    final usersData = json['users'] as Map<String, dynamic>?;
    final booksData = json['books'] as Map<String, dynamic>?;
    final txData = json['transactions'] as Map<String, dynamic>?;
    final rawRecentTx = json['recent_transactions'] as List<dynamic>? ?? [];

    final studentsCount = (usersData?['mahasiswa'] as num?)?.toInt() ?? 320;
    final booksCount = (booksData?['total'] as num?)?.toInt() ?? 1245;
    final requestsCount = (txData?['menunggu_konfirmasi'] as num?)?.toInt() ?? 86;
    final txCount = (txData?['total'] as num?)?.toInt() ?? 62;

    final List<AdminActivityItem> activities = [];
    final List<AdminTransactionItem> transactions = [];

    for (final item in rawRecentTx) {
      if (item is Map<String, dynamic>) {
        final bookTitle = item['book_judul']?.toString() ?? 'The Unknown';
        final rawType = item['tipe_transaksi']?.toString().toLowerCase() ?? 'pinjam';
        final type = rawType == 'barter' ? 'Barter' : 'Borrow';
        final person = item['requester_nama']?.toString() ?? item['owner_nama']?.toString() ?? 'Mahasiswa';
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

        String cover = 'assets/images/book_the_unknown.jpg';
        final lowTitle = bookTitle.toLowerCase();
        if (lowTitle.contains('fruit')) {
          cover = 'assets/images/book_fruit_fly.jpg';
        } else if (lowTitle.contains('adversary') || lowTitle.contains('filosofi')) {
          cover = 'assets/images/book_adversary.jpg';
        } else if (lowTitle.contains('atomic')) {
          cover = 'assets/images/book_atomic_habits.jpg';
        } else if (lowTitle.contains('midnight')) {
          cover = 'assets/images/book_midnight_lib.jpg';
        }

        final author = lowTitle.contains('fruit') ? 'Kaiju Shirai' : 'Riley Sager';

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

    final finalActivities = activities.isNotEmpty
        ? activities.take(2).toList()
        : const [
            AdminActivityItem(
              id: 'act_1',
              title: 'The Unknown',
              author: 'Riley Sager',
              coverPath: 'assets/images/book_the_unknown.jpg',
              type: 'Barter',
              personName: 'Andi',
              status: 'Pending',
            ),
            AdminActivityItem(
              id: 'act_2',
              title: 'Fruit Fly',
              author: 'Kaiju Shirai',
              coverPath: 'assets/images/book_fruit_fly.jpg',
              type: 'Borrow',
              personName: 'Sarah',
              status: 'Accepted',
            ),
          ];

    final finalTransactions = transactions.isNotEmpty
        ? transactions.take(2).toList()
        : const [
            AdminTransactionItem(
              id: 'trx_1',
              title: 'The Unknown',
              author: 'Riley Sager',
              coverPath: 'assets/images/book_the_unknown.jpg',
              type: 'Barter',
              personName: 'Andi',
              status: 'Incompleted',
            ),
            AdminTransactionItem(
              id: 'trx_2',
              title: 'Fruit Fly',
              author: 'Kaiju Shirai',
              coverPath: 'assets/images/book_fruit_fly.jpg',
              type: 'Borrow',
              personName: 'Sarah',
              status: 'Completed',
            ),
          ];

    return AdminDashboardModel(
      totalStudents: studentsCount > 0 ? studentsCount : 320,
      totalBooks: booksCount > 0 ? booksCount : 1245,
      totalRequests: requestsCount > 0 ? requestsCount : 86,
      totalTransactions: txCount > 0 ? txCount : 62,
      recentActivity: finalActivities,
      recentTransactions: finalTransactions,
    );
  }
}
