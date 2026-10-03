import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../screens/admin_books_page.dart';
import '../screens/admin_dashboard_page.dart';
import '../screens/admin_requests_page.dart';
import '../screens/admin_transactions_page.dart';
import '../screens/admin_users_page.dart';

class AdminBottomNav extends StatelessWidget {
  final int selectedIndex;

  const AdminBottomNav({super.key, required this.selectedIndex});

  void _bukaHalaman(BuildContext context, int index) {
    if (index == selectedIndex) {
      return;
    }

    Widget? halamanTujuan;
    if (index == 0) {
      halamanTujuan = const AdminDashboardPage();
    } else if (index == 1) {
      halamanTujuan = const AdminBooksPage();
    } else if (index == 2) {
      halamanTujuan = const AdminUsersPage();
    } else if (index == 3) {
      halamanTujuan = const AdminTransactionsPage();
    } else if (index == 4) {
      halamanTujuan = const AdminRequestsPage();
    }

    if (halamanTujuan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Menu ini sedang dalam pengembangan'),
          backgroundColor: AppColors.primary,
          duration: const Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final tujuan = halamanTujuan;
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => tujuan,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      (route) => false,
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
  }) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => _bukaHalaman(context, index),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 60,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8E4FD) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Icon(
            isSelected ? activeIcon : inactiveIcon,
            color: isSelected ? AppColors.primary : const Color(0xFF52518D),
            size: 24,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
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
          _buildItem(
            context,
            index: 0,
            activeIcon: CupertinoIcons.house_fill,
            inactiveIcon: CupertinoIcons.house,
          ),
          _buildItem(
            context,
            index: 1,
            activeIcon: CupertinoIcons.book_fill,
            inactiveIcon: CupertinoIcons.book,
          ),
          _buildItem(
            context,
            index: 2,
            activeIcon: CupertinoIcons.person_fill,
            inactiveIcon: CupertinoIcons.person,
          ),
          _buildItem(
            context,
            index: 3,
            activeIcon: CupertinoIcons.arrow_right_arrow_left,
            inactiveIcon: CupertinoIcons.arrow_right_arrow_left,
          ),
          _buildItem(
            context,
            index: 4,
            activeIcon: CupertinoIcons.doc_plaintext,
            inactiveIcon: CupertinoIcons.doc_plaintext,
          ),
        ],
      ),
    );
  }
}
