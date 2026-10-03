import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/screens/home_page.dart';
import '../../../chat/presentation/screens/chat_page.dart';
import '../../../profile/presentation/screens/profile_page.dart';
import '../../domain/models/book_model.dart';
import '../providers/book_provider.dart';
import 'book_detail_page.dart';
import 'my_book_page.dart';

class SearchPage extends StatefulWidget {
  final String? initialQuery;

  const SearchPage({
    super.key,
    this.initialQuery,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int _selectedIndex = 2;
  int _selectedSegment = 0;
  String _selectedGenreFilter = 'Semua';
  String _selectedStatusFilter = 'Semua';
  String _selectedLanguageFilter = 'Semua';
  String _selectedRatingFilter = 'Semua';
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _searchController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<BookProvider>().fetchBooksFromApi();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _selectedGenreFilter != 'Semua' ||
      _selectedStatusFilter != 'Semua' ||
      _selectedLanguageFilter != 'Semua' ||
      _selectedRatingFilter != 'Semua';

  Widget _buildActiveFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEBE7FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              CupertinoIcons.xmark,
              size: 13,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticFilterCard({
    required String label,
    required String? selectedValue,
    required VoidCallback onTap,
  }) {
    final hasSelection = selectedValue != null && selectedValue != 'Semua';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF130F26),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasSelection)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBE7FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      selectedValue,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 20,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingDropdownOverlay({
    required int index,
    required String label,
    required String? selectedValue,
    required List<String> options,
    required VoidCallback onClose,
    required Function(String) onSelect,
  }) {
    final double topOffset = 52.0 + (index * 62.0);
    final double maxListHeight = index == 2 ? 184.0 : 330.0;

    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEBE8F4),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onClose,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  color: const Color(0xFFEBE8F4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF130F26),
                        ),
                      ),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 1.2,
                color: const Color(0xFFDED8F6),
              ),
              Container(
                color: Colors.white,
                constraints: BoxConstraints(
                  maxHeight: maxListHeight,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((option) {
                      final isSelected = selectedValue == option;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => onSelect(option),
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              alignment: Alignment.centerLeft,
                              color: isSelected
                                  ? const Color(0xFFF7F6FD)
                                  : Colors.white,
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : const Color(0xFF757489),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 1.2,
                            color: const Color(0xFFDED8F6),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _bukaModalFilter(BuildContext context) {
    String tempGenre = _selectedGenreFilter;
    String tempStatus = _selectedStatusFilter;
    String tempLanguage = _selectedLanguageFilter;
    String tempRating = _selectedRatingFilter;
    int? expandedIndex;

    final List<String> listGenre = [
      'Romance',
      'Horror',
      'Thriller',
      'Fantasy',
      'Sci-Fi',
      'Historical',
      'Self-Help',
    ];

    final List<String> listStatus = [
      'Available',
      'Unavailable',
    ];

    final List<String> listLanguage = [
      'Indonesian',
      'English',
      'Chinese',
      'Japanese',
      'Spanish',
      'French',
      'German',
    ];

    final List<String> listRating = [
      'Highest',
      'Lowest',
    ];

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxWidth: 380,
                  minHeight: 440,
                  maxHeight: MediaQuery.of(modalCtx).size.height * 0.88,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F0FD),
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filter',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF130F26),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildStaticFilterCard(
                          label: 'Genre',
                          selectedValue: tempGenre,
                          onTap: () {
                            setModalState(() {
                              expandedIndex = expandedIndex == 0 ? null : 0;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildStaticFilterCard(
                          label: 'Status',
                          selectedValue: tempStatus,
                          onTap: () {
                            setModalState(() {
                              expandedIndex = expandedIndex == 1 ? null : 1;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildStaticFilterCard(
                          label: 'Language',
                          selectedValue: tempLanguage,
                          onTap: () {
                            setModalState(() {
                              expandedIndex = expandedIndex == 2 ? null : 2;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildStaticFilterCard(
                          label: 'Rating',
                          selectedValue: tempRating,
                          onTap: () {
                            setModalState(() {
                              expandedIndex = expandedIndex == 3 ? null : 3;
                            });
                          },
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedGenreFilter = tempGenre;
                                _selectedStatusFilter = tempStatus;
                                _selectedLanguageFilter = tempLanguage;
                                _selectedRatingFilter = tempRating;
                              });
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Apply filter',
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
                    if (expandedIndex != null)
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setModalState(() {
                              expandedIndex = null;
                            });
                          },
                        ),
                      ),
                    if (expandedIndex != null)
                      _buildFloatingDropdownOverlay(
                        index: expandedIndex!,
                        label: expandedIndex == 0
                            ? 'Genre'
                            : expandedIndex == 1
                                ? 'Status'
                                : expandedIndex == 2
                                    ? 'Language'
                                    : 'Rating',
                        selectedValue: expandedIndex == 0
                            ? tempGenre
                            : expandedIndex == 1
                                ? tempStatus
                                : expandedIndex == 2
                                    ? tempLanguage
                                    : tempRating,
                        options: expandedIndex == 0
                            ? listGenre
                            : expandedIndex == 1
                                ? listStatus
                                : expandedIndex == 2
                                    ? listLanguage
                                    : listRating,
                        onClose: () {
                          setModalState(() {
                            expandedIndex = null;
                          });
                        },
                        onSelect: (val) {
                          setModalState(() {
                            if (expandedIndex == 0) {
                              tempGenre = tempGenre == val ? 'Semua' : val;
                            } else if (expandedIndex == 1) {
                              tempStatus = tempStatus == val ? 'Semua' : val;
                            } else if (expandedIndex == 2) {
                              tempLanguage =
                                  tempLanguage == val ? 'Semua' : val;
                            } else if (expandedIndex == 3) {
                              tempRating = tempRating == val ? 'Semua' : val;
                            }
                            expandedIndex = null;
                          });
                        },
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

  Widget _buildSearchResultCard({
    required String coverPath,
    required String title,
    required String author,
    required double rating,
    required int reviewsCount,
    required List<String> genres,
    BookModel? book,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetailPage(
              book: book,
              coverPath: coverPath,
              title: title,
              author: author,
              rating: rating,
              genre: genres.join('/'),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                coverPath,
                width: 72,
                height: 98,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 72,
                    height: 98,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7E3FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.book_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF130F26),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    author,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8A88A5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFF5A623),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$rating ($reviewsCount reviews)',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8A88A5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: genres.map((genre) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBE7FD),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          genre,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorCard({
    required String name,
    required String bookCount,
    required String genre,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFEBE7FD),
            child: Text(
              name.substring(0, 1),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF130F26),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$bookCount Books • $genre',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8A88A5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            color: AppColors.primary,
            size: 22,
          ),
        ],
      ),
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
    if (j.contains('basis data') || j.contains('python') || j.contains('jaringan')) {
      return 'assets/images/book_fruit_fly.jpg';
    }
    if (j.contains('laskar') || j.contains('filosofi')) {
      return 'assets/images/book_adversary.jpg';
    }
    return 'assets/images/book_the_unknown.jpg';
  }

  Widget _buildBookCover(
    String assetPath, {
    String? title,
    String? author,
    String? genre,
    BookModel? book,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetailPage(
              book: book,
              coverPath: assetPath,
              title: title ?? book?.judul,
              author: author ?? book?.penulis,
              genre: genre ?? book?.kategori,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: assetPath.startsWith('http://') ||
                assetPath.startsWith('https://')
            ? Image.network(
                assetPath,
                width: 108,
                height: 165,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 108,
                    height: 165,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7E3FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.book_rounded,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                  );
                },
              )
            : Image.asset(
                assetPath,
                width: 108,
                height: 165,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 108,
                    height: 165,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7E3FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.book_rounded,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildBookSection(String title, {List<BookModel>? books}) {
    final hasBooks = books != null && books.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF130F26),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 165,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: hasBooks
                ? books.map((b) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: _buildBookCover(
                        _getCoverForBook(b),
                        title: b.judul,
                        author: b.penulis,
                        genre: b.kategori,
                        book: b,
                      ),
                    );
                  }).toList()
                : [
                    _buildBookCover(
                      'assets/images/book_the_unknown.jpg',
                      title: 'The Unknown',
                      author: 'Riley Sager',
                      genre: 'Horror/Thriller',
                    ),
                    const SizedBox(width: 14),
                    _buildBookCover(
                      'assets/images/book_fruit_fly.jpg',
                      title: 'Fruit Fly',
                      author: 'Dr. John Doe',
                      genre: 'Sains',
                    ),
                    const SizedBox(width: 14),
                    _buildBookCover(
                      'assets/images/book_adversary.jpg',
                      title: 'Adversary',
                      author: 'Jane Smith',
                      genre: 'Fiksi',
                    ),
                  ],
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
          setState(() {
            _selectedIndex = 2;
          });
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
    BookProvider? bookProvider;
    try {
      bookProvider = Provider.of<BookProvider>(context);
    } catch (_) {}
    final query = _searchController.text.trim();
    final isSearching = query.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0),
                child: SizedBox(
                  height: 44,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        isSearching ? 'Search result' : 'Search',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF130F26),
                          letterSpacing: -0.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _bukaModalFilter(context),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                CupertinoIcons.slider_horizontal_3,
                                size: 26,
                                color: Color(0xFF52518D),
                              ),
                            ),
                            if (_hasActiveFilters)
                              Positioned(
                                right: 2,
                                top: 2,
                                child: Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.background,
                                      width: 1.5,
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
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.search,
                        color: Color(0xFFA7A3B7),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            hintStyle: TextStyle(
                              color: Color(0xFFA7A3B7),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF130F26),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      if (isSearching)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(
                              CupertinoIcons.clear_thick_circled,
                              color: Color(0xFFC7C6D8),
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_hasActiveFilters) ...[
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (_selectedGenreFilter != 'Semua')
                          _buildActiveFilterChip(
                            label: _selectedGenreFilter,
                            onRemove: () {
                              setState(() {
                                _selectedGenreFilter = 'Semua';
                              });
                            },
                          ),
                        if (_selectedStatusFilter != 'Semua')
                          _buildActiveFilterChip(
                            label: _selectedStatusFilter,
                            onRemove: () {
                              setState(() {
                                _selectedStatusFilter = 'Semua';
                              });
                            },
                          ),
                        if (_selectedLanguageFilter != 'Semua')
                          _buildActiveFilterChip(
                            label: _selectedLanguageFilter,
                            onRemove: () {
                              setState(() {
                                _selectedLanguageFilter = 'Semua';
                              });
                            },
                          ),
                        if (_selectedRatingFilter != 'Semua')
                          _buildActiveFilterChip(
                            label: _selectedRatingFilter,
                            onRemove: () {
                              setState(() {
                                _selectedRatingFilter = 'Semua';
                              });
                            },
                          ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedGenreFilter = 'Semua';
                              _selectedStatusFilter = 'Semua';
                              _selectedLanguageFilter = 'Semua';
                              _selectedRatingFilter = 'Semua';
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Text(
                              'Reset',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8A88A5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              if (isSearching) ...[
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSegment = 0;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedSegment == 0
                                ? const Color(0xFFEBE7FD)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Books',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _selectedSegment == 0
                                  ? AppColors.primary
                                  : const Color(0xFF52518D),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        color: const Color(0xFFDDD9EE),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSegment = 1;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedSegment == 1
                                ? const Color(0xFFEBE7FD)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Authors',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _selectedSegment == 1
                                  ? AppColors.primary
                                  : const Color(0xFF52518D),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _selectedSegment == 0
                      ? Column(
                          children: () {
                            if (bookProvider != null &&
                                bookProvider.allBooks.isNotEmpty) {
                              final q =
                                  _searchController.text.toLowerCase().trim();
                              final results = bookProvider.allBooks.where((b) {
                                final matchQuery = q.isEmpty ||
                                    b.judul.toLowerCase().contains(q) ||
                                    b.penulis.toLowerCase().contains(q) ||
                                    b.kategori.toLowerCase().contains(q);
                                final matchGenre =
                                    _selectedGenreFilter == 'Semua' ||
                                        b.kategori.toLowerCase() ==
                                            _selectedGenreFilter.toLowerCase();
                                final matchStatus =
                                    _selectedStatusFilter == 'Semua' ||
                                        (_selectedStatusFilter == 'Available'
                                            ? b.tersedia
                                            : !b.tersedia);
                                return matchQuery && matchGenre && matchStatus;
                              }).toList();
                              if (results.isNotEmpty) {
                                return results.map((b) {
                                  return _buildSearchResultCard(
                                    book: b,
                                    coverPath: _getCoverForBook(b),
                                    title: b.judul,
                                    author: b.penulis,
                                    rating: b.rating > 0 ? b.rating : 4.8,
                                    reviewsCount: 15,
                                    genres: [b.kategori],
                                  );
                                }).toList();
                              }
                            }
                            return [
                              _buildSearchResultCard(
                                coverPath: 'assets/images/book_the_unknown.jpg',
                                title: 'The Unknown',
                                author: 'Riley Sager',
                                rating: 4.5,
                                reviewsCount: 20,
                                genres: const ['Horror', 'Thriller'],
                              ),
                              _buildSearchResultCard(
                                coverPath: 'assets/images/book_the_unknown.jpg',
                                title: 'The Unknown',
                                author: 'Riley Sager',
                                rating: 4.5,
                                reviewsCount: 20,
                                genres: const ['Horror', 'Thriller'],
                              ),
                              _buildSearchResultCard(
                                coverPath: 'assets/images/book_the_unknown.jpg',
                                title: 'The Unknown',
                                author: 'Riley Sager',
                                rating: 4.5,
                                reviewsCount: 20,
                                genres: const ['Horror', 'Thriller'],
                              ),
                            ];
                          }(),
                        )
                      : Column(
                          children: [
                            _buildAuthorCard(
                              name: 'Riley Sager',
                              bookCount: '8',
                              genre: 'Horror / Thriller',
                            ),
                            _buildAuthorCard(
                              name: 'Robert C. Martin',
                              bookCount: '12',
                              genre: 'Software Engineering',
                            ),
                            _buildAuthorCard(
                              name: 'Eric Ries',
                              bookCount: '5',
                              genre: 'Startup / Business',
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 24),
              ] else ...[
                const SizedBox(height: 6),
                _buildBookSection(
                  'Trending',
                  books: (bookProvider != null &&
                          bookProvider.allBooks.isNotEmpty)
                      ? bookProvider.allBooks.take(8).toList()
                      : null,
                ),
                const SizedBox(height: 24),
                _buildBookSection(
                  'Recently added',
                  books: (bookProvider != null &&
                          bookProvider.allBooks.isNotEmpty)
                      ? (bookProvider.allBooks.length > 8
                          ? bookProvider.allBooks.skip(8).take(8).toList()
                          : bookProvider.allBooks.reversed.toList())
                      : null,
                ),
                const SizedBox(height: 24),
                _buildBookSection(
                  'Recommended',
                  books: (bookProvider != null &&
                          bookProvider.allBooks.isNotEmpty)
                      ? (bookProvider.allBooks.length > 16
                          ? bookProvider.allBooks.skip(16).take(8).toList()
                          : (List.of(bookProvider.allBooks)
                            ..sort((a, b) => b.rating.compareTo(a.rating))))
                      : null,
                ),
                const SizedBox(height: 24),
              ],
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
}
