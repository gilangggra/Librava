import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_page.dart';
import '../../../books/domain/models/book_model.dart';
import '../../../books/presentation/providers/book_provider.dart';
import '../../../books/presentation/screens/book_detail_page.dart';
import '../../../books/presentation/screens/my_book_page.dart';
import '../../../books/presentation/screens/search_page.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../chat/presentation/screens/chat_page.dart';
import '../../../events/presentation/providers/event_provider.dart';
import '../../../events/presentation/screens/event_detail_page.dart';
import '../../../home/presentation/screens/home_page.dart';
import '../../../transactions/domain/models/transaction_model.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../transactions/presentation/screens/transaction_detail_page.dart';
import '../../../transactions/presentation/screens/transaction_history_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final int _selectedIndex = 4;

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
          try {
            final eventProvider =
                Provider.of<EventProvider>(context, listen: false);
            eventProvider.fetchMyEvents(token);
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
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
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
        ),
      ),
    );
  }

  String _getCoverForBook(BookModel book) {
    if (book.fotoBuku != null &&
        book.fotoBuku!.isNotEmpty &&
        book.fotoBuku != 'assets/images/book_the_unknown.jpg') {
      return book.fotoBuku!;
    }
    final j = book.judul.toLowerCase();
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

  void _bukaModalBukuTersimpan(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Consumer<BookProvider>(
          builder: (context, bookProvider, _) {
            final bookmarks = bookProvider.bookmarkedBooks;
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E4E9),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Buku Tersimpan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF130F26),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEAFE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${bookmarks.length} Buku',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (bookmarks.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(
                          child: Column(
                            children: const [
                              Icon(CupertinoIcons.bookmark,
                                  size: 48, color: Color(0xFFB4B0C7)),
                              SizedBox(height: 12),
                              Text(
                                'Belum Ada Buku Tersimpan',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Color(0xFF4A4468),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tekan ikon bookmark pada halaman detail buku untuk menyimpannya di sini.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8A88A5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: bookmarks.length,
                          separatorBuilder: (context, index) => const Divider(
                              height: 1, color: Color(0xFFEBE8F4)),
                          itemBuilder: (_, index) {
                            final b = bookmarks[index];
                            final cover = _getCoverForBook(b);
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 6),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _buildCoverWidget(cover),
                              ),
                              title: Text(
                                b.judul,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.5,
                                ),
                              ),
                              subtitle: Text(
                                '${b.penulis} • ${b.kategori}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7E7A92),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  CupertinoIcons.bookmark_fill,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                onPressed: () {
                                  bookProvider.toggleBookmark(b);
                                },
                              ),
                              onTap: () {
                                Navigator.pop(ctx);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BookDetailPage(book: b),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _bukaModalEventSaya(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Consumer<EventProvider>(
          builder: (context, eventProvider, _) {
            final myEvents = eventProvider.myEvents;
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E4E9),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Event yang Saya Ikuti',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF130F26),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${myEvents.length} Event',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (myEvents.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(
                          child: Column(
                            children: const [
                              Icon(CupertinoIcons.ticket,
                                  size: 48, color: Color(0xFFB4B0C7)),
                              SizedBox(height: 12),
                              Text(
                                'Belum Ada Event yang Diikuti',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Color(0xFF4A4468),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Jelajahi agenda literasi kampus di Home dan tekan tombol Join Event.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8A88A5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: myEvents.length,
                          separatorBuilder: (context, index) => const Divider(
                              height: 1, color: Color(0xFFEBE8F4)),
                          itemBuilder: (_, index) {
                            final ev = myEvents[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 6),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8FAF0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.event_available_rounded,
                                  color: Color(0xFF16A34A),
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                ev.judul,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.5,
                                ),
                              ),
                              subtitle: Text(
                                '${ev.lokasi} • Kuota: ${ev.kuota}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7E7A92),
                                ),
                              ),
                              trailing: const Icon(
                                CupertinoIcons.chevron_right,
                                size: 18,
                                color: Color(0xFF7E7A92),
                              ),
                              onTap: () {
                                Navigator.pop(ctx);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EventDetailPage(event: ev),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCoverWidget(String coverPath) {
    String? fullNetworkUrl;
    if (coverPath.startsWith('http://') || coverPath.startsWith('https://')) {
      fullNetworkUrl = coverPath;
    } else if (coverPath.startsWith('/uploads/') ||
        coverPath.startsWith('uploads/')) {
      final clean = coverPath.startsWith('/') ? coverPath : '/$coverPath';
      fullNetworkUrl = '${ApiConstants.baseUrl.replaceAll('/api', '')}$clean';
    }

    Widget fallback() {
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
    }

    if (fullNetworkUrl != null) {
      return Image.network(
        fullNetworkUrl,
        width: 56,
        height: 68,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback(),
      );
    }
    return Image.asset(
      coverPath,
      width: 56,
      height: 68,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback(),
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
    int badgeCount = 0,
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
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? AppColors.primary : const Color(0xFF52518D),
                size: 28,
              ),
              if (badgeCount > 0)
                Positioned(
                  top: -2,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final namaUser = authProvider.currentUser?.nama ?? 'Pengguna';
    final emailUser = authProvider.currentUser?.email ?? '-';

    TransactionProvider? trxProvider;
    try {
      trxProvider = context.watch<TransactionProvider>();
    } catch (_) {}

    BookProvider? bookProvider;
    try {
      bookProvider = context.watch<BookProvider>();
    } catch (_) {}

    EventProvider? eventProvider;
    try {
      eventProvider = context.watch<EventProvider>();
    } catch (_) {}

    final booksReadStat =
        (trxProvider != null && trxProvider.semuaTransaksi.isNotEmpty)
            ? trxProvider.semuaTransaksi
                .where((t) => t.status == 'selesai')
                .length
                .toString()
            : '0';
    final booksBorrowedStat =
        (trxProvider != null && trxProvider.semuaTransaksi.isNotEmpty)
            ? trxProvider.semuaTransaksi
                .where((t) => t.jenisTransaksi == 'pinjam')
                .length
                .toString()
            : '0';
    final favoritesStat =
        (bookProvider != null && bookProvider.bookmarkedBooks.isNotEmpty)
            ? bookProvider.bookmarkedBooks.length.toString()
            : (bookProvider != null && bookProvider.koleksiSaya.isNotEmpty
                ? bookProvider.koleksiSaya.length.toString()
                : '0');

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
                    bookAuthor: trx.penulisBuku.isNotEmpty && trx.penulisBuku != 'Penulis'
                        ? trx.penulisBuku
                        : trx.pemilikNama,
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
      recentWidgets.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: Text(
              'Belum ada aktivitas transaksi terbaru.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF8E8B9F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
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
              if (eventProvider != null) {
                await eventProvider.fetchMyEvents(token);
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
                              child: (authProvider.currentUser?.fotoProfil != null &&
                                      authProvider.currentUser!.fotoProfil!.isNotEmpty)
                                  ? ClipOval(
                                      child: Image.network(
                                        authProvider.currentUser!.fotoProfil!.startsWith('http')
                                            ? authProvider.currentUser!.fotoProfil!
                                            : '${ApiConstants.baseUrl.replaceAll('/api', '')}/${authProvider.currentUser!.fotoProfil!.replaceFirst(RegExp(r'^/+'), '')}',
                                        width: 84,
                                        height: 84,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Center(
                                          child: Icon(
                                            Icons.person,
                                            size: 52,
                                            color: Color(0xFF130F26),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const Center(
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
                              (authProvider.currentUser?.phone.isNotEmpty == true)
                                  ? authProvider.currentUser!.phone
                                  : '-',
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
              const SizedBox(height: 24),
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TransactionHistoryPage(),
                              ),
                            );
                          },
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TransactionHistoryPage(),
                              ),
                            );
                          },
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
                          onTap: () => _bukaModalBukuTersimpan(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: InkWell(
                  onTap: () => _bukaModalEventSaya(context),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFE8E5F4),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E1A34).withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEAFE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            CupertinoIcons.ticket_fill,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Event Kampus yang Diikuti',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF130F26),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${eventProvider?.myEvents.length ?? 0} agenda terdaftar',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF7E7A92),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          CupertinoIcons.chevron_right,
                          size: 18,
                          color: Color(0xFF7E7A92),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent activity',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF130F26),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TransactionHistoryPage(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Lihat Semua',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              CupertinoIcons.chevron_right,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
              badgeCount: () {
                try {
                  return context.watch<ChatProvider>().totalUnread;
                } catch (_) {
                  return 0;
                }
              }(),
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
