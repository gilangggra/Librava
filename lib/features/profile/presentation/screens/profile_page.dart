import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_page.dart';
import '../../../books/presentation/providers/book_provider.dart';
import '../../../books/presentation/screens/my_book_page.dart';
import '../../../books/presentation/screens/search_page.dart';
import '../../../chat/presentation/screens/chat_page.dart';
import '../../../home/presentation/screens/home_page.dart';
import '../../../transactions/domain/models/transaction_model.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../transactions/presentation/screens/transaction_detail_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final int _selectedIndex = 4;
  final String _phoneNumber = '+62 8959982898';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final token = authProvider.token;
        if (token != null) {
          try {
            final trxProvider =
                Provider.of<TransactionProvider>(context, listen: false);
            trxProvider.fetchTransaksi(token);
          } catch (_) {}
          try {
            final bookProvider =
                Provider.of<BookProvider>(context, listen: false);
            bookProvider.fetchMyBooks(token);
          } catch (_) {}
        }
      } catch (_) {}
    });
  }

  void _bukaModalPengaturan(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCD9EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pengaturan Akun',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF130F26),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Color(0xFFFF4D4F)),
                  title: const Text(
                    'Keluar dari Akun',
                    style: TextStyle(
                      color: Color(0xFFFF4D4F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.read<AuthProvider>().keluar();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildInfoRow(String label, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7E7A92),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF423D60),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(
          color: Color(0xFFEBE8F4),
          thickness: 1,
          height: 1,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF130F26),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF7E7A92),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverWidget(String coverPath) {
    if (coverPath.startsWith('http://') || coverPath.startsWith('https://')) {
      return Image.network(
        coverPath,
        width: 56,
        height: 68,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 56,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFE7E3FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(
                Icons.book_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          );
        },
      );
    }
    return Image.asset(
      coverPath,
      width: 56,
      height: 68,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 56,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFFE7E3FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Icon(
              Icons.book_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  String _getCoverForTransaction(TransactionModel trx) {
    if (trx.coverBuku.isNotEmpty &&
        trx.coverBuku != 'assets/images/book_the_unknown.jpg') {
      return trx.coverBuku;
    }
    final j = trx.judulBuku.toLowerCase();
    if (j.contains('atomic')) return 'assets/images/book_atomic_habits.jpg';
    if (j.contains('midnight')) return 'assets/images/book_midnight_lib.jpg';
    if (j.contains('clean code') || j.contains('pragmatic')) {
      return 'assets/images/bookshelf.jpg';
    }
    if (j.contains('basis data') ||
        j.contains('python') ||
        j.contains('jaringan')) {
      return 'assets/images/book_fruit_fly.jpg';
    }
    if (j.contains('laskar') || j.contains('filosofi')) {
      return 'assets/images/book_adversary.jpg';
    }
    return 'assets/images/book_the_unknown.jpg';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return const Color(0xFF52C41A);
      case 'sedang_dipinjam':
        return const Color(0xFF4C7BFE);
      case 'ditolak':
      case 'dibatalkan':
        return const Color(0xFFFF4D4F);
      case 'pending':
      case 'menunggu_konfirmasi':
      default:
        return const Color(0xFFFFDD2D);
    }
  }

  String _getStatusText(TransactionModel trx) {
    switch (trx.status.toLowerCase()) {
      case 'selesai':
        return 'Selesai';
      case 'sedang_dipinjam':
        return 'Sedang Dipinjam';
      case 'disetujui':
        return 'Disetujui';
      case 'deposit_dibayar':
        return 'Deposit Dibayar';
      case 'lokasi_ditentukan':
        return 'Lokasi Ditentukan';
      case 'ditolak':
        return 'Ditolak';
      case 'dibatalkan':
        return 'Dibatalkan';
      case 'pending':
      default:
        return "Waiting for owner's response";
    }
  }

  Widget _buildRecentItem({
    required String image,
    required String title,
    required String subtitle,
    required Color statusColor,
    required String status,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _buildCoverWidget(image),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF130F26),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF8A859E),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        status,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B667F),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF4C7BFE),
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
  }) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => const HomePage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => const MyBookPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => const SearchPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => const ChatPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 64,
        height: 54,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEBE7FD) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Icon(
            isSelected ? activeIcon : inactiveIcon,
            color: isSelected ? AppColors.primary : const Color(0xFF52518D),
            size: 28,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final namaUser = authProvider.currentUser?.nama ?? 'Ujang Knalpot';
    final emailUser = authProvider.currentUser?.email ?? 'ujang@example.com';

    TransactionProvider? trxProvider;
    try {
      trxProvider = context.watch<TransactionProvider>();
    } catch (_) {}

    BookProvider? bookProvider;
    try {
      bookProvider = context.watch<BookProvider>();
    } catch (_) {}

    final booksReadStat =
        (trxProvider != null && trxProvider.semuaTransaksi.isNotEmpty)
            ? trxProvider.semuaTransaksi
                .where((t) => t.status == 'selesai')
                .length
                .toString()
            : '12';
    final booksBorrowedStat =
        (trxProvider != null && trxProvider.semuaTransaksi.isNotEmpty)
            ? trxProvider.semuaTransaksi
                .where((t) => t.jenisTransaksi == 'pinjam')
                .length
                .toString()
            : '3';
    final favoritesStat =
        (bookProvider != null && bookProvider.koleksiSaya.isNotEmpty)
            ? bookProvider.koleksiSaya.length.toString()
            : '5';

    final List<Widget> recentWidgets = [];
    final transactions = trxProvider?.semuaTransaksi ?? [];
    if (transactions.isNotEmpty) {
      final recentList = transactions.take(5).toList();
      for (int i = 0; i < recentList.length; i++) {
        final trx = recentList[i];
        final subtitleText = trx.jenisTransaksi == 'barter'
            ? 'Barter with ${trx.pemilikNama}'
            : (trx.pemilikNama == namaUser
                ? 'Lent to ${trx.pemohonNama}'
                : 'Borrowing from ${trx.pemilikNama}');
        recentWidgets.add(
          _buildRecentItem(
            image: _getCoverForTransaction(trx),
            title: trx.judulBuku,
            subtitle: subtitleText,
            statusColor: _getStatusColor(trx.status),
            status: _getStatusText(trx),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TransactionDetailPage(
                    transactionId: trx.id,
                    bookTitle: trx.judulBuku,
                    bookAuthor: trx.pemilikNama,
                    coverPath: _getCoverForTransaction(trx),
                    status: trx.status,
                    depositAmount: '${trx.depositSimulasi.toInt()} Rupiah',
                    ownerName: trx.pemilikNama,
                    type: trx.jenisTransaksi == 'barter' ? 'Barter' : 'Borrow',
                  ),
                ),
              );
            },
          ),
        );
        if (i < recentList.length - 1) {
          recentWidgets.add(
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(
                color: Color(0xFFEBE8F4),
                thickness: 1,
                height: 1,
              ),
            ),
          );
        }
      }
    } else {
      recentWidgets.addAll([
        _buildRecentItem(
          image: 'assets/images/book_the_unknown.jpg',
          title: 'The Unknown',
          subtitle: 'Borrowing from Andi',
          statusColor: const Color(0xFFFFDD2D),
          status: "Waiting for owner's response",
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Divider(
            color: Color(0xFFEBE8F4),
            thickness: 1,
            height: 1,
          ),
        ),
        _buildRecentItem(
          image: 'assets/images/book_fruit_fly.jpg',
          title: 'Fruit Fly',
          subtitle: 'Borrowed from Sarah',
          statusColor: const Color(0xFF4C7BFE),
          status: 'Due in 3 days',
        ),
      ]);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final token = authProvider.token;
            if (token != null) {
              if (trxProvider != null) {
                await trxProvider.fetchTransaksi(token);
              }
              if (bookProvider != null) {
                await bookProvider.fetchMyBooks(token);
              }
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF130F26),
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: Color(0xFF7E7A92),
                        size: 28,
                      ),
                      onPressed: () => _bukaModalPengaturan(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E1A34).withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                        child: Column(
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.person,
                                  size: 52,
                                  color: Color(0xFF130F26),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              authProvider.currentUser?.username ?? 'User',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF130F26),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              authProvider.currentUser?.bio ?? 'A casual reader',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF7E7A92),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildInfoRow('Name', namaUser),
                            _buildInfoRow('Email', emailUser),
                            _buildInfoRow(
                              'Phone',
                              authProvider.currentUser?.phone ?? _phoneNumber,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 0,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.45),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfilePage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Edit profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Activity',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF130F26),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E1A34).withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        _buildStatItem(
                          icon: CupertinoIcons.book,
                          value: booksReadStat,
                          label: 'Books Read',
                        ),
                        const VerticalDivider(
                          color: Color(0xFFEBE8F4),
                          thickness: 1,
                          indent: 6,
                          endIndent: 6,
                        ),
                        _buildStatItem(
                          icon: CupertinoIcons.arrow_2_squarepath,
                          value: booksBorrowedStat,
                          label: 'Books Borrowed',
                        ),
                        const VerticalDivider(
                          color: Color(0xFFEBE8F4),
                          thickness: 1,
                          indent: 6,
                          endIndent: 6,
                        ),
                        _buildStatItem(
                          icon: CupertinoIcons.bookmark,
                          value: favoritesStat,
                          label: 'Favorites',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Recent activity',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF130F26),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E1A34).withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: recentWidgets,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ),
      bottomNavigationBar: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0xFFEBE8F6),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              activeIcon: CupertinoIcons.house_fill,
              inactiveIcon: CupertinoIcons.house,
            ),
            _buildNavItem(
              index: 1,
              activeIcon: CupertinoIcons.book_fill,
              inactiveIcon: CupertinoIcons.book,
            ),
            _buildNavItem(
              index: 2,
              activeIcon: CupertinoIcons.search,
              inactiveIcon: CupertinoIcons.search,
            ),
            _buildNavItem(
              index: 3,
              activeIcon: CupertinoIcons.ellipses_bubble_fill,
              inactiveIcon: CupertinoIcons.ellipses_bubble,
            ),
            _buildNavItem(
              index: 4,
              activeIcon: CupertinoIcons.person_fill,
              inactiveIcon: CupertinoIcons.person,
            ),
          ],
        ),
      ),
    );
  }
}
