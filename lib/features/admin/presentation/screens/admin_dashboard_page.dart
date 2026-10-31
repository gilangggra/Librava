import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/utils/book_cover_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_page.dart';
import '../../domain/models/admin_dashboard_model.dart';
import '../../domain/models/admin_transaction_model.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_bottom_nav.dart';
import 'admin_books_page.dart';
import 'admin_events_page.dart';
import 'admin_request_detail_page.dart';
import 'admin_requests_page.dart';
import 'admin_transaction_detail_page.dart';
import 'admin_transactions_page.dart';
import 'admin_users_page.dart';
import '../../../events/domain/models/event_model.dart';
import '../../../events/presentation/providers/event_provider.dart';
import '../../../events/presentation/screens/add_event_page.dart';
import '../../../events/presentation/screens/event_detail_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final auth = context.read<AuthProvider>();
        final admin = context.read<AdminProvider>();
        final token = auth.token;
        admin.fetchDashboard(token);
        admin.fetchTransaksi(token);
        admin.fetchBuku(token);
        admin.fetchMahasiswa(token);
        context.read<EventProvider>().fetchEvents();
      } catch (_) {}
    });
  }

  void _konfirmasiKeluar() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Log Out from Admin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF130F26),
            ),
          ),
          content: const Text(
            'Are you sure you want to log out from the Admin session?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7E7A92),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8A88A5),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AuthProvider>().keluar();
                Navigator.pop(ctx);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Ya, Keluar',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEAFE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFDCD5FE).withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7E7A92),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF130F26),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Color(0xFF8A88A5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String author,
    required String coverPath,
    required String type,
    required String personName,
    required String status,
    VoidCallback? onTap,
  }) {
    final bool isBarter = type.toLowerCase() == 'barter';
    final s = status.toLowerCase();
    final bool isAccepted = s == 'accepted';
    final bool isRejected = s == 'rejected' || s == 'cancelled';
    final bool isOnLoan = s == 'on loan';
    final bool isCompleted = s == 'completed';

    final Color chipBg = isCompleted || isAccepted
        ? const Color(0xFFD1FADF)
        : (isOnLoan
            ? const Color(0xFFE0F2FE)
            : (isRejected ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7)));
    final Color chipFg = isCompleted || isAccepted
        ? const Color(0xFF12B76A)
        : (isOnLoan
            ? const Color(0xFF0284C7)
            : (isRejected ? const Color(0xFFDC2626) : const Color(0xFFD97706)));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildBookCoverWidget(coverPath, title: title),
            const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF130F26),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF7E7A92),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: isBarter ? const Color(0xFFEDEAFE) : const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isBarter ? AppColors.primary : const Color(0xFF0284C7),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE5E2F3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        personName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF130F26),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: chipFg,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: AppColors.primary,
            ),
          ],
        ),
      ],
    ),
  ),
);
  }

  Widget _buildTransactionItem({
    required String title,
    required String author,
    required String coverPath,
    required String type,
    required String personName,
    required String status,
    VoidCallback? onTap,
  }) {
    final bool isBarter = type.toLowerCase() == 'barter';
    final s = status.toLowerCase();
    final bool isCompleted = s == 'completed';
    final bool isOnLoan = s == 'on loan';
    final bool isRejected = s == 'rejected' || s == 'cancelled';

    final Color chipBg = isCompleted
        ? const Color(0xFFD1FADF)
        : (isOnLoan
            ? const Color(0xFFE0F2FE)
            : (isRejected ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7)));
    final Color chipFg = isCompleted
        ? const Color(0xFF12B76A)
        : (isOnLoan
            ? const Color(0xFF0284C7)
            : (isRejected ? const Color(0xFFDC2626) : const Color(0xFFD97706)));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildBookCoverWidget(coverPath, title: title),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF130F26),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF7E7A92),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: isBarter ? const Color(0xFFEDEAFE) : const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isBarter ? AppColors.primary : const Color(0xFF0284C7),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE5E2F3),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            personName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF130F26),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: chipFg,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCoverWidget(String coverPath, {String title = ''}) {
    final resolved = BookCoverHelper.getCover(
      fotoBuku: coverPath,
      judul: title,
    );
    return BookCoverHelper.buildCoverImage(
      resolved,
      width: 54,
      height: 76,
      fallbackJudul: title,
      borderRadius: BorderRadius.circular(12),
    );
  }

  Widget _buildEventImage(String? fotoPath) {
    if (fotoPath == null || fotoPath.isEmpty) {
      return Image.asset(
        'assets/images/event_library.jpg',
        width: 54,
        height: 76,
        fit: BoxFit.cover,
      );
    }
    String? fullNetworkUrl;
    if (fotoPath.startsWith('http://') || fotoPath.startsWith('https://')) {
      fullNetworkUrl = fotoPath;
    } else if (fotoPath.startsWith('/uploads/') ||
        fotoPath.startsWith('uploads/')) {
      final clean = fotoPath.startsWith('/') ? fotoPath : '/$fotoPath';
      fullNetworkUrl = '${ApiConstants.baseUrl.replaceAll('/api', '')}$clean';
    }

    Widget fallback() => Container(
          width: 54,
          height: 76,
          color: const Color(0xFFEDEAFE),
          child: const Icon(
            Icons.event_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        );

    if (fullNetworkUrl != null) {
      return Image.network(
        fullNetworkUrl,
        width: 54,
        height: 76,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback(),
      );
    }
    return Image.asset(
      fotoPath,
      width: 54,
      height: 76,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallback(),
    );
  }

  String _formatEventDate(DateTime dt) {
    const hari = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    const bulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final dayName = hari[dt.weekday];
    final monthName = bulan[dt.month];
    return '$dayName, ${dt.day} $monthName ${dt.year}';
  }

  Widget _buildEventItem({
    required EventModel event,
    VoidCallback? onTap,
  }) {
    final String formattedDate = _formatEventDate(event.tanggalMulai);
    final String status = event.displayStatus;
    final bool isApproved = status == 'Approved';
    final bool isRejected = status == 'Rejected';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildEventImage(event.fotoEvent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.judul,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF130F26),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.calendar,
                        size: 13,
                        color: Color(0xFF7E7A92),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          formattedDate,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7E7A92),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.location_solid,
                        size: 13,
                        color: Color(0xFF7E7A92),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.lokasi,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF7E7A92),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? const Color(0xFFD1FADF)
                        : (isRejected ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isApproved
                          ? const Color(0xFF12B76A)
                          : (isRejected ? const Color(0xFFDC2626) : const Color(0xFFD97706)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  void _bukaDetailActivity(AdminActivityItem item) {
    final adminProvider = context.read<AdminProvider>();
    AdminTransactionModel model;
    try {
      model = adminProvider.daftarTransaksi.firstWhere(
        (tx) => tx.id == item.id || tx.bookJudul.toLowerCase() == item.title.toLowerCase(),
      );
    } catch (_) {
      model = AdminTransactionModel(
        id: item.id.isNotEmpty ? item.id : '-',
        tipeTransaksi: item.type.toUpperCase() == 'BARTER' ? 'BARTER' : 'PINJAM',
        status: item.status.toLowerCase() == 'accepted'
            ? 'DISETUJUI'
            : (item.status.toLowerCase() == 'rejected' ? 'DITOLAK' : 'MENUNGGU_KONFIRMASI'),
        depositDummy: 0,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        requesterNama: item.personName,
        requesterEmail: '-',
        ownerNama: '-',
        ownerEmail: '-',
        bookJudul: item.title,
        bookFoto: item.coverPath,
        bookPenulis: item.author,
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminRequestDetailPage(request: model),
      ),
    );
  }

  void _bukaDetailTransaction(AdminTransactionItem item) {
    final adminProvider = context.read<AdminProvider>();
    AdminTransactionModel model;
    try {
      model = adminProvider.daftarTransaksi.firstWhere(
        (tx) => tx.id == item.id || tx.bookJudul.toLowerCase() == item.title.toLowerCase(),
      );
    } catch (_) {
      model = AdminTransactionModel(
        id: item.id.isNotEmpty ? item.id : '-',
        tipeTransaksi: item.type.toUpperCase() == 'BARTER' ? 'BARTER' : 'PINJAM',
        status: item.status.toLowerCase() == 'completed' ? 'SELESAI' : 'DALAM_PROSES',
        depositDummy: 0,
        lokasiPertemuan: null,
        waktuPertemuan: null,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        requesterNama: item.personName,
        requesterEmail: '-',
        ownerNama: '-',
        ownerEmail: '-',
        bookJudul: item.title,
        bookFoto: item.coverPath,
        bookPenulis: item.author,
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminTransactionDetailPage(transaksi: model),
      ),
    );
  }

  void _bukaDataMahasiswa() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => const AdminUsersPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _bukaDataBuku() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => const AdminBooksPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _bukaDataRequest() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => const AdminRequestsPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _bukaDataTransaksi() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => const AdminTransactionsPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final dashboard = adminProvider.dashboard;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Admin dashboard',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF130F26),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        CupertinoIcons.square_arrow_right,
                        color: Color(0xFF7E7A92),
                        size: 24,
                      ),
                      onPressed: _konfirmasiKeluar,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _bukaDataMahasiswa,
                        child: _buildMetricCard(
                          icon: CupertinoIcons.person,
                          label: 'Total students',
                          value: '${dashboard.totalStudents}',
                          subtitle: 'From last month',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _bukaDataBuku,
                        child: _buildMetricCard(
                          icon: CupertinoIcons.book,
                          label: 'Total books',
                          value: '${dashboard.totalBooks}',
                          subtitle: 'From last month',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _bukaDataRequest,
                        child: _buildMetricCard(
                          icon: CupertinoIcons.arrow_right_arrow_left,
                          label: 'Total requests',
                          value: '${dashboard.totalRequests}',
                          subtitle: 'From last month',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _bukaDataTransaksi,
                        child: _buildMetricCard(
                          icon: CupertinoIcons.doc_plaintext,
                          label: 'Total transactions',
                          value: '${dashboard.totalTransactions}',
                          subtitle: 'From last month',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Recent activity',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF130F26),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _bukaDataRequest,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          'View all',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E1A34).withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: dashboard.recentActivity.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Text(
                              'No recent request activity.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF7E7A92),
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            for (int i = 0; i < dashboard.recentActivity.length; i++) ...[
                              () {
                                final act = dashboard.recentActivity[i];
                                return _buildActivityItem(
                                  title: act.title,
                                  author: act.author,
                                  coverPath: act.coverPath,
                                  type: act.type,
                                  personName: act.personName,
                                  status: act.status,
                                  onTap: () => _bukaDetailActivity(act),
                                );
                              }(),
                              if (i < dashboard.recentActivity.length - 1)
                                const Divider(
                                  color: Color(0xFFF0EEF8),
                                  height: 20,
                                  thickness: 1,
                                ),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: 24),
                // Section Event Sesuai Mockup UI Admin Dashboard
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Event',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF130F26),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddEventPage(isAdmin: true)),
                            );
                            if (context.mounted) {
                              context.read<EventProvider>().fetchEvents(forceRefresh: true);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDEAFE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.add_rounded, size: 15, color: AppColors.primary),
                                SizedBox(width: 3),
                                Text(
                                  'Tambah',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AdminEventsPage()),
                            );
                            if (context.mounted) {
                              context.read<EventProvider>().fetchEvents(forceRefresh: true);
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              'View all',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E1A34).withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Builder(
                    builder: (ctx) {
                      final eventProvider = ctx.watch<EventProvider>();
                      final events = eventProvider.events;

                      if (eventProvider.isLoading && events.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }

                      if (events.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: Column(
                              children: [
                                const Text(
                                  'No campus events yet.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF7E7A92),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const AddEventPage(isAdmin: true)),
                                    );
                                    if (context.mounted) {
                                      context.read<EventProvider>().fetchEvents(forceRefresh: true);
                                    }
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Buat Event Baru'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final displayedEvents = events.take(2).toList();
                      return Column(
                        children: [
                          for (int i = 0; i < displayedEvents.length; i++) ...[
                            _buildEventItem(
                              event: displayedEvents[i],
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EventDetailPage(
                                      event: displayedEvents[i],
                                      isAdmin: true,
                                    ),
                                  ),
                                );
                                if (context.mounted) {
                                  context.read<EventProvider>().fetchEvents(forceRefresh: true);
                                }
                              },
                            ),
                            if (i < displayedEvents.length - 1)
                              const Divider(
                                color: Color(0xFFF0EEF8),
                                height: 20,
                                thickness: 1,
                              ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Recent transactions',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF130F26),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _bukaDataTransaksi,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          'View all',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E1A34).withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: dashboard.recentTransactions.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Text(
                              'No recent transactions.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF7E7A92),
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            for (int i = 0; i < dashboard.recentTransactions.length; i++) ...[
                              () {
                                final trx = dashboard.recentTransactions[i];
                                return _buildTransactionItem(
                                  title: trx.title,
                                  author: trx.author,
                                  coverPath: trx.coverPath,
                                  type: trx.type,
                                  personName: trx.personName,
                                  status: trx.status,
                                  onTap: () => _bukaDetailTransaction(trx),
                                );
                              }(),
                              if (i < dashboard.recentTransactions.length - 1)
                                const Divider(
                                  color: Color(0xFFF0EEF8),
                                  height: 20,
                                  thickness: 1,
                                ),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 0),
    );
  }
}
