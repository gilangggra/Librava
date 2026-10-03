import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_page.dart';
import '../../domain/models/admin_dashboard_model.dart';
import '../../domain/models/admin_transaction_model.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_bottom_nav.dart';
import 'admin_books_page.dart';
import 'admin_request_detail_page.dart';
import 'admin_requests_page.dart';
import 'admin_transaction_detail_page.dart';
import 'admin_transactions_page.dart';
import 'admin_users_page.dart';

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
        if (auth.token != null && auth.token!.isNotEmpty) {
          final admin = context.read<AdminProvider>();
          admin.fetchDashboard(auth.token!);
          admin.fetchTransaksi(auth.token!);
        }
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
            'Keluar dari Admin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF130F26),
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari sesi Admin Librava?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7E7A92),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Batal',
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
    final bool isAccepted = status.toLowerCase() == 'accepted';

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
          child: coverPath.startsWith('http://') || coverPath.startsWith('https://')
              ? Image.network(
                  coverPath,
                  width: 54,
                  height: 76,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 54,
                      height: 76,
                      color: const Color(0xFFE7E3FF),
                      child: const Icon(
                        Icons.book_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    );
                  },
                )
              : Image.asset(
                  coverPath,
                  width: 54,
                  height: 76,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 54,
                      height: 76,
                      color: const Color(0xFFE7E3FF),
                      child: const Icon(
                        Icons.book_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    );
                  },
                ),
        ),
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
                color: isAccepted ? const Color(0xFFD1FADF) : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isAccepted ? const Color(0xFF12B76A) : const Color(0xFFD97706),
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
    final bool isCompleted = status.toLowerCase() == 'completed';

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
              child: coverPath.startsWith('http://') || coverPath.startsWith('https://')
                  ? Image.network(
                      coverPath,
                      width: 54,
                      height: 76,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 54,
                          height: 76,
                          color: const Color(0xFFE7E3FF),
                          child: const Icon(
                            Icons.book_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      coverPath,
                      width: 54,
                      height: 76,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 54,
                          height: 76,
                          color: const Color(0xFFE7E3FF),
                          child: const Icon(
                            Icons.book_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        );
                      },
                    ),
            ),
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
                    color: isCompleted ? const Color(0xFFD1FADF) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isCompleted ? const Color(0xFF12B76A) : const Color(0xFFD97706),
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
        id: item.id.isNotEmpty ? item.id : '1',
        tipeTransaksi: item.type.toUpperCase() == 'BARTER' ? 'BARTER' : 'PINJAM',
        status: item.status.toLowerCase() == 'accepted'
            ? 'DISETUJUI'
            : (item.status.toLowerCase() == 'rejected' ? 'DITOLAK' : 'MENUNGGU_KONFIRMASI'),
        depositDummy: 0,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        requesterNama: item.personName,
        requesterEmail: '${item.personName.toLowerCase()}@librava.com',
        ownerNama: 'Librava User',
        ownerEmail: 'user@librava.com',
        bookJudul: item.title,
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
        id: item.id.isNotEmpty ? item.id : '1',
        tipeTransaksi: item.type.toUpperCase() == 'BARTER' ? 'BARTER' : 'PINJAM',
        status: item.status.toLowerCase() == 'completed' ? 'SELESAI' : 'DALAM_PROSES',
        depositDummy: 50000,
        lokasiPertemuan: 'Perpustakaan Pusat Tel-U Lt. 2',
        waktuPertemuan: '2026-10-05 10:00 WIB',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        requesterNama: item.personName,
        requesterEmail: '${item.personName.toLowerCase()}@librava.com',
        ownerNama: 'Librava User',
        ownerEmail: 'user@librava.com',
        bookJudul: item.title,
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
                  child: Column(
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
                  child: Column(
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
