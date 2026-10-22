import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../books/domain/models/book_model.dart';
import '../../../books/presentation/providers/book_provider.dart';
import '../../../books/presentation/screens/book_detail_page.dart';
import '../../../books/presentation/screens/my_book_page.dart';
import '../../../books/presentation/screens/search_page.dart';
import '../../../chat/presentation/screens/chat_page.dart';
import '../../../profile/presentation/screens/profile_page.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../transactions/presentation/screens/transaction_detail_page.dart';
import '../../../events/domain/models/event_model.dart';
import '../../../events/presentation/providers/event_provider.dart';
import '../../../events/presentation/screens/event_detail_page.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../../core/utils/book_cover_helper.dart';
import 'request_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _currentEventIndex = 0;
  int _currentBorrowIndex = 0;
  final PageController _eventPageController = PageController();
  final PageController _borrowPageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<BookProvider>().fetchBooksFromApi();
      } catch (_) {}
      try {
        final auth = context.read<AuthProvider>();
        if (auth.token != null) {
          context.read<TransactionProvider>().fetchTransaksi(auth.token!);
          context.read<ChatProvider>().fetchSummary(auth.token!);
        }
      } catch (_) {}
      try {
        context.read<EventProvider>().fetchEvents();
      } catch (_) {}
    });
  }

  String _getCoverForJudul(String judul) {
    return BookCoverHelper.getCoverForJudul(judul);
  }

  String _getCoverForBook(BookModel book) {
    return BookCoverHelper.getCover(fotoBuku: book.fotoBuku, judul: book.judul);
  }

  List<Map<String, dynamic>> _getBorrowedBooks(
      TransactionProvider? trxProvider) {
    if (trxProvider != null && trxProvider.semuaTransaksi.isNotEmpty) {
      return trxProvider.semuaTransaksi.map((t) {
        final author = t.penulisBuku.isNotEmpty && t.penulisBuku != 'Penulis'
            ? t.penulisBuku
            : (t.judulBuku.toLowerCase().contains('basis data')
                ? 'Fathansyah'
                : (t.pemilikNama.isNotEmpty ? t.pemilikNama : 'Penulis'));
        final cover = t.coverBuku.isNotEmpty &&
                t.coverBuku != 'assets/images/book_the_unknown.jpg'
            ? t.coverBuku
            : _getCoverForJudul(t.judulBuku);
        return {
          'id': t.id,
          'title': t.judulBuku,
          'author': author,
          'subtitle':
              '${t.jenisTransaksi == "barter" ? "Bartered with" : "Borrowing from"} ${t.pemilikNama}',
          'status': t.status == 'pending'
              ? 'Waiting for owner’s response'
              : t.status == 'disetujui'
                  ? 'Approved'
                  : t.status == 'selesai'
                      ? 'Barter completed'
                      : t.status,
          'statusColor': t.status == 'pending'
              ? const Color(0xFFFFDD2D)
              : t.status == 'disetujui'
                  ? const Color(0xFF4C7BFE)
                  : const Color(0xFF34C759),
          'image': cover,
        };
      }).toList();
    }
    return const [];
  }

  @override
  void dispose() {
    _borrowPageController.dispose();
    _eventPageController.dispose();
    super.dispose();
  }

  Widget _buildBookCover(String assetPath, {BookModel? book}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetailPage(
              book: book,
              coverPath: assetPath,
              title: book?.judul ?? 'Buku',
              author: book?.penulis ?? 'Penulis',
              genre: book?.kategori ?? 'Umum',
            ),
          ),
        );
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BookCoverHelper.buildCoverImage(
              assetPath,
              width: 108,
              height: 165,
              fallbackJudul: book?.judul,
            ),
          ),
          if (book != null && book.rating > 0)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFD027),
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      book.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBorrowCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionDetailPage(
              transactionId: item['id'] as String?,
              bookTitle: item['title'] as String,
              bookAuthor: (item['author'] as String?) ?? 'Penulis',
              coverPath: item['image'] as String,
              status: item['status'] as String,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 26.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BookCoverHelper.buildCoverImage(
                  item['image'] as String,
                  width: 104,
                  height: 132,
                  fallbackJudul: item['title'] as String?,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item['title'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF130F26),
                        letterSpacing: -0.3,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['subtitle'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF8A859E),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: item['statusColor'] as Color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item['status'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
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
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _getDefaultEventAsset(EventModel event) {
    if (event.fotoEvent != null &&
        event.fotoEvent!.trim().startsWith('assets/')) {
      return event.fotoEvent!.trim();
    }
    const defaults = [
      'assets/images/event_library.jpg',
      'assets/images/event_reading_meetup.jpg',
      'assets/images/event_book_discussion.jpg',
    ];
    final judulLower = event.judul.toLowerCase();
    final katLower = event.kategori.toLowerCase();
    if (judulLower.contains('read') ||
        judulLower.contains('circle') ||
        katLower.contains('circle') ||
        katLower.contains('reading')) {
      return 'assets/images/event_reading_meetup.jpg';
    }
    if (judulLower.contains('panel') ||
        judulLower.contains('review') ||
        judulLower.contains('workshop') ||
        katLower.contains('workshop') ||
        katLower.contains('seminar')) {
      return 'assets/images/event_book_discussion.jpg';
    }
    return defaults[(event.id.abs()) % defaults.length];
  }

  Widget _buildEventCard(EventModel event) {
    final foto = event.fotoEvent ?? '';
    final isHttp = foto.startsWith('http://') || foto.startsWith('https://');
    final isUploads =
        foto.startsWith('/uploads/') || foto.startsWith('uploads/');
    final fallbackAsset = _getDefaultEventAsset(event);

    String? fullNetworkUrl;
    if (isHttp) {
      fullNetworkUrl = foto;
    } else if (isUploads) {
      final cleanPath = foto.startsWith('/') ? foto : '/$foto';
      final rootServer = ApiConstants.baseUrl.replaceAll('/api', '');
      fullNetworkUrl = '$rootServer$cleanPath';
    }

    Widget backgroundWidget;
    if (fullNetworkUrl != null) {
      backgroundWidget = Image.network(
        fullNetworkUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            fallbackAsset,
            fit: BoxFit.cover,
          );
        },
      );
    } else if (foto.isNotEmpty && foto.startsWith('assets/')) {
      backgroundWidget = Image.asset(
        foto,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            fallbackAsset,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      backgroundWidget = Image.asset(
        fallbackAsset,
        fit: BoxFit.cover,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Positioned.fill(
            child: backgroundWidget,
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF6356FF).withValues(alpha: 0.90),
                    const Color(0xFF6356FF).withValues(alpha: 0.75),
                    const Color(0xFF6356FF).withValues(alpha: 0.20),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 0.75, 1.0],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 18.0, 48.0, 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.judul,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.deskripsi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailPage(event: event),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E5FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'VIEW EVENT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
        if (index == 1) {
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
        } else {
          setState(() => _selectedIndex = index);
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
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
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
    BookProvider? bookProvider;
    TransactionProvider? trxProvider;
    try {
      bookProvider = Provider.of<BookProvider>(context);
    } catch (_) {}
    try {
      trxProvider = Provider.of<TransactionProvider>(context);
    } catch (_) {}
    final borrowedList = _getBorrowedBooks(trxProvider);
    final pendingRequestCount =
        trxProvider?.requestMasuk.where((t) => t.status == 'pending').length ??
            0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF130F26),
                        letterSpacing: -0.5,
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RequestListPage(),
                          ),
                        );
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.notifications_none_rounded,
                              size: 30,
                              color: Color(0xFF555268),
                            ),
                          ),
                          if (pendingRequestCount > 0)
                            Positioned(
                              top: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    pendingRequestCount > 9
                                        ? '9+'
                                        : '$pendingRequestCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: borrowedList.isEmpty
                    ? Container(
                        margin: const EdgeInsets.symmetric(horizontal: 14.0),
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFEBE8F4)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0ECFF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.auto_stories_outlined,
                                color: AppColors.primary,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'No Borrowed Books Yet',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E1A34),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Explore the campus book collection to borrow or barter your favorite books.',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF7E7A92),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14.0),
                            child: SizedBox(
                              height: 220,
                        child: PageView.builder(
                          controller: _borrowPageController,
                          itemCount: borrowedList.length,
                          scrollBehavior:
                              const MaterialScrollBehavior().copyWith(
                            dragDevices: {
                              PointerDeviceKind.mouse,
                              PointerDeviceKind.touch,
                              PointerDeviceKind.trackpad,
                            },
                          ),
                          onPageChanged: (index) {
                            setState(() {
                              _currentBorrowIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return _buildBorrowCard(borrowedList[index]);
                          },
                        ),
                      ),
                    ),
                    if (_currentBorrowIndex > 0)
                      Positioned(
                        left: 0,
                        top: 74,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (_borrowPageController.hasClients) {
                                _borrowPageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.chevron_left_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_currentBorrowIndex < borrowedList.length - 1)
                      Positioned(
                        right: 0,
                        top: 74,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (_borrowPageController.hasClients) {
                                _borrowPageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 240,
                        height: 48,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.38),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          onPressed: () {
                            final currentBook = borrowedList[
                                _currentBorrowIndex < borrowedList.length
                                    ? _currentBorrowIndex
                                    : 0];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransactionDetailPage(
                                  transactionId:
                                      currentBook['id'] as String?,
                                  bookTitle: currentBook['title'] as String,
                                  bookAuthor: (currentBook['author'] as String?) ?? 'Penulis',
                                  coverPath: currentBook['image'] as String,
                                  status: currentBook['status'] as String,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'View transaction',
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
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Event',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF130F26),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Builder(
                  builder: (context) {
                    final eventProvider = context.watch<EventProvider>();
                    final daftarEvent = eventProvider.events;

                    if (daftarEvent.isEmpty) {
                      return const SizedBox(
                        height: 175,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }

                    final safeEventIndex =
                        _currentEventIndex.clamp(0, daftarEvent.length - 1);

                    return Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14.0),
                              child: SizedBox(
                                height: 175,
                                child: PageView.builder(
                                  controller: _eventPageController,
                                  itemCount: daftarEvent.length,
                                  scrollBehavior:
                                      const MaterialScrollBehavior().copyWith(
                                    dragDevices: {
                                      PointerDeviceKind.mouse,
                                      PointerDeviceKind.touch,
                                      PointerDeviceKind.trackpad,
                                    },
                                  ),
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentEventIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return _buildEventCard(daftarEvent[index]);
                                  },
                                ),
                              ),
                            ),
                            if (safeEventIndex > 0)
                              Positioned(
                                left: 0,
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      if (_eventPageController.hasClients) {
                                        _eventPageController.previousPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8E5FE),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.08),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.chevron_left_rounded,
                                          color: AppColors.primary,
                                          size: 26,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (safeEventIndex < daftarEvent.length - 1)
                              Positioned(
                                right: 0,
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      if (_eventPageController.hasClients) {
                                        _eventPageController.nextPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8E5FE),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.08),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.chevron_right_rounded,
                                          color: AppColors.primary,
                                          size: 26,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            daftarEvent.length,
                            (index) {
                              final isActive = safeEventIndex == index;
                              return MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (_eventPageController.hasClients) {
                                      _eventPageController.animateToPage(
                                        index,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    width: 9,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? AppColors.primary
                                          : const Color(0xFFB8AEFF),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFF5A623),
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Recommended for you',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF130F26),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 165,
                child: (bookProvider != null &&
                        bookProvider.recommendedBooks.isNotEmpty)
                    ? ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        children: bookProvider.recommendedBooks.map((b) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 14.0),
                            child: _buildBookCover(
                              _getCoverForBook(b),
                              book: b,
                            ),
                          );
                        }).toList(),
                      )
                    : (bookProvider != null && bookProvider.allBooks.isNotEmpty)
                        ? ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            children: bookProvider.allBooks.map((b) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 14.0),
                                child: _buildBookCover(
                                  _getCoverForBook(b),
                                  book: b,
                                ),
                              );
                            }).toList(),
                          )
                        : Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24.0),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFEBE8F4)),
                            ),
                            child: const Center(
                              child: Text(
                                'No book recommendations available at this time.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF7E7A92),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Featured books',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF130F26),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 165,
                child: (bookProvider != null &&
                        bookProvider.allBooks.isNotEmpty)
                    ? ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        children: bookProvider.allBooks.map((b) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 14.0),
                            child: _buildBookCover(
                              _getCoverForBook(b),
                              book: b,
                            ),
                          );
                        }).toList(),
                      )
                    : Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24.0),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFEBE8F4)),
                        ),
                        child: const Center(
                          child: Text(
                            'No featured books available.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7E7A92),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
              ),
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
