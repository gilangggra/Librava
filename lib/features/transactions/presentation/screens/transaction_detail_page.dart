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
  final String? ownerId;

  const TransactionDetailPage({
    super.key,
    this.transactionId,
    this.ownerId,
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
  late bool _youConfirmed;
  late bool _ownerConfirmed;
  bool _hasReviewed = false;
  int _myRating = 5;
  String _myComment = '';
  bool _isLoadingAction = false;

  @override
  void initState() {
    super.initState();
    _depositPaid = widget.isDepositPaid;
    _currentHandoverLocation = widget.handoverLocation;
    _currentStatus = widget.status;
    _youConfirmed = widget.youConfirmed;
    _ownerConfirmed = widget.ownerConfirmed;
  }

  void _konfirmasiSerahTerima() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Konfirmasi Serah Terima',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF130F26),
            ),
          ),
          content: Text(
            'Apakah Anda sudah menerima / menyerahkan buku "${widget.bookTitle}" di $_currentHandoverLocation?',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7E7A92),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8A88A5),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                setState(() {
                  _youConfirmed = true;
                  if (_ownerConfirmed) {
                    _currentStatus = 'selesai';
                  } else {
                    _currentStatus = 'sedang_dipinjam';
                  }
                });

                if (widget.transactionId != null) {
                  try {
                    final auth = context.read<AuthProvider>();
                    if (auth.token != null) {
                      await context
                          .read<TransactionProvider>()
                          .confirmHandoverApi(
                            auth.token!,
                            widget.transactionId!,
                          );
                    }
                  } catch (_) {}
                }

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _ownerConfirmed
                          ? 'Serah terima selesai! Status transaksi kini Selesai.'
                          : 'Konfirmasi serah terima Anda berhasil dicatat.',
                    ),
                    backgroundColor: const Color(0xFF2FD677),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Ya, Konfirmasi',
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
              depositAmount: widget.depositAmount,
              onClose: () => Navigator.pop(ctx),
              onPaymentConfirmed: () async {
                setState(() {
                  _depositPaid = true;
                });
                final auth = context.read<AuthProvider>();
                final trxProvider = context.read<TransactionProvider>();
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(ctx);
                final depositNominal = double.tryParse(
                      widget.depositAmount.replaceAll(RegExp(r'[^0-9]'), ''),
                    ) ??
                    20000.0;

                // Memotong saldo dummy pengguna
                auth.potongSaldoDummy(depositNominal);

                if (widget.transactionId != null) {
                  try {
                    if (auth.token != null) {
                      await trxProvider.updateStatusApi(
                            auth.token!,
                            widget.transactionId!,
                            'DALAM_PROSES',
                          );
                      await auth.segarkanProfil();
                    }
                  } catch (_) {}
                }
                navigator.pop();
                if (!mounted) return;
                final sisaSaldoFormatted =
                    (auth.currentUser?.saldoDummy ?? 100000.0)
                        .toInt()
                        .toString()
                        .replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]}.',
                        );
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Pembayaran deposit Rp ${depositNominal.toInt()} berhasil diamankan! Sisa saldo dompet: Rp $sisaSaldoFormatted.',
                    ),
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
          userId: widget.ownerId ?? '1',
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

  void _tampilkanDialogPengembalianDepositSukses({
    required BuildContext context,
    required String depositAmount,
    required double updatedSaldo,
  }) {
    final formattedSaldo = updatedSaldo.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2FD677), Color(0xFF10B981)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF10B981).withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Deposit Dikembalikan!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF130F26),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Buku "${widget.bookTitle}" telah dikembalikan kepada ${widget.ownerName}. Jaminan peminjaman telah dikembalikan penuh ke saldo Anda.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF7E7A92),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F8FF),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE4E9FB)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Jumlah Dana Dicairkan',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF7E7A92),
                              ),
                            ),
                            Text(
                              '+$depositAmount',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(
                            height: 1,
                            color: Color(0xFFE4E9FB),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Saldo Dompet Sekarang',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF7E7A92),
                              ),
                            ),
                            Text(
                              'Rp $formattedSaldo',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF130F26),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        if (!_hasReviewed) {
                          _bukaModalReview();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _hasReviewed ? 'Selesai' : 'Beri Ulasan Pemilik',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8A88A5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _konfirmasiPengembalianBuku() async {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Konfirmasi Pengembalian Buku',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF130F26),
            ),
          ),
          content: Text(
            'Apakah Anda sudah mengembalikan buku "${widget.bookTitle}" kepada ${widget.ownerName}?\n\nSetelah dikonfirmasi, transaksi akan selesai dan saldo jaminan deposit akan dikembalikan ke akun Anda.',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7E7A92),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8A88A5),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final auth = context.read<AuthProvider>();
                final trxProvider = context.read<TransactionProvider>();
                final messenger = ScaffoldMessenger.of(context);
                final depositNominal = double.tryParse(
                      widget.depositAmount.replaceAll(RegExp(r'[^0-9]'), ''),
                    ) ??
                    20000.0;

                Navigator.pop(ctx);
                setState(() {
                  _isLoadingAction = true;
                });

                // Tambahkan kembali saldo jaminan ke dompet peminjam
                auth.tambahSaldoDummy(depositNominal);

                if (widget.transactionId != null && auth.token != null) {
                  try {
                    await trxProvider.confirmReturnApi(
                      auth.token!,
                      widget.transactionId!,
                    );
                    await auth.segarkanProfil();
                  } catch (_) {}
                }

                if (!mounted) return;
                setState(() {
                  _isLoadingAction = false;
                  _currentStatus = 'selesai';
                });

                final updatedSaldo =
                    auth.currentUser?.saldoDummy ?? 100000.0;
                _tampilkanDialogPengembalianDepositSukses(
                  context: context,
                  depositAmount: widget.depositAmount,
                  updatedSaldo: updatedSaldo,
                );

                messenger.showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Buku berhasil dikembalikan! Transaksi selesai dan saldo jaminan deposit telah dicairkan kembali.',
                    ),
                    backgroundColor: const Color(0xFF2FD677),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Ya, Sudah Dikembalikan',
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

  void _bukaModalReview() {
    int selectedRating = _myRating > 0 ? _myRating : 5;
    final commentController = TextEditingController(text: _myComment);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
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
                  const SizedBox(height: 18),
                  const Text(
                    'Beri Ulasan & Rating',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF130F26),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bagikan pengalaman transaksi bersama ${widget.ownerName}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF7E7A92),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedRating = starValue;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              starValue <= selectedRating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 38,
                              color: starValue <= selectedRating
                                  ? const Color(0xFFFFB800)
                                  : const Color(0xFFCCC8DC),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      selectedRating == 5
                          ? 'Sangat Memuaskan! (5/5)'
                          : selectedRating == 4
                              ? 'Bagus (4/5)'
                              : selectedRating == 3
                                  ? 'Cukup (3/5)'
                                  : selectedRating == 2
                                      ? 'Kurang (2/5)'
                                      : 'Sangat Buruk (1/5)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A4960),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar atau kesan Anda (opsional)...',
                      hintStyle: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF9E9BAE),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF7F6FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final comment = commentController.text.trim();
                        final auth = context.read<AuthProvider>();
                        final trxProvider = context.read<TransactionProvider>();
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(ctx);

                        setState(() {
                          _hasReviewed = true;
                          _myRating = selectedRating;
                          _myComment = comment;
                        });

                        if (widget.transactionId != null && auth.token != null) {
                          try {
                            await trxProvider.submitReviewApi(
                              token: auth.token!,
                              transactionId: widget.transactionId!,
                              rating: selectedRating,
                              komentar: comment.isNotEmpty ? comment : null,
                            );
                          } catch (_) {}
                        }

                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content:
                                const Text('Ulasan Anda berhasil dikirim!'),
                            backgroundColor: const Color(0xFF2FD677),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Kirim Ulasan',
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
    Color dotColor = const Color(0xFFFFD027);
    String titleText = _currentStatus;
    String descText =
        'Your request has been sent. Please wait for a response from the owner';

    final s = _currentStatus.toLowerCase();
    if (s == 'selesai') {
      dotColor = const Color(0xFF2FD677);
      titleText = 'Selesai';
      descText =
          'Transaksi telah selesai! Buku telah berhasil diserahterimakan.';
    } else if (s == 'sedang_dipinjam') {
      dotColor = const Color(0xFF388AF6);
      titleText = 'Sedang Dipinjam';
      descText =
          'Buku sedang dipinjam. Harap jaga kondisi buku dan kembalikan tepat waktu.';
    } else if (s == 'dibatalkan' || s == 'ditolak') {
      dotColor = const Color(0xFFFF4D4F);
      titleText = _currentStatus == 'ditolak' ? 'Ditolak' : 'Dibatalkan';
      descText = 'Transaksi ini telah ditutup.';
    } else if (s == 'disetujui' || s == 'lokasi_ditentukan' || s == 'dalam_proses') {
      dotColor = const Color(0xFF388AF6);
      titleText = 'Disetujui / Dalam Proses';
      descText =
          'Permintaan disetujui. Selesaikan pembayaran deposit dan penentuan lokasi serah terima.';
    }

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
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4A4960),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    descText,
                    style: const TextStyle(
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
                    color: _youConfirmed ? const Color(0xFF2FD677) : const Color(0xFFFFD027),
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
                    color: _ownerConfirmed ? const Color(0xFF2FD677) : const Color(0xFFFFD027),
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
            if (!_youConfirmed) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _konfirmasiSerahTerima,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Konfirmasi Serah Terima',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FAF0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Color(0xFF2FD677),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Anda telah mengonfirmasi serah terima buku.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0C9A4B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  Widget _buildReturnCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF388AF6).withValues(alpha: 0.3),
            width: 1.2,
          ),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F1FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.assignment_return_rounded,
                    color: Color(0xFF388AF6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Pengembalian Buku Pinjaman',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF130F26),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Buku saat ini sedang dalam masa peminjaman. Jika sudah selesai dibaca, lakukan konfirmasi pengembalian buku kepada pemilik untuk menyelesaikan transaksi dan mencairkan kembali saldo deposit jaminan Anda.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF7E7A92),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _isLoadingAction ? null : _konfirmasiPengembalianBuku,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF388AF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: _isLoadingAction
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                label: Text(
                  _isLoadingAction
                      ? 'Memproses...'
                      : 'Konfirmasi Pengembalian Buku',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2FD677).withValues(alpha: 0.3),
            width: 1.2,
          ),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FAF0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFB800),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Ulasan & Penilaian Transaksi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF130F26),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (!_hasReviewed) ...[
              Text(
                'Transaksi telah selesai! Bagikan ulasan dan berikan penilaian bintang untuk ${widget.ownerName} guna membantu membangun reputasi komunitas mahasiswa.',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7E7A92),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _bukaModalReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB800),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(
                    Icons.rate_review_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Beri Ulasan Sekarang',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F8FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < _myRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 18,
                            color: const Color(0xFFFFB800),
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '$_myRating / 5',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF130F26),
                          ),
                        ),
                      ],
                    ),
                    if (_myComment.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '"$_myComment"',
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF4A4960),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: Color(0xFF2FD677),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Ulasan Anda telah tersimpan di sistem.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0C9A4B),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final s = _currentStatus.toLowerCase();
    final isDone = s == 'selesai';
    final isBorrowing = s == 'sedang_dipinjam';
    final isCancelled = s == 'dibatalkan' || s == 'ditolak';

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
          if (!isCancelled) ...[
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 48,
                child: isBorrowing
                    ? ElevatedButton(
                        onPressed: _isLoadingAction
                            ? null
                            : _konfirmasiPengembalianBuku,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF388AF6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Kembalikan Buku',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : isDone
                        ? ElevatedButton(
                            onPressed: _bukaModalReview,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _hasReviewed
                                  ? const Color(0xFFE8FAF0)
                                  : const Color(0xFFFFF7E6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              _hasReviewed ? 'Ubah Ulasan' : 'Beri Ulasan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _hasReviewed
                                    ? const Color(0xFF0C9A4B)
                                    : const Color(0xFFD48806),
                              ),
                            ),
                          )
                        : ElevatedButton(
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
              if (_currentStatus.toLowerCase() == 'sedang_dipinjam') ...[
                const SizedBox(height: 14),
                _buildReturnCard(),
              ],
              if (_currentStatus.toLowerCase() == 'selesai') ...[
                const SizedBox(height: 14),
                _buildReviewSection(),
              ],
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
