import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/screens/chat_page.dart';
import '../../../chat/presentation/screens/chat_room_page.dart';
import '../../../home/presentation/screens/home_page.dart';
import '../../../profile/presentation/screens/profile_page.dart';
import '../../../books/presentation/screens/my_book_page.dart';
import '../../../books/presentation/screens/search_page.dart';
import '../providers/transaction_provider.dart';
import 'deposit_page.dart';
import 'handover_modal.dart';
import '../../../profile/presentation/screens/profile_view_page.dart';

class TransactionDetailPage extends StatefulWidget {
  final String? transactionId;
  final String bookTitle;
  final String bookAuthor;
  final String coverPath;
  final String type;
  final String requestedDate;
  final String preferredPeriod;
  final String depositAmount;
  final bool isDepositPaid;
  final String handoverLocation;
  final String ownerName;
  final String ownerUsername;
  final String status;
  final bool youConfirmed;
  final bool ownerConfirmed;

  const TransactionDetailPage({
    super.key,
    this.transactionId,
    this.bookTitle = 'The Unknown',
    this.bookAuthor = 'Riley Sager',
    this.coverPath = 'assets/images/book_the_unknown.jpg',
    this.type = 'Borrow',
    this.requestedDate = 'Aug 21, 2026',
    this.preferredPeriod = '2 weeks',
    this.depositAmount = '50.000 Rupiah',
    this.isDepositPaid = false,
    this.handoverLocation = 'Set handover',
    this.ownerName = 'Andi',
    this.ownerUsername = '@andireads',
    this.status = 'Waiting for owner’s response',
    this.youConfirmed = true,
    this.ownerConfirmed = false,
  });

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final int _selectedIndex = 2;
  late bool _depositPaid;
  late String _currentHandoverLocation;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _depositPaid = widget.isDepositPaid;
    _currentHandoverLocation = widget.handoverLocation;
    _currentStatus = widget.status;
  }

  void _bukaModalBayarDeposit() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: DepositModalContent(
              onClose: () => Navigator.pop(ctx),
              onPaymentConfirmed: () {
                setState(() {
                  _depositPaid = true;
                });
                if (widget.transactionId != null) {
                  try {
                    final auth = context.read<AuthProvider>();
                    if (auth.token != null) {
                      context.read<TransactionProvider>().updateStatusApi(
                            auth.token!,
                            widget.transactionId!,
                            'DALAM_PROSES',
                          );
                    }
                  } catch (_) {}
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Payment successful! Deposit is now secured.'),
                    backgroundColor: const Color(0xFF2FD677),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _bukaModalSetHandover() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: HandoverModalContent(
              initialLocation: _currentHandoverLocation == 'Set handover'
                  ? 'Open Library Telkom University'
                  : _currentHandoverLocation,
              onClose: () => Navigator.pop(ctx),
              onHandoverConfirmed: (selectedLocation) {
                setState(() {
                  _currentHandoverLocation = selectedLocation;
                });
                if (widget.transactionId != null) {
                  try {
                    final auth = context.read<AuthProvider>();
                    if (auth.token != null) {
                      context.read<TransactionProvider>().setMeetingApi(
                            auth.token!,
                            widget.transactionId!,
                            selectedLocation,
                            null,
                          );
                    }
                  } catch (_) {}
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Handover set to $selectedLocation'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _bukaHalamanProfilPemilik() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileViewPage(
          name: widget.ownerName,
          role: 'User',
          bio: 'A casual reader',
          email: widget.ownerName.toLowerCase() == 'andi'
              ? 'andi@example.com'
              : (widget.ownerUsername.isNotEmpty
                  ? '${widget.ownerUsername.replaceAll('@', '')}@example.com'
                  : 'ujang@example.com'),
          phone: '+62 8959982898',
          booksRead: 12,
          booksBorrowed: 3,
          favorites: 5,
          transactionId: widget.transactionId,
        ),
      ),
    );
  }

  void _konfirmasiBatalkanPermintaan() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Batalkan Permintaan?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF130F26),
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin membatalkan transaksi peminjaman buku ini?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7E7A92),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Kembali',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8A88A5),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStatus = 'Dibatalkan';
                });
                if (widget.transactionId != null) {
                  try {
                    final auth = context.read<AuthProvider>();
                    if (auth.token != null) {
                      context.read<TransactionProvider>().updateStatusApi(
                            auth.token!,
                            widget.transactionId!,
                            'DIBATALKAN',
                          );
                    }
                  } catch (_) {}
                }
                Navigator.pop(ctx);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Permintaan transaksi berhasil dibatalkan.'),
                    backgroundColor: const Color(0xFFFF4D4F),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D4F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Ya, Batalkan',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: widget.coverPath.startsWith('http://') ||
                      widget.coverPath.startsWith('https://')
                  ? Image.network(
                      widget.coverPath,
                      width: 92,
                      height: 136,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 92,
                          height: 136,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7E3FF),
                            borderRadius: BorderRadius.circular(16),
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
                      widget.coverPath,
                      width: 92,
                      height: 136,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 92,
                          height: 136,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7E3FF),
                            borderRadius: BorderRadius.circular(16),
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
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.bookTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF130F26),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.bookAuthor,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8A88A5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD027),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentStatus,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4A4960),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your request has been sent. Please wait for a response from the owner',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8A88A5),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction Info',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4A4960),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(label: 'Type', value: widget.type),
            const SizedBox(height: 12),
            _buildInfoRow(label: 'Requested on', value: widget.requestedDate),
            const SizedBox(height: 12),
            _buildInfoRow(label: 'Preferred period', value: widget.preferredPeriod),
            const SizedBox(height: 12),
            _buildInteractiveInfoRow(
              label: 'Deposit',
              value: widget.depositAmount,
              dotColor: _depositPaid ? const Color(0xFF2FD677) : const Color(0xFFF05151),
              onTap: _bukaModalBayarDeposit,
            ),
            const SizedBox(height: 12),
            _buildInteractiveInfoRow(
              label: 'Handover',
              value: _currentHandoverLocation,
              dotColor: const Color(0xFF388AF6),
              onTap: _bukaModalSetHandover,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
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
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4960),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveInfoRow({
    required String label,
    required String value,
    required Color dotColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8A88A5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A4960),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandoverConfirmationCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Handover confirmation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4A4960),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: widget.youConfirmed ? const Color(0xFF2FD677) : const Color(0xFFFFD027),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'You',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4960),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: widget.ownerConfirmed ? const Color(0xFF2FD677) : const Color(0xFFFFD027),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Owner',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4960),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Icon(
                  CupertinoIcons.info_circle_fill,
                  size: 15,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Transaction will complete after both parties confirm',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8A88A5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Owner information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4A4960),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFFE5E2F3),
                      child: const Icon(
                        CupertinoIcons.person_fill,
                        size: 32,
                        color: Color(0xFF130F26),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2FD677),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.ownerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF130F26),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.ownerUsername,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8A88A5),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _bukaHalamanProfilPemilik,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E0FC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'View profile',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
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
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatRoomPage(
                        userName: widget.ownerName,
                        isOnline: true,
                        transactionId: widget.transactionId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Message Owner',
                  style: TextStyle(
                    fontSize: 14.5,
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
                onPressed: _konfirmasiBatalkanPermintaan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5E0FC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Cancel Request',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
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
    bool isMiddle = false,
  }) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, a1, a2) => const HomePage(),
              transitionDuration: Duration.zero,
            ),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, a1, a2) => const MyBookPage(),
              transitionDuration: Duration.zero,
            ),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, a1, a2) => const SearchPage(),
              transitionDuration: Duration.zero,
            ),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, a1, a2) => const ChatPage(),
              transitionDuration: Duration.zero,
            ),
          );
        } else if (index == 4) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, a1, a2) => const ProfilePage(),
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
          color: isMiddle ? const Color(0xFFE8E4FD) : Colors.transparent,
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    CupertinoIcons.chevron_left,
                    color: Color(0xFF130F26),
                    size: 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 12),
              _buildBookHeader(),
              const SizedBox(height: 18),
              _buildStatusBanner(),
              const SizedBox(height: 14),
              _buildTransactionInfoCard(),
              const SizedBox(height: 14),
              _buildHandoverConfirmationCard(),
              const SizedBox(height: 14),
              _buildOwnerInfoCard(),
              const SizedBox(height: 18),
              _buildActionButtons(),
              const SizedBox(height: 20),
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
              isMiddle: true,
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
