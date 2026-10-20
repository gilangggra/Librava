import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/book_cover_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../books/domain/models/book_model.dart';
import '../../../books/presentation/providers/book_provider.dart';
import '../../../books/presentation/screens/book_detail_page.dart';
import '../../../books/presentation/screens/search_page.dart';
import '../../domain/models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import 'transaction_detail_page.dart';

/// Halaman Riwayat Transaksi (SRS FR-TRX-02)
/// Menampilkan daftar seluruh transaksi pinjam, barter, dan buku favorit dengan filter tab lengkap.
class TransactionHistoryPage extends StatefulWidget {
  final int initialFilterIndex;
  const TransactionHistoryPage({super.key, this.initialFilterIndex = 0});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  late int _selectedFilterIndex;
  final List<String> _filters = const [
    'Semua',
    'Pinjam',
    'Barter',
    'Selesai',
    'Favorit',
    'Dibatalkan',
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilterIndex = widget.initialFilterIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.token != null) {
        context.read<TransactionProvider>().fetchTransaksi(auth.token!);
      }
      try {
        context.read<BookProvider>().fetchBooksFromApi();
      } catch (_) {}
    });
  }

  String _getCoverForTransaction(TransactionModel trx) {
    return BookCoverHelper.getCover(
      fotoBuku: trx.coverBuku.isNotEmpty &&
              trx.coverBuku != 'assets/images/book_the_unknown.jpg'
          ? trx.coverBuku
          : null,
      judul: trx.judulBuku,
    );
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
        return 'Menunggu Konfirmasi';
    }
  }

  List<TransactionModel> _filterTransactions(List<TransactionModel> list) {
    switch (_selectedFilterIndex) {
      case 1: // Pinjam
        return list.where((t) => t.jenisTransaksi == 'pinjam').toList();
      case 2: // Barter
        return list.where((t) => t.jenisTransaksi == 'barter').toList();
      case 3: // Selesai
        return list.where((t) => t.status.toLowerCase() == 'selesai').toList();
      case 4: // Favorit (ditangani khusus)
        return [];
      case 5: // Dibatalkan / Ditolak
        return list
            .where((t) =>
                t.status.toLowerCase() == 'dibatalkan' ||
                t.status.toLowerCase() == 'ditolak')
            .toList();
      case 0: // Semua
      default:
        return list;
    }
  }

  Widget _buildCoverWidget(String coverPath, {String? fallbackJudul}) {
    final resolved = BookCoverHelper.getCover(
      fotoBuku: coverPath,
      judul: fallbackJudul ?? '',
    );
    return BookCoverHelper.buildCoverImage(
      resolved,
      width: 64,
      height: 84,
      fallbackJudul: fallbackJudul,
      borderRadius: BorderRadius.circular(12),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? actionButton,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDEAFE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 36,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF130F26),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36.0),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8A88A5),
                      height: 1.35,
                    ),
                  ),
                ),
                if (actionButton != null) ...[
                  const SizedBox(height: 20),
                  actionButton,
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesList(List<BookModel> favoriteBooks) {
    if (favoriteBooks.isEmpty) {
      return _buildEmptyState(
        icon: CupertinoIcons.bookmark,
        title: 'Belum Ada Buku Favorit',
        subtitle:
            'Tekan ikon bookmark pada halaman detail buku untuk menyimpannya ke daftar favorit Anda.',
        actionButton: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          icon: const Icon(CupertinoIcons.search, size: 16),
          label: const Text(
            'Jelajahi Katalog Buku',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SearchPage(),
              ),
            );
          },
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteBooks.length,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final book = favoriteBooks[index];
        final coverPath = BookCoverHelper.getCover(
          fotoBuku: book.fotoBuku,
          judul: book.judul,
        );
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookDetailPage(
                  book: book,
                  coverPath: coverPath,
                  title: book.judul,
                  author: book.penulis,
                  genre: book.kategori,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildCoverWidget(
                    coverPath,
                    fallbackJudul: book.judul,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDEAFE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              book.kategori.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            book.tahunTerbit > 0
                                ? '${book.tahunTerbit}'
                                : 'Buku Favorit',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF8A88A5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book.judul,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF130F26),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Oleh ${book.penulis}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF7E7A92),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: book.tersedia
                                  ? const Color(0xFF52C41A)
                                  : const Color(0xFFFAAD14),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              book.tersedia ? 'Tersedia' : 'Sedang Dipinjam',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: book.tersedia
                                    ? const Color(0xFF52C41A)
                                    : const Color(0xFFFAAD14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(
                    CupertinoIcons.bookmark_fill,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  onPressed: () {
                    context.read<BookProvider>().toggleBookmark(book);
                  },
                  tooltip: 'Hapus dari favorit',
                ),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 18,
                  color: Color(0xFF8A88A5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionsList(
      List<TransactionModel> filteredList, String namaUser) {
    if (filteredList.isEmpty) {
      return _buildEmptyState(
        icon: Icons.receipt_long_rounded,
        title: 'Tidak Ada Transaksi',
        subtitle:
            'Belum ada transaksi pada kategori ${_filters[_selectedFilterIndex].toLowerCase()}.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final trx = filteredList[index];
        final subtitleText = trx.jenisTransaksi == 'barter'
            ? 'Barter dengan ${trx.pemilikNama}'
            : (trx.pemilikNama == namaUser
                ? 'Dipinjamkan ke ${trx.pemohonNama}'
                : 'Meminjam dari ${trx.pemilikNama}');

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TransactionDetailPage(
                  transactionId: trx.id,
                  bookTitle: trx.judulBuku,
                  bookAuthor: trx.penulisBuku.isNotEmpty &&
                          trx.penulisBuku != 'Penulis'
                      ? trx.penulisBuku
                      : trx.pemilikNama,
                  coverPath: _getCoverForTransaction(trx),
                  status: trx.status,
                  depositAmount: '${trx.depositSimulasi.toInt()} Rupiah',
                  ownerName: trx.pemilikNama,
                  type: trx.jenisTransaksi == 'barter' ? 'Barter' : 'Borrow',
                  dueDate: trx.dueDate ?? trx.effectiveDueDate,
                  isOverdue: trx.isOverdue,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildCoverWidget(
                    _getCoverForTransaction(trx),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: trx.jenisTransaksi == 'barter'
                                  ? const Color(0xFFF3EAFF)
                                  : const Color(0xFFE8F1FD),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              trx.jenisTransaksi.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: trx.jenisTransaksi == 'barter'
                                    ? const Color(0xFF722ED1)
                                    : const Color(0xFF1890FF),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            trx.tanggal,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF8A88A5),
                            ),
                          ),
                          if (trx.isOverdue) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'OVERDUE',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        trx.judulBuku,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF130F26),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF7E7A92),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: trx.isOverdue
                                  ? const Color(0xFFDC2626)
                                  : _getStatusColor(trx.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              trx.isOverdue
                                  ? '${_getStatusText(trx)} (Terlambat)'
                                  : _getStatusText(trx),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: trx.isOverdue
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF4A4960),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 18,
                  color: Color(0xFF8A88A5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentUser = auth.currentUser;
    final currentUserId = currentUser?.id ?? '';
    final namaUser = currentUser?.nama ?? 'User';
    final trxProvider = context.watch<TransactionProvider>();
    final userSpecificList = trxProvider.semuaTransaksi.where((t) {
      if (currentUserId.isNotEmpty &&
          (t.pemohonId.isNotEmpty || t.pemilikId.isNotEmpty)) {
        if (t.pemohonId == currentUserId || t.pemilikId == currentUserId) {
          return true;
        }
      }
      if (namaUser != 'User' && namaUser.isNotEmpty) {
        final pNama = t.pemohonNama.trim().toLowerCase();
        final oNama = t.pemilikNama.trim().toLowerCase();
        final uNama = namaUser.trim().toLowerCase();
        if (pNama == uNama || oNama == uNama) return true;
      }
      return false;
    }).toList();

    final allList = userSpecificList.isNotEmpty
        ? userSpecificList
        : (currentUserId.isEmpty && (namaUser == 'User' || namaUser.isEmpty)
            ? trxProvider.semuaTransaksi
            : <TransactionModel>[]);
    final filteredList = _filterTransactions(allList);
    final isFavoriteTab = _filters[_selectedFilterIndex] == 'Favorit';
    final favoriteBooks = context.watch<BookProvider>().bookmarkedBooks;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.chevron_left,
            color: Color(0xFF130F26),
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isFavoriteTab ? 'Buku Favorit' : 'Riwayat Transaksi',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF130F26),
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Tabs Row
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_filters.length, (index) {
                    final isSelected = _selectedFilterIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedFilterIndex = index;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFF3F2F8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _filters[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF6B667F),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEBE8F4)),

            // Content List (Favorit or Transactions)
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final token = auth.token;
                  final bookProv = context.read<BookProvider>();
                  if (token != null) {
                    await trxProvider.fetchTransaksi(token);
                  }
                  try {
                    await bookProv.fetchBooksFromApi();
                  } catch (_) {}
                },
                child: isFavoriteTab
                    ? _buildFavoritesList(favoriteBooks)
                    : _buildTransactionsList(filteredList, namaUser),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
