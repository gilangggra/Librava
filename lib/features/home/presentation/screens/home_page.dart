import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../books/presentation/screens/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

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

  Widget _buildNavItem({
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
  }) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        if (index == 2) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  const SearchPage(),
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
          child: Icon(
            isSelected ? activeIcon : inactiveIcon,
            color: isSelected ? AppColors.primary : const Color(0xFF38335A),
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
                    Stack(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            size: 30,
                            color: Color(0xFF555268),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
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
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.centerRight,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 20.0, 32.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'assets/images/book_the_unknown.jpg',
                                    width: 104,
                                    height: 132,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 104,
                                        height: 132,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE7E3FF),
                                          borderRadius: BorderRadius.circular(20),
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
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'The Unknown',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF130F26),
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Borrowing from Andi',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontStyle: FontStyle.italic,
                                          color: Color(0xFF8A859E),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Container(
                                            width: 16,
                                            height: 16,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFFDD2D),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Expanded(
                                            child: Text(
                                              "Waiting for owner's response",
                                              style: TextStyle(
                                                fontSize: 13,
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
                                const SizedBox(width: 12),
                              ],
                            ),
                          ),
                          Positioned(
                            right: -14,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
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
                          onPressed: () {},
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerRight,
                  children: [
                    Container(
                      height: 175,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFF2E2068),
                        image: DecorationImage(
                          image: const AssetImage('assets/images/event_library.jpg'),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {},
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF1C1344).withValues(alpha: 0.65),
                              const Color(0xFF2E2068).withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Book Exchange Day',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Exchange your favorite books with\nother students',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.3,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: -10,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9E6FA),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB1A7FF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCEC8FF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
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
