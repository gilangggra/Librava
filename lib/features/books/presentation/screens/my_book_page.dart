import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../chat/presentation/screens/chat_page.dart';
import '../../../home/presentation/screens/home_page.dart';
import '../../../profile/presentation/screens/profile_page.dart';
import '../../../transactions/domain/models/transaction_model.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../transactions/presentation/screens/transaction_detail_page.dart';
import '../../../../core/utils/book_cover_helper.dart';
import '../../domain/models/book_model.dart';
import '../providers/book_provider.dart';
import 'book_detail_page.dart';
import 'search_page.dart';
import 'add_book_page.dart';
import 'edit_book_page.dart';

class MyBookPage extends StatefulWidget {
  const MyBookPage({super.key});

  @override
  State<MyBookPage> createState() => _MyBookPageState();
}

class _MyBookPageState extends State<MyBookPage> {
  final int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final auth = context.read<AuthProvider>();
        if (auth.token != null) {
          context.read<BookProvider>().fetchMyBooks(auth.token!);
          context.read<TransactionProvider>().fetchTransaksi(auth.token!);
        }
      } catch (_) {}
    });
  }

  /// Membuka halaman AddBookPage sesuai mockup desain tampilan
  void _bukaModalTambahBuku(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddBookPage(),
      ),
    );
  }

  /// Membuka dialog pemilihan buku untuk diedit pada EditBookPage
  void _bukaModalPilihBukuEdit(BuildContext context, List<BookModel> myBooks) {
    if (myBooks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You don\'t have any books in your collection to edit.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                const Text(
                  'Select Book to Edit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF130F26),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: myBooks.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: Color(0xFFEBE8F4)),
                    itemBuilder: (_, index) {
                      final b = myBooks[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        leading: _buildCoverWidget(
                          b.fotoBuku ?? 'assets/images/book_the_unknown.jpg',
                          width: 36,
                          height: 48,
                          borderRadius: 8,
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
                              builder: (_) => EditBookPage(book: b),
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
  }

  /// Membuka dialog pemilihan buku untuk dihapus dari koleksi (CupertinoIcons.delete_left)
  void _bukaModalPilihBukuHapus(BuildContext context, List<BookModel> myBooks) {
    if (myBooks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You don\'t have any books in your collection to delete.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                const Text(
                  'Select Book to Delete',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF130F26),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: myBooks.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: Color(0xFFEBE8F4)),
                    itemBuilder: (_, index) {
                      final b = myBooks[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        leading: _buildCoverWidget(
                          b.fotoBuku ?? 'assets/images/book_the_unknown.jpg',
                          width: 36,
                          height: 48,
                          borderRadius: 8,
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
                        trailing: const Icon(
                          CupertinoIcons.chevron_right,
                          size: 18,
                          color: Color(0xFF7E7A92),
                        ),
                        onTap: () => _konfirmasiHapusBukuDariModal(
                            context, ctx, b),
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
  }

  /// Menampilkan dialog konfirmasi penghapusan buku
  void _konfirmasiHapusBukuDariModal(
      BuildContext pageContext, BuildContext dialogCtx, BookModel book) {
    try {
      final trxProvider = pageContext.read<TransactionProvider>();
      final hasActiveTx = trxProvider.semuaTransaksi.any((t) =>
          (t.bukuId == book.id || t.bukuBarter == book.judul) &&
          t.status != 'selesai' &&
          t.status != 'ditolak' &&
          t.status != 'dibatalkan');

      if (hasActiveTx || !book.tersedia) {
        ScaffoldMessenger.of(pageContext).showSnackBar(
          SnackBar(
            content: Text(
                'Book "${book.judul}" is currently borrowed or in an active transaction and cannot be deleted.'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    } catch (_) {}

    showDialog(
      context: dialogCtx,
      builder: (confirmCtx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.trash,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Delete Book?',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF130F26),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${book.judul}" from your collection? This action cannot be undone.',
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF555268),
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(confirmCtx),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFFDCD9EB)),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF7E7A92),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(confirmCtx);
                      if (Navigator.canPop(dialogCtx)) {
                        Navigator.pop(dialogCtx);
                      }

                      final auth = pageContext.read<AuthProvider>();
                      final bookProvider = pageContext.read<BookProvider>();

                      if (auth.token != null) {
                        await bookProvider.hapusBukuApi(
                          token: auth.token!,
                          bookId: book.id,
                        );
                      } else {
                        bookProvider.hapusBuku(book.id);
                      }

                      if (pageContext.mounted) {
                        ScaffoldMessenger.of(pageContext).showSnackBar(
                          SnackBar(
                            content:
                                Text('Book "${book.judul}" has been deleted.'),
                            backgroundColor: const Color(0xFFDC2626),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Yes, Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _getCoverForBook(BookModel book) {
    return BookCoverHelper.getCover(fotoBuku: book.fotoBuku, judul: book.judul);
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

  Widget _buildCoverWidget(
    String coverPath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    double borderRadius = 18,
    String? fallbackJudul,
  }) {
    final resolved = BookCoverHelper.getCover(
      fotoBuku: coverPath,
      judul: fallbackJudul ?? '',
    );
    return BookCoverHelper.buildCoverImage(
      resolved,
      width: width ?? 72,
      height: height ?? 100,
      fit: fit,
      fallbackJudul: fallbackJudul,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  void _tampilkanDetailBukuModel(
      BuildContext context, BookModel book, String coverAsset) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCoverWidget(
                  coverAsset,
                  width: 120,
                  height: 160,
                  borderRadius: 16,
                ),
                const SizedBox(height: 16),
                Text(
                  book.judul,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF130F26),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Penulis: ${book.penulis}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7E7A92),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F2F8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        book.kategori,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    _buildStatusModerasiBadge(book),
                  ],
                ),
                if (book.isDitolak &&
                    book.catatanModerasi != null &&
                    book.catatanModerasi!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Text(
                      'Alasan penolakan: ${book.catatanModerasi}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFB91C1C),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Tombol Edit Buku
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEDEAFE),
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text(
                          'Edit',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditBookPage(book: book),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tombol Hapus Buku tepat di samping Edit
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEE2E2),
                          foregroundColor: const Color(0xFFDC2626),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(CupertinoIcons.trash, size: 16),
                        label: const Text(
                          'Delete',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                        onPressed: () =>
                            _konfirmasiHapusBukuDariModal(context, ctx, book),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFFDCD9EB)),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(
                            color: Color(0xFF7E7A92),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookDetailPage(
                                book: book,
                                coverPath: coverAsset,
                                title: book.judul,
                                author: book.penulis,
                                genre: book.kategori,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Detail',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusModerasiBadge(BookModel book) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    if (book.isPending) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFD97706);
      label = 'Pending';
      icon = Icons.hourglass_top_rounded;
    } else if (book.isDitolak) {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFDC2626);
      label = 'Rejected';
      icon = Icons.cancel_outlined;
    } else {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF16A34A);
      label = 'Approved';
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionRow(List<BookModel> books) {
    if (books.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEBE8F4)),
        ),
        child: const Text(
          'No books added to your collection yet.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF8E8B9F),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return SizedBox(
      height: 165,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: books.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final book = books[index];
          final coverPath = _getCoverForBook(book);
          return GestureDetector(
            onTap: () => _tampilkanDetailBukuModel(context, book, coverPath),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 108,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E1A34).withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildCoverWidget(
                    coverPath,
                    width: 108,
                    height: 165,
                    borderRadius: 18,
                  ),
                ),
                if (book.isPending || book.isDitolak)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: book.isPending
                            ? const Color(0xFFFEF3C7)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        book.isPending ? 'Pending' : 'Rejected',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: book.isPending
                              ? const Color(0xFFB45309)
                              : const Color(0xFFB91C1C),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionRow(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEBE8F4)),
        ),
        child: const Text(
          'No transactions in this category.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF8E8B9F),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return SizedBox(
      height: 165,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: transactions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final trx = transactions[index];
          final coverPath = _getCoverForTransaction(trx);
          return GestureDetector(
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
                    coverPath: coverPath,
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
            child: Container(
              width: 108,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: trx.isOverdue
                        ? const Color(0xFFDC2626).withValues(alpha: 0.25)
                        : const Color(0xFF1E1A34).withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  _buildCoverWidget(
                    coverPath,
                    width: 108,
                    height: 165,
                    borderRadius: 18,
                  ),
                  if (trx.isOverdue)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.clock_fill,
                              color: Colors.white,
                              size: 10,
                            ),
                            SizedBox(width: 3),
                            Text(
                              'Overdue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
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
              pageBuilder: (context, animation1, animation2) =>
                  const HomePage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  const SearchPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  const ChatPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 4) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  const ProfilePage(),
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
    AuthProvider? authProvider;
    try {
      authProvider = Provider.of<AuthProvider>(context);
    } catch (_) {}

    BookProvider? bookProvider;
    try {
      bookProvider = Provider.of<BookProvider>(context);
    } catch (_) {}

    TransactionProvider? trxProvider;
    try {
      trxProvider = Provider.of<TransactionProvider>(context);
    } catch (_) {}

    final currentUserId = authProvider?.currentUser?.id;
    final userNama = authProvider?.currentUser?.nama;

    final myBooks = bookProvider?.koleksiSaya ?? [];

    final rawBorrowedList = (trxProvider != null && trxProvider.semuaTransaksi.isNotEmpty)
        ? trxProvider.semuaTransaksi.where((t) {
            final isBorrow = t.jenisTransaksi == 'pinjam';
            final isActive = t.status != 'selesai' &&
                t.status != 'ditolak' &&
                t.status != 'dibatalkan';
            final matchUser = (currentUserId != null &&
                    currentUserId.isNotEmpty &&
                    t.pemohonId == currentUserId) ||
                (userNama != null &&
                    userNama.isNotEmpty &&
                    t.pemohonNama.trim().toLowerCase() ==
                        userNama.trim().toLowerCase());
            return isBorrow && isActive && matchUser;
          }).toList()
        : <TransactionModel>[];

    final rawLentOutList = (trxProvider != null && trxProvider.semuaTransaksi.isNotEmpty)
        ? trxProvider.semuaTransaksi.where((t) {
            final isActive = t.status != 'selesai' &&
                t.status != 'ditolak' &&
                t.status != 'dibatalkan';
            final matchOwner = (currentUserId != null &&
                    currentUserId.isNotEmpty &&
                    t.pemilikId == currentUserId) ||
                (userNama != null &&
                    userNama.isNotEmpty &&
                    t.pemilikNama.trim().toLowerCase() ==
                        userNama.trim().toLowerCase());
            return isActive && matchOwner;
          }).toList()
        : <TransactionModel>[];

    // Deduplikasi per buku (bukuId atau judul) agar tidak ada kartu buku kembar
    final Map<String, TransactionModel> uniqueBorrowed = {};
    for (final t in rawBorrowedList) {
      final key = t.bukuId.isNotEmpty && t.bukuId != '0'
          ? t.bukuId
          : t.judulBuku.trim().toLowerCase();
      if (!uniqueBorrowed.containsKey(key)) {
        uniqueBorrowed[key] = t;
      }
    }
    final displayBorrowed = uniqueBorrowed.values.toList();

    final Map<String, TransactionModel> uniqueLentOut = {};
    for (final t in rawLentOutList) {
      final key = t.bukuId.isNotEmpty && t.bukuId != '0'
          ? t.bukuId
          : t.judulBuku.trim().toLowerCase();
      if (!uniqueLentOut.containsKey(key)) {
        uniqueLentOut[key] = t;
      }
    }
    final displayLentOut = uniqueLentOut.values.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'My book',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF130F26),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Check your book collection',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF7E7A92),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Collection',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF130F26),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            CupertinoIcons.plus_circle,
                            size: 28,
                            color: Color(0xFF7E7A92),
                          ),
                          onPressed: () => _bukaModalTambahBuku(context),
                        ),
                        const SizedBox(width: 14),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            CupertinoIcons.square_pencil,
                            size: 28,
                            color: Color(0xFF7E7A92),
                          ),
                          onPressed: () =>
                              _bukaModalPilihBukuEdit(context, myBooks),
                        ),
                        const SizedBox(width: 14),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            CupertinoIcons.delete_left,
                            size: 28,
                            color: Color(0xFF7E7A92),
                          ),
                          onPressed: () =>
                              _bukaModalPilihBukuHapus(context, myBooks),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildCollectionRow(myBooks),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Borrowed',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF130F26),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildTransactionRow(displayBorrowed),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Lent out',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF130F26),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildTransactionRow(displayLentOut),
              ),
              const SizedBox(height: 32),
            ],
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
