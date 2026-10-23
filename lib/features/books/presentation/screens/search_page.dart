import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/book_cover_helper.dart';
import '../../../home/presentation/screens/home_page.dart';
import '../../../chat/presentation/screens/chat_page.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
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
  String _selectedGenreFilter = 'All';
  String _selectedStatusFilter = 'All';
  String _selectedLanguageFilter = 'All';
  String _selectedRatingFilter = 'All';
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
      _selectedGenreFilter != 'All' ||
      _selectedStatusFilter != 'All' ||
      _selectedLanguageFilter != 'All' ||
      _selectedRatingFilter != 'All';

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
    final hasSelection = selectedValue != null && selectedValue != 'All';

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
                              tempGenre = tempGenre == val ? 'All' : val;
                            } else if (expandedIndex == 1) {
                              tempStatus = tempStatus == val ? 'All' : val;
                            } else if (expandedIndex == 2) {
                              tempLanguage =
                                  tempLanguage == val ? 'All' : val;
                            } else if (expandedIndex == 3) {
                              tempRating = tempRating == val ? 'All' : val;
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

  Widget _buildCoverImage(
    String coverPath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    double borderRadius = 18,
    double iconSize = 32,
    String? fallbackJudul,
  }) {
    final resolvedPath = BookCoverHelper.getCover(
      fotoBuku: coverPath,
      judul: fallbackJudul ?? '',
    );
    return BookCoverHelper.buildCoverImage(
      resolvedPath,
      width: width ?? 72,
      height: height ?? 100,
      fit: fit,
      fallbackJudul: fallbackJudul,
      borderRadius: BorderRadius.circular(borderRadius),
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
            _buildCoverImage(
              coverPath,
              width: 72,
              height: 98,
              borderRadius: 14,
              iconSize: 28,
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
    return BookCoverHelper.getCover(fotoBuku: book.fotoBuku, judul: book.judul);
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
      child: Stack(
        children: [
          _buildCoverImage(
            assetPath,
            width: 108,
            height: 165,
            borderRadius: 18,
            iconSize: 36,
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
                    Container(
                      width: 220,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEBE8F4)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const Center(
                        child: Text(
                          'No books available',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7E7A92),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (isSearchActive && isSelected)
                Stack(
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
              else
                Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  color:
                      isSelected ? AppColors.primary : const Color(0xFF52518D),
                  size: 28,
                ),
              if (badgeCount > 0)
                Positioned(
                  top: -2,
                  right: -6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
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
    BookProvider? bookProvider;
    try {
      bookProvider = Provider.of<BookProvider>(context);
    } catch (_) {}
    final query = _searchController.text.trim();
    final isSearching = query.isNotEmpty || _hasActiveFilters;

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
                        if (_selectedGenreFilter != 'All')
                          _buildActiveFilterChip(
                            label: _selectedGenreFilter,
                            onRemove: () {
                              setState(() {
                                _selectedGenreFilter = 'All';
                              });
                            },
                          ),
                        if (_selectedStatusFilter != 'All')
                          _buildActiveFilterChip(
                            label: _selectedStatusFilter,
                            onRemove: () {
                              setState(() {
                                _selectedStatusFilter = 'All';
                              });
                            },
                          ),
                        if (_selectedLanguageFilter != 'All')
                          _buildActiveFilterChip(
                            label: _selectedLanguageFilter,
                            onRemove: () {
                              setState(() {
                                _selectedLanguageFilter = 'All';
                              });
                            },
                          ),
                        if (_selectedRatingFilter != 'All')
                          _buildActiveFilterChip(
                            label: _selectedRatingFilter,
                            onRemove: () {
                              setState(() {
                                _selectedRatingFilter = 'All';
                              });
                            },
                          ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedGenreFilter = 'All';
                              _selectedStatusFilter = 'All';
                              _selectedLanguageFilter = 'All';
                              _selectedRatingFilter = 'All';
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
                                    _selectedGenreFilter == 'All' ||
                                        b.kategori.toLowerCase() ==
                                            _selectedGenreFilter.toLowerCase();
                                final matchStatus =
                                    _selectedStatusFilter == 'All' ||
                                        (_selectedStatusFilter == 'Available'
                                            ? b.tersedia
                                            : !b.tersedia);
                                return matchQuery && matchGenre && matchStatus;
                              }).toList();

                              if (_selectedRatingFilter == 'Highest') {
                                results.sort((a, b) => b.rating.compareTo(a.rating));
                              } else if (_selectedRatingFilter == 'Lowest') {
                                results.sort((a, b) => a.rating.compareTo(b.rating));
                              } else if (_selectedRatingFilter != 'All') {
                                final minRating = double.tryParse(
                                        _selectedRatingFilter.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                                    0.0;
                                results.removeWhere((b) => b.rating < minRating);
                              }
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
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: Center(
                                  child: Text(
                                    'No books match your search.',
                                    style: TextStyle(
                                      color: Color(0xFF7E7A92),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ];
                          }(),
                        )
                      : Column(
                          children: () {
                            final allBooks = bookProvider?.allBooks ?? [];
                            final authors = allBooks
                                .map((b) => b.penulis.trim())
                                .where((p) => p.isNotEmpty)
                                .toSet()
                                .toList();
                            if (authors.isEmpty) {
                              return [
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Center(
                                    child: Text(
                                      'No registered authors found.',
                                      style: TextStyle(
                                        color: Color(0xFF7E7A92),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ];
                            }
                            return authors.map((author) {
                              final count = allBooks
                                  .where((b) =>
                                      b.penulis.trim().toLowerCase() ==
                                      author.toLowerCase())
                                  .length;
                              final genre = allBooks
                                  .firstWhere((b) =>
                                      b.penulis.trim().toLowerCase() ==
                                      author.toLowerCase())
                                  .kategori;
                              return _buildAuthorCard(
                                name: author,
                                bookCount: count.toString(),
                                genre: genre,
                              );
                            }).toList();
                          }(),
                        ),
                ),
                const SizedBox(height: 24),
              ] else ...[
                const SizedBox(height: 6),
                _buildBookSection(
                  'Trending',
                  books: bookProvider?.trendingBooks,
                ),
                const SizedBox(height: 24),
                _buildBookSection(
                  'Recently added',
                  books: bookProvider?.recentlyAddedBooks,
                ),
                const SizedBox(height: 24),
                _buildBookSection(
                  'Recommended',
                  books: bookProvider?.recommendedBooks,
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
