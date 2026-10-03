import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/screens/chat_page.dart';
import '../../../home/presentation/screens/home_page.dart';
import '../../../profile/presentation/screens/profile_page.dart';
import '../../../transactions/domain/models/transaction_model.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../transactions/presentation/screens/transaction_detail_page.dart';
import '../../domain/models/book_model.dart';
import '../providers/book_provider.dart';
import 'book_detail_page.dart';
import 'search_page.dart';

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

  void _bukaModalTambahBuku(BuildContext context) {
    final judulController = TextEditingController();
    final penulisController = TextEditingController();
    final kategoriController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCD9EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tambah Koleksi Buku',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF130F26),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Judul Buku',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF130F26),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: judulController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Belajar Pemrograman Dart',
                  hintStyle: const TextStyle(color: Color(0xFFA09DB2)),
                  filled: true,
                  fillColor: const Color(0xFFF3F2F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Penulis',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF130F26),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: penulisController,
                decoration: InputDecoration(
                  hintText: 'Nama penulis buku',
                  hintStyle: const TextStyle(color: Color(0xFFA09DB2)),
                  filled: true,
                  fillColor: const Color(0xFFF3F2F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF130F26),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: kategoriController,
                decoration: InputDecoration(
                  hintText: 'Teknologi / Fiksi / Sains',
                  hintStyle: const TextStyle(color: Color(0xFFA09DB2)),
                  filled: true,
                  fillColor: const Color(0xFFF3F2F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    final judul = judulController.text.trim();
                    final penulis = penulisController.text.trim();
                    final kategori = kategoriController.text.trim();
                    if (judul.isNotEmpty) {
                      setState(() {});
                      try {
                        final auth = context.read<AuthProvider>();
                        if (auth.token != null) {
                          context.read<BookProvider>().tambahBukuApi(
                                token: auth.token!,
                                judul: judul,
                                penulis: penulis.isNotEmpty
                                    ? penulis
                                    : 'Penulis Librava',
                                kategori:
                                    kategori.isNotEmpty ? kategori : 'Umum',
                              );
                        }
                      } catch (_) {}
                    }
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          judul.isNotEmpty
                              ? 'Buku "$judul" berhasil ditambahkan!'
                              : 'Koleksi buku diperbarui.',
                        ),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Simpan Buku',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getCoverForBook(BookModel book) {
    if (book.fotoBuku != null && book.fotoBuku!.isNotEmpty) {
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    coverAsset,
                    width: 120,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 120,
                      height: 160,
                      color: const Color(0xFFE7E3FF),
                      child: const Icon(
                        Icons.book_rounded,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                  ),
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
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                const SizedBox(height: 20),
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
                    const SizedBox(width: 10),
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

  Widget _buildCollectionRow(List<BookModel> books) {
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
            child: Container(
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  coverPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFE7E3FF),
                      child: const Center(
                        child: Icon(
                          Icons.book_rounded,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionRow(List<TransactionModel> transactions) {
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
                    bookAuthor: trx.pemilikNama,
                    coverPath: coverPath,
                    status: trx.status,
                    depositAmount: '${trx.depositSimulasi.toInt()} Rupiah',
                    ownerName: trx.pemilikNama,
                    type: trx.jenisTransaksi == 'barter' ? 'Barter' : 'Borrow',
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
                    color: const Color(0xFF1E1A34).withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  coverPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFE7E3FF),
                      child: const Center(
                        child: Icon(
                          Icons.book_rounded,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
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

    final userNama = authProvider?.currentUser?.nama;

    final myBooks = (bookProvider != null && bookProvider.koleksiSaya.isNotEmpty)
        ? bookProvider.koleksiSaya
        : [
            const BookModel(
              id: 'bk_the_unknown',
              judul: 'The Unknown',
              penulis: 'Riley Sager',
              kategori: 'Horror',
              tahunTerbit: 2022,
              fotoBuku: 'assets/images/book_the_unknown.jpg',
            ),
            const BookModel(
              id: 'bk_fruit_fly',
              judul: 'Fruit Fly',
              penulis: 'Sarah Jenkins',
              kategori: 'Sains',
              tahunTerbit: 2021,
              fotoBuku: 'assets/images/book_fruit_fly.jpg',
            ),
            const BookModel(
              id: 'bk_adversary',
              judul: 'Adversary to the Villain',
              penulis: 'Hannah Nicole',
              kategori: 'Fiksi',
              tahunTerbit: 2020,
              fotoBuku: 'assets/images/book_adversary.jpg',
            ),
          ];

    final borrowedList = (trxProvider != null && trxProvider.semuaTransaksi.isNotEmpty)
        ? trxProvider.semuaTransaksi.where((t) {
            final isBorrow = t.jenisTransaksi == 'pinjam';
            final isActive = t.status != 'selesai' && t.status != 'ditolak';
            final matchUser = userNama == null ||
                t.pemohonNama == userNama ||
                t.pemohonNama.contains('Gilang') ||
                t.pemohonNama.contains('Budi');
            return isBorrow && isActive && matchUser;
          }).toList()
        : <TransactionModel>[];

    final lentOutList = (trxProvider != null && trxProvider.semuaTransaksi.isNotEmpty)
        ? trxProvider.semuaTransaksi.where((t) {
            final isActive = t.status != 'selesai' && t.status != 'ditolak';
            final matchOwner = userNama == null ||
                t.pemilikNama == userNama ||
                t.pemilikNama.contains('Gilang') ||
                t.pemilikNama.contains('Budi');
            return isActive && matchOwner;
          }).toList()
        : <TransactionModel>[];

    final displayBorrowed = borrowedList.isNotEmpty
        ? borrowedList
        : [
            const TransactionModel(
              id: 'trx_demo_1',
              bukuId: 'bk_the_unknown',
              judulBuku: 'The Unknown',
              pemohonNama: 'Gilang Ramadan',
              pemilikNama: 'Andi',
              jenisTransaksi: 'pinjam',
              status: 'pending',
              tanggal: '2026-09-20',
              coverBuku: 'assets/images/book_the_unknown.jpg',
            ),
            const TransactionModel(
              id: 'trx_demo_2',
              bukuId: 'bk_fruit_fly',
              judulBuku: 'Fruit Fly',
              pemohonNama: 'Gilang Ramadan',
              pemilikNama: 'Sarah',
              jenisTransaksi: 'pinjam',
              status: 'sedang_dipinjam',
              tanggal: '2026-09-22',
              coverBuku: 'assets/images/book_fruit_fly.jpg',
            ),
            const TransactionModel(
              id: 'trx_demo_3',
              bukuId: 'bk_adversary',
              judulBuku: 'Adversary to the Villain',
              pemohonNama: 'Gilang Ramadan',
              pemilikNama: 'Kevin',
              jenisTransaksi: 'pinjam',
              status: 'selesai',
              tanggal: '2026-09-18',
              coverBuku: 'assets/images/book_adversary.jpg',
            ),
          ];

    final displayLentOut = lentOutList.isNotEmpty
        ? lentOutList
        : [
            const TransactionModel(
              id: 'trx_demo_4',
              bukuId: 'bk_the_unknown',
              judulBuku: 'The Unknown',
              pemohonNama: 'Budi Santoso',
              pemilikNama: 'Gilang Ramadan',
              jenisTransaksi: 'pinjam',
              status: 'pending',
              tanggal: '2026-09-21',
              coverBuku: 'assets/images/book_the_unknown.jpg',
            ),
            const TransactionModel(
              id: 'trx_demo_5',
              bukuId: 'bk_fruit_fly',
              judulBuku: 'Fruit Fly',
              pemohonNama: 'Rina Kartika',
              pemilikNama: 'Gilang Ramadan',
              jenisTransaksi: 'pinjam',
              status: 'sedang_dipinjam',
              tanggal: '2026-09-23',
              coverBuku: 'assets/images/book_fruit_fly.jpg',
            ),
            const TransactionModel(
              id: 'trx_demo_6',
              bukuId: 'bk_adversary',
              judulBuku: 'Adversary to the Villain',
              pemohonNama: 'Andi Pratama',
              pemilikNama: 'Gilang Ramadan',
              jenisTransaksi: 'barter',
              status: 'selesai',
              tanggal: '2026-09-15',
              coverBuku: 'assets/images/book_adversary.jpg',
            ),
          ];

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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Mode edit koleksi diaktifkan'),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Pilih buku yang ingin dihapus'),
                                backgroundColor: const Color(0xFFFF4D4F),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
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
