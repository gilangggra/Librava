import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/screens/chat_page.dart';
import '../../../home/presentation/screens/home_page.dart';
import '../../../profile/presentation/screens/profile_page.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../domain/models/book_model.dart';
import '../../domain/models/book_review_model.dart';
import '../providers/book_provider.dart';
import 'edit_book_page.dart';
import 'my_book_page.dart';
import 'search_page.dart';

class BookDetailPage extends StatefulWidget {
  final BookModel? book;
  final String? coverPath;
  final String? author;
  final String? genre;
  final String? status;
  final String? language;
  final double? rating;
  final String? description;
  final String? title;

  const BookDetailPage({
    super.key,
    this.book,
    this.coverPath,
    this.author,
    this.genre,
    this.status,
    this.language,
    this.rating,
    this.description,
    this.title,
  });

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  final int _selectedIndex = 2;
  bool _isBookmarked = false;

  List<BookReviewModel> _reviews = [];
  double _dynamicAverageRating = 0.0;
  int _totalReviews = 0;
  bool _isLoadingReviews = false;

  @override
  void initState() {
    super.initState();
    _muatUlasanBuku();
  }

  Future<void> _muatUlasanBuku() async {
    final bookIdNum = int.tryParse(widget.book?.id ?? '');
    if (bookIdNum == null) return;

    setState(() {
      _isLoadingReviews = true;
    });

    try {
      final bookProvider = context.read<BookProvider>();
      final hasil = await bookProvider.fetchBookReviews(bookIdNum);
      if (!mounted) return;
      setState(() {
        _reviews = hasil.reviews;
        _dynamicAverageRating = hasil.averageRating;
        _totalReviews = hasil.totalReviews;
        _isLoadingReviews = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  String get _title => widget.title ?? widget.book?.judul ?? 'The Unknown';
  String get _author => widget.author ?? widget.book?.penulis ?? 'Riley Sager';
  String get _genre =>
      widget.genre ?? widget.book?.kategori ?? 'Horror/Thriller';
  String get _status =>
      widget.status ??
      (widget.book != null
          ? (widget.book!.tersedia ? 'Available' : 'Unavailable')
          : 'Available');
  String get _language => widget.language ?? 'English';
  double get _rating => widget.rating ?? widget.book?.rating ?? 4.5;
  String get _description {
    if (widget.description != null && widget.description!.isNotEmpty) {
      return widget.description!;
    }
    if (widget.book != null && widget.book!.deskripsi.isNotEmpty) {
      return widget.book!.deskripsi;
    }
    return 'A chilling mystery unfolds when hidden secrets turn ordinary lives into something far more dangerous than they seem.';
  }

  String get _coverPath {
    if (widget.book?.fotoBuku != null && widget.book!.fotoBuku!.isNotEmpty) {
      return widget.book!.fotoBuku!;
    }
    if (widget.coverPath != null && widget.coverPath!.isNotEmpty) {
      return widget.coverPath!;
    }
    return 'assets/images/book_the_unknown.jpg';
  }

  void _bukaModalPinjam(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final currentUser = auth.currentUser;
    final bool isMyBook = currentUser != null &&
        widget.book != null &&
        ((widget.book!.pemilikId != null &&
          widget.book!.pemilikId == currentUser.id) ||
         (widget.book!.pemilikNama != null &&
          currentUser.nama.isNotEmpty &&
          widget.book!.pemilikNama!.trim().toLowerCase() ==
              currentUser.nama.trim().toLowerCase()));

    if (isMyBook) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda tidak dapat meminjam buku milik Anda sendiri.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if ((currentUser?.saldoDummy ?? 100000.0) < 20000.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Saldo dummy Anda tidak mencukupi untuk deposit simulasi (minimal Rp 20.000).',
          ),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    int durasiTerpilih = 7;
    final catatanController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ajukan Peminjaman',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF130F26),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(CupertinoIcons.xmark_circle_fill),
                        color: const Color(0xFF8A88A5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Buku: $_title',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Durasi Pinjam',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF130F26),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [3, 7, 14].map((hari) {
                      final isSelected = durasiTerpilih == hari;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text('$hari Hari'),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: const Color(0xFFF2F1FA),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF52518D),
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) {
                            setModalState(() {
                              durasiTerpilih = hari;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F3FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          CupertinoIcons.info_circle_fill,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Deposit Simulasi: Rp 20.000 (akan diproses setelah disetujui)',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF52518D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: catatanController,
                    decoration: InputDecoration(
                      labelText: 'Catatan untuk pemilik (opsional)',
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8A88A5),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F7FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        String pemohon = 'Gilang Ramadan';
                        String? token;
                        try {
                          final auth = context.read<AuthProvider>();
                          if (auth.currentUser?.nama != null) {
                            pemohon = auth.currentUser!.nama;
                          }
                          token = auth.token;
                        } catch (_) {}

                        final rawBookId = widget.book?.id ?? 'bk_unknown';
                        final intBookId = int.tryParse(rawBookId);

                        if (token != null && intBookId != null) {
                          context.read<TransactionProvider>().ajukanPinjamApi(
                                token: token,
                                bookId: intBookId,
                                durasiHari: durasiTerpilih,
                                judulBuku: _title,
                                pemilikNama: widget.book?.pemilikNama ?? 'Pemilik Buku',
                                coverBuku: _coverPath,
                              );
                        } else {
                          context.read<TransactionProvider>().ajukanPinjam(
                                bukuId: rawBookId,
                                judulBuku: _title,
                                pemohonNama: pemohon,
                                durasiHari: durasiTerpilih,
                              );
                        }

                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Permohonan pinjam "$_title" berhasil diajukan!',
                            ),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Konfirmasi Pengajuan Pinjam',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _bukaModalBarter(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final currentUser = auth.currentUser;
    final bool isMyBook = currentUser != null &&
        widget.book != null &&
        ((widget.book!.pemilikId != null &&
          widget.book!.pemilikId == currentUser.id) ||
         (widget.book!.pemilikNama != null &&
          currentUser.nama.isNotEmpty &&
          widget.book!.pemilikNama!.trim().toLowerCase() ==
              currentUser.nama.trim().toLowerCase()));

    if (isMyBook) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda tidak dapat membarter buku milik Anda sendiri.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    List<BookModel> koleksi = [];
    try {
      final bp = context.read<BookProvider>();
      koleksi = bp.koleksiSaya.where((b) => b.id != widget.book?.id).toList();
    } catch (_) {}

    if (koleksi.isEmpty) {
      koleksi = const [
        BookModel(
          id: '1',
          judul: 'Clean Code',
          penulis: 'Robert C. Martin',
          kategori: 'Teknologi',
          tahunTerbit: 2008,
        ),
        BookModel(
          id: '2',
          judul: 'Design Patterns',
          penulis: 'Erich Gamma',
          kategori: 'Teknologi',
          tahunTerbit: 1994,
        ),
        BookModel(
          id: '3',
          judul: 'The Unknown',
          penulis: 'Riley Sager',
          kategori: 'Horror',
          tahunTerbit: 2022,
        ),
        BookModel(
          id: '4',
          judul: 'Fruit Fly',
          penulis: 'Sarah Jenkins',
          kategori: 'Sains',
          tahunTerbit: 2021,
        ),
      ];
    }

    BookModel bukuBarterTerpilih = koleksi.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ajukan Barter Buku',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF130F26),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(CupertinoIcons.xmark_circle_fill),
                        color: const Color(0xFF8A88A5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ingin ditukar dengan: $_title',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Pilih Buku dari Koleksimu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF130F26),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: koleksi.map((buku) {
                      final isSelected = bukuBarterTerpilih.id == buku.id ||
                          bukuBarterTerpilih.judul == buku.judul;
                      return ChoiceChip(
                        label: Text(buku.judul),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: const Color(0xFFF2F1FA),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF52518D),
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) {
                          setModalState(() {
                            bukuBarterTerpilih = buku;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        String pemohon = 'Gilang Ramadan';
                        String? token;
                        try {
                          final auth = context.read<AuthProvider>();
                          if (auth.currentUser?.nama != null) {
                            pemohon = auth.currentUser!.nama;
                          }
                          token = auth.token;
                        } catch (_) {}

                        final rawBookId = widget.book?.id ?? 'bk_unknown';
                        final intBookId = int.tryParse(rawBookId);
                        final intBarterBookId =
                            int.tryParse(bukuBarterTerpilih.id) ?? 1;

                        if (token != null && intBookId != null) {
                          context.read<TransactionProvider>().ajukanBarterApi(
                                token: token,
                                bookId: intBookId,
                                barterBookId: intBarterBookId,
                                judulBuku: _title,
                                pemilikNama: widget.book?.pemilikNama ?? 'Pemilik Buku',
                                coverBuku: _coverPath,
                              );
                        } else {
                          context.read<TransactionProvider>().ajukanBarter(
                                bukuId: rawBookId,
                                judulBuku: _title,
                                pemohonNama: pemohon,
                                bukuBarter: bukuBarterTerpilih.judul,
                              );
                        }

                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Permohonan barter $_title dengan ${bukuBarterTerpilih.judul} diajukan!',
                            ),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Konfirmasi Pengajuan Barter',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8A88A5),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4C4A6A),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
    bool isSearchActive = false,
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
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  const MyBookPage(),
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
          child: isSearchActive && isSelected
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.search,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    Positioned(
                      left: 7,
                      top: 7,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                )
              : Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  color:
                      isSelected ? AppColors.primary : const Color(0xFF52518D),
                  size: 28,
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  const SearchPage(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          CupertinoIcons.chevron_left,
                          size: 26,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (widget.book != null)
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              final isOwnerOrAdmin = auth.currentUser?.role == 'admin' ||
                                  (auth.currentUser != null &&
                                      widget.book!.pemilikNama != null &&
                                      widget.book!.pemilikNama == auth.currentUser!.nama);
                              if (!isOwnerOrAdmin) return const SizedBox.shrink();

                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6.0),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                EditBookPage(book: widget.book!),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: const Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Icon(
                                          CupertinoIcons.pencil_circle_fill,
                                          size: 26,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: InkWell(
                                      onTap: () => _konfirmasiHapusBuku(
                                          context, widget.book!),
                                      borderRadius: BorderRadius.circular(20),
                                      child: const Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Icon(
                                          CupertinoIcons.trash_circle_fill,
                                          size: 26,
                                          color: Color(0xFFDC2626),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        Builder(
                          builder: (ctx) {
                            final bookProv = ctx.watch<BookProvider>();
                            final effectiveBook = widget.book ??
                                BookModel(
                                  id: widget.title
                                          ?.toLowerCase()
                                          .replaceAll(' ', '_') ??
                                      'bk_001',
                                  judul: _title,
                                  penulis: _author,
                                  kategori: _genre,
                                  tahunTerbit: 2024,
                                  fotoBuku: widget.coverPath,
                                );
                            final isBookmarked =
                                bookProv.isBookmarked(effectiveBook.id) ||
                                    _isBookmarked;

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _isBookmarked = !isBookmarked;
                                });
                                bookProv.toggleBookmark(effectiveBook);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      !isBookmarked
                                          ? 'Buku disimpan ke bookmark'
                                          : 'Buku dihapus dari bookmark',
                                    ),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  isBookmarked
                                      ? CupertinoIcons.bookmark_fill
                                      : CupertinoIcons.bookmark,
                                  size: 24,
                                  color: isBookmarked
                                      ? AppColors.primary
                                      : const Color(0xFF333333),
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
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECEAFC),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1B1238)
                                  .withValues(alpha: 0.32),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: () {
                            final path = _coverPath;
                            String? fullNetworkUrl;
                            if (path.startsWith('http://') ||
                                path.startsWith('https://')) {
                              fullNetworkUrl = path;
                            } else if (path.startsWith('/uploads/') ||
                                path.startsWith('uploads/')) {
                              final clean =
                                  path.startsWith('/') ? path : '/$path';
                              fullNetworkUrl =
                                  '${ApiConstants.baseUrl.replaceAll('/api', '')}$clean';
                            }

                            if (fullNetworkUrl != null) {
                              return Image.network(
                                fullNetworkUrl,
                                width: 140,
                                height: 205,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 140,
                                    height: 205,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE7E3FF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.book_rounded,
                                        color: AppColors.primary,
                                        size: 48,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }

                            return Image.asset(
                              path,
                              width: 140,
                              height: 205,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 140,
                                  height: 205,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE7E3FF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.book_rounded,
                                      color: AppColors.primary,
                                      size: 48,
                                    ),
                                  ),
                                );
                              },
                            );
                          }(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF130F26),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow('Author', _author),
                            const SizedBox(height: 10),
                            _buildDetailRow('Genre', _genre),
                            const SizedBox(height: 10),
                            _buildDetailRow('Status', _status),
                            const SizedBox(height: 10),
                            _buildDetailRow('Language', _language),
                            const SizedBox(height: 10),
                            _buildDetailRow(
                              'Rating',
                              _totalReviews > 0
                                  ? '${_dynamicAverageRating.toStringAsFixed(1)} ★ ($_totalReviews)'
                                  : '${_rating.toStringAsFixed(1)} ★',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About this book',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF130F26),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _description,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF7B7993),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final currentUser = auth.currentUser;
                    final bool isMyBook = currentUser != null &&
                        widget.book != null &&
                        ((widget.book!.pemilikId != null &&
                          widget.book!.pemilikId == currentUser.id) ||
                         (widget.book!.pemilikNama != null &&
                          currentUser.nama.isNotEmpty &&
                          widget.book!.pemilikNama!.trim().toLowerCase() ==
                              currentUser.nama.trim().toLowerCase()));

                    if (isMyBook) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F2FD),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ini Adalah Buku Milik Anda',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF130F26),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Anda tidak dapat meminjam atau membarter koleksi sendiri.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF7E7A92),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () => _bukaModalPinjam(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Borrow',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF52518D)
                                      .withValues(alpha: 0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () => _bukaModalBarter(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE5E2FD),
                                foregroundColor: AppColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Barter',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              _buildSectionUlasan(),
              const SizedBox(height: 24),
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
              isSearchActive: true,
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

  void _konfirmasiHapusBuku(BuildContext context, BookModel book) {
    showDialog(
      context: context,
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
                'Hapus Buku?',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF130F26),
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus buku "${book.judul}" dari koleksi Anda? Tindakan ini tidak dapat dibatalkan.',
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
                      'Batal',
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

                      final auth = context.read<AuthProvider>();
                      final bookProvider = context.read<BookProvider>();

                      if (auth.token != null) {
                        await bookProvider.hapusBukuApi(
                          token: auth.token!,
                          bookId: book.id,
                        );
                      } else {
                        bookProvider.hapusBuku(book.id);
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Buku "${book.judul}" berhasil dihapus.'),
                            backgroundColor: const Color(0xFFDC2626),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Ya, Hapus',
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

  void _bukaModalTulisUlasan(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final bookProvider = context.read<BookProvider>();

    if (auth.token == null || auth.token!.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu untuk memberikan ulasan.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final bookIdNum = int.tryParse(widget.book?.id ?? '');
    if (bookIdNum == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Buku ini belum tersinkronisasi dengan server database.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    int ratingTerpilih = 5;
    final komentarController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Beri Ulasan Buku',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF130F26),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(CupertinoIcons.xmark_circle_fill),
                        color: const Color(0xFF8A88A5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Buku: $_title',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Penilaian Bintang',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF130F26),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      final isSelected = starValue <= ratingTerpilih;
                      return IconButton(
                        iconSize: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        icon: Icon(
                          isSelected
                              ? CupertinoIcons.star_fill
                              : CupertinoIcons.star,
                          color: isSelected
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFD1D5DB),
                        ),
                        onPressed: () {
                          setModalState(() {
                            ratingTerpilih = starValue;
                          });
                        },
                      );
                    }),
                  ),
                  Center(
                    child: Text(
                      _getRatingDescription(ratingTerpilih),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7E7A92),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Komentar / Catatan Ulasan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF130F26),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: komentarController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText:
                          'Bagikan pendapatmu tentang alur cerita atau isi buku ini...',
                      hintStyle: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF9CA3AF),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F7FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE4E1FB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE4E1FB)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setModalState(() {
                                isSubmitting = true;
                              });

                              try {
                                await bookProvider.submitBookReview(
                                  token: auth.token!,
                                  bookId: bookIdNum,
                                  rating: ratingTerpilih,
                                  komentar:
                                      komentarController.text.trim().isNotEmpty
                                          ? komentarController.text.trim()
                                          : null,
                                );

                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                }

                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Ulasan berhasil dikirim! Terima kasih.'),
                                    backgroundColor: Color(0xFF16A34A),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );

                                _muatUlasanBuku();
                              } catch (e) {
                                setModalState(() {
                                  isSubmitting = false;
                                });
                                final pesan = e
                                    .toString()
                                    .replaceFirst('Exception: ', '');
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(pesan),
                                    backgroundColor: const Color(0xFFDC2626),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Kirim Ulasan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getRatingDescription(int rating) {
    switch (rating) {
      case 1:
        return 'Sangat Kurang ⭐';
      case 2:
        return 'Kurang ⭐⭐';
      case 3:
        return 'Cukup Baik ⭐⭐⭐';
      case 4:
        return 'Bagus ⭐⭐⭐⭐';
      case 5:
        return 'Luar Biasa / Sangat Bagus ⭐⭐⭐⭐⭐';
      default:
        return '';
    }
  }

  Widget _buildSectionUlasan() {
    final double ratingTampil =
        _totalReviews > 0 ? _dynamicAverageRating : _rating;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Ulasan Pembaca',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF130F26),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECEAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_totalReviews',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => _bukaModalTulisUlasan(context),
                icon: const Icon(CupertinoIcons.pencil, size: 14),
                label: const Text('Beri Ulasan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: Color(0xFFC7BFF5)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Rating summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFBFE),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFECE8F6)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ratingTampil.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF130F26),
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        final filled = (index + 1) <= ratingTampil.round();
                        return Icon(
                          filled
                              ? CupertinoIcons.star_fill
                              : CupertinoIcons.star,
                          size: 16,
                          color: filled
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFD1D5DB),
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    _totalReviews > 0
                        ? 'Berdasarkan ulasan $_totalReviews pembaca di Librava.'
                        : 'Belum ada ulasan resmi. Nilai standar katalog adalah $ratingTampil.',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (_isLoadingReviews)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_reviews.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEBE8F6)),
              ),
              child: Column(
                children: const [
                  Icon(
                    CupertinoIcons.chat_bubble_2,
                    size: 32,
                    color: Color(0xFFB8AEFF),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Belum ada ulasan untuk buku ini',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF130F26),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Jadilah yang pertama membagikan pendapat Anda!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A88A5),
                    ),
                  ),
                ],
              ),
            )
          else
            ..._reviews.map((r) => _buildReviewCard(r)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BookReviewModel review) {
    final tanggalStr = review.createdAt != null
        ? '${review.createdAt!.day}/${review.createdAt!.month}/${review.createdAt!.year}'
        : 'Baru saja';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECE8F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFECE7FD),
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF130F26),
                      ),
                    ),
                    Text(
                      tanggalStr,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  final filled = index < review.rating;
                  return Icon(
                    filled ? CupertinoIcons.star_fill : CupertinoIcons.star,
                    size: 14,
                    color: filled
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFD1D5DB),
                  );
                }),
              ),
            ],
          ),
          if (review.komentar != null && review.komentar!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.komentar!,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
