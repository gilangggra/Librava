import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../books/presentation/screens/my_book_page.dart';
import '../../../books/presentation/screens/search_page.dart';
import '../../../chat/presentation/screens/chat_page.dart';
import '../../../profile/presentation/screens/profile_page.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../domain/models/book_request_item.dart';
import 'request_detail_page.dart';

class RequestListPage extends StatefulWidget {
  const RequestListPage({super.key});

  @override
  State<RequestListPage> createState() => _RequestListPageState();
}

class _RequestListPageState extends State<RequestListPage> {
  final int _selectedIndex = 0;

  late List<BookRequestItem> _requestList;

  @override
  void initState() {
    super.initState();
    _inisialisasiData();
  }

  void _inisialisasiData() {
    _requestList = [
      BookRequestItem(
        id: 'req_1',
        bookTitle: 'The Unknown',
        bookAuthor: 'Riley Sager',
        bookCover: 'assets/images/book_the_unknown.jpg',
        requesterName: 'Andi',
        requesterHandle: '@andireads',
        type: 'Barter',
        status: 'Pending',
        exchangeBookTitle: 'Fruit Fly',
        exchangeBookAuthor: 'Josh Silver',
        exchangeBookCover: 'assets/images/book_fruit_fly.jpg',
        requestedPeriod: '2 weeks',
        requestedOn: 'Aug 21, 2026',
      ),
      BookRequestItem(
        id: 'req_2',
        bookTitle: 'Adversary to the Villain',
        bookAuthor: 'Hannah Nicole Maehrer',
        bookCover: 'assets/images/book_adversary.jpg',
        requesterName: 'Sarah',
        requesterHandle: '@sarahluv',
        type: 'Borrow',
        status: 'Pending',
        requestedPeriod: '1 week',
        dateRange: 'Sep 21, 2026 - Sep 28, 2026',
        requestedOn: 'Sep 21, 2026',
      ),
      BookRequestItem(
        id: 'req_3',
        bookTitle: 'The Unknown',
        bookAuthor: 'Riley Sager',
        bookCover: 'assets/images/book_the_unknown.jpg',
        requesterName: 'Andi',
        requesterHandle: '@andireads',
        type: 'Barter',
        status: 'Accepted',
        exchangeBookTitle: 'Fruit Fly',
        exchangeBookAuthor: 'Josh Silver',
        exchangeBookCover: 'assets/images/book_fruit_fly.jpg',
        requestedPeriod: '2 weeks',
        requestedOn: 'Aug 21, 2026',
      ),
    ];
  }

  void _showAcceptDialog(BookRequestItem item) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to accept\nthis request from ${item.requesterName}?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF130F26),
                    height: 1.35,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6356FF).withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6356FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {
                            Navigator.pop(dialogCtx);
                            _updateItemStatus(item, 'Accepted');
                          },
                          child: const Text(
                            'Accept',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE2E0FD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () => Navigator.pop(dialogCtx),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6356FF),
                            ),
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

  void _showDeclineDialog(BookRequestItem item) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to decline\nthis request from ${item.requesterName}?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF130F26),
                    height: 1.35,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6356FF).withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6356FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {
                            Navigator.pop(dialogCtx);
                            _updateItemStatus(item, 'Declined');
                          },
                          child: const Text(
                            'Decline',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE2E0FD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () => Navigator.pop(dialogCtx),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6356FF),
                            ),
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

  void _updateItemStatus(BookRequestItem item, String newStatus) {
    setState(() {
      item.status = newStatus;
    });

    if (item.transactionId != null) {
      try {
        final authProvider = context.read<AuthProvider>();
        final trxProvider = context.read<TransactionProvider>();
        if (authProvider.token != null) {
          final backendStatus =
              newStatus == 'Accepted' ? 'DISETUJUI' : 'DITOLAK';
          trxProvider.updateStatusApi(
            authProvider.token!,
            item.transactionId.toString(),
            backendStatus,
          );
        }
      } catch (_) {}
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus == 'Accepted'
              ? 'Request from ${item.requesterName} accepted!'
              : 'Request from ${item.requesterName} declined.',
        ),
        backgroundColor: newStatus == 'Accepted'
            ? const Color(0xFF00B341)
            : const Color(0xFF555268),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _bukaDetailRequest(BookRequestItem item) async {
    final updatedStatus = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => RequestDetailPage(
          item: item,
          onStatusChanged: (status) {
            setState(() {
              item.status = status;
            });
          },
        ),
      ),
    );

    if (updatedStatus != null && mounted) {
      setState(() {
        item.status = updatedStatus;
      });
    }
  }

  Widget _buildCoverImage(String path, {double width = 64, double height = 88}) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _fallbackCover(width, height),
      );
    }
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          _fallbackCover(width, height),
    );
  }

  Widget _fallbackCover(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF6356FF).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.menu_book_rounded,
        color: Color(0xFF6356FF),
        size: 24,
      ),
    );
  }

  Widget _buildCard(BookRequestItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1A34).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section of card: Book cover, info, user, badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildCoverImage(
                  item.bookCover,
                  width: 64,
                  height: 88,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.bookTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF130F26),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.bookAuthor,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8F8E9D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Requester row
                    Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: const Color(0xFFF0EFFE),
                              child: const Icon(
                                Icons.person,
                                size: 18,
                                color: Color(0xFF130F26),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF34C759),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.requesterName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF130F26),
                              ),
                            ),
                            Text(
                              item.requesterHandle,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8F8E9D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Right column badges
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Type pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: item.isBarter
                          ? const Color(0xFFECEBFC)
                          : const Color(0xFFE5F4FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.type,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: item.isBarter
                            ? const Color(0xFF6356FF)
                            : const Color(0xFF2997FF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Status pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: item.isPending
                          ? const Color(0xFFFFF7C2)
                          : item.isAccepted
                              ? const Color(0xFF25D366)
                              : const Color(0xFFFFDEDE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: item.isPending
                            ? const Color(0xFFB59300)
                            : item.isAccepted
                                ? Colors.white
                                : const Color(0xFFE53935),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Middle sub-card (Offers to exchange with / Requested period)
          InkWell(
            onTap: () => _bukaDetailRequest(item),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F0FD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.isBarter
                        ? 'Offers to exchange with:'
                        : 'Requested period:',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7A7893),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (item.isBarter && item.exchangeBookTitle != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: _buildCoverImage(
                            item.exchangeBookCover ??
                                'assets/images/book_fruit_fly.jpg',
                            width: 36,
                            height: 48,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.exchangeBookTitle!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF130F26),
                              ),
                            ),
                            Text(
                              item.exchangeBookAuthor ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8F8E9D),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF6356FF),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            CupertinoIcons.calendar_badge_plus,
                            color: Color(0xFF6356FF),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.requestedPeriod ?? '1 week',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF130F26),
                              ),
                            ),
                            Text(
                              item.dateRange ?? 'Sep 21, 2026 - Sep 28, 2026',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8F8E9D),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: Color(0xFF6356FF),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom action buttons (Accept / Decline) if status is Pending
          if (item.isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6356FF).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6356FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => _showAcceptDialog(item),
                      child: const Text(
                        'Accept',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE2E0FD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => _showDeclineDialog(item),
                      child: const Text(
                        'Decline',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6356FF),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
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
          Navigator.pop(context);
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const MyBookPage(),
              transitionDuration: Duration.zero,
            ),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const SearchPage(),
              transitionDuration: Duration.zero,
            ),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const ChatPage(),
              transitionDuration: Duration.zero,
            ),
          );
        } else if (index == 4) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const ProfilePage(),
              transitionDuration: Duration.zero,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF3F2F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title: Request list
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 8, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Request list',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF130F26),
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF555268),
                        size: 26,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Request list items
              ..._requestList.map((item) => _buildCard(item)),
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
