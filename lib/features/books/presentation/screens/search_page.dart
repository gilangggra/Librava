import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/screens/home_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int _selectedIndex = 2;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildBookCover(String assetPath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
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
    );
  }

  Widget _buildBookSection(String title) {
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
            children: [
              _buildBookCover('assets/images/book_the_unknown.jpg'),
              const SizedBox(width: 14),
              _buildBookCover('assets/images/book_fruit_fly.jpg'),
              const SizedBox(width: 14),
              _buildBookCover('assets/images/book_adversary.jpg'),
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
                      isSelected ? AppColors.primary : const Color(0xFF38335A),
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
              const Padding(
                padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0),
                child: Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF130F26),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  height: 50,
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildBookSection('Trending'),
              const SizedBox(height: 24),
              _buildBookSection('Recently added'),
              const SizedBox(height: 24),
              _buildBookSection('Recommended'),
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
}
