import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/book_cover_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/screens/chat_page.dart';
import '../../../chat/presentation/screens/chat_room_page.dart';
import '../../../home/presentation/screens/home_page.dart';
import '../../../profile/presentation/screens/profile_page.dart';
import '../../../books/presentation/screens/my_book_page.dart';
import '../../../books/presentation/screens/search_page.dart';
import '../providers/transaction_provider.dart';
import '../../domain/models/transaction_model.dart';
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
  final bool? isOwner;
  final DateTime? dueDate;
  final bool? isOverdue;

  const TransactionDetailPage({
    super.key,
    this.transactionId,
    this.ownerId,
    this.isOwner,
    this.bookTitle = 'Buku Kampus',
    this.bookAuthor = 'Penulis',
    this.coverPath = 'assets/images/bookshelf.jpg',
    this.type = 'Borrow',
    this.requestedDate = 'Hari ini',
    this.preferredPeriod = '1 minggu',
    this.depositAmount = '20.000 Rupiah',
    this.isDepositPaid = false,
    this.handoverLocation = 'Tentukan lokasi',
    this.ownerName = 'Pemilik Buku',
    this.ownerUsername = '@pemilik',
    this.status = 'Menunggu Konfirmasi',
    this.youConfirmed = false,
    this.ownerConfirmed = false,
    this.dueDate,
    this.isOverdue,
  });

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final int _selectedIndex = 2;

  bool get _isOverdue {
    if (widget.isOverdue == true) return true;
    final s = _currentStatus.toLowerCase();
    if (s == 'selesai' || s == 'ditolak' || s == 'dibatalkan' || s == 'pending' || s == 'menunggu konfirmasi') {
      return false;
    }
    if (widget.dueDate != null) {
      return DateTime.now().isAfter(widget.dueDate!);
    }
    return false;
  }
  late bool _depositPaid;
  late String _currentHandoverLocation;
  late String _currentStatus;
  late bool _youConfirmed;
  late bool _ownerConfirmed;
  bool _hasReviewed = false;
  int _myRating = 5;
  String _myComment = '';
  bool _isLoadingAction = false;

  String _parseDisplayLocation(String raw) {
    if (raw.contains('| JADWAL:')) {
      return raw.split('| JADWAL:').first.trim();
    }
    return raw.trim();
  }

  String _parseDisplayTime(String raw) {
    if (raw.contains('| JADWAL:')) {
      return raw.split('| JADWAL:').last.trim();
    }
    return '';
  }

  static String _getNamaBulan(int month) {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    if (month >= 1 && month <= 12) return bulan[month - 1];
    return '';
  }

  bool get _isHandoverSet {
    final loc = _currentHandoverLocation.trim().toLowerCase();
    return loc.isNotEmpty &&
        loc != 'tentukan lokasi' &&
        loc != 'set handover' &&
        loc != 'pilih lokasi' &&
        loc != 'belum ditentukan';
  }

  @override
  void initState() {
    super.initState();
    final s = widget.status.toLowerCase();
    _depositPaid = widget.isDepositPaid ||
        s == 'dalam_proses' ||
        s == 'lokasi_ditentukan' ||
        s == 'sedang_dipinjam' ||
        s == 'selesai';
    _currentHandoverLocation = widget.handoverLocation;
    _currentStatus = widget.status;
    _youConfirmed = widget.youConfirmed;
    _ownerConfirmed = widget.ownerConfirmed;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final tx = _getTrx(context);
      if (tx != null && tx.lokasiPertemuan.trim().isNotEmpty) {
        setState(() {
          _currentHandoverLocation = tx.lokasiPertemuan;
        });
      }
      try {
        final auth = context.read<AuthProvider>();
        final intId = int.tryParse(widget.transactionId ?? tx?.id ?? '');
        if (auth.token != null && intId != null && !_isHandoverSet) {
          final loc = await context.read<TransactionProvider>().checkHandoverFromChat(auth.token!, intId);
          if (mounted && loc != null && loc.isNotEmpty) {
            setState(() {
              _currentHandoverLocation = loc;
            });
          }
        }
      } catch (_) {}
      _refreshTransactionData();
    });
  }

  Future<void> _refreshTransactionData() async {
    if (widget.transactionId == null) return;
    try {
      final auth = context.read<AuthProvider>();
      if (auth.token != null) {
        final trxProvider = context.read<TransactionProvider>();
        final tx = await trxProvider.fetchTransaksiById(
          auth.token!,
          widget.transactionId!,
        );
        if (mounted && tx != null) {
          setState(() {
            if (tx.lokasiPertemuan.trim().isNotEmpty) {
              _currentHandoverLocation = tx.lokasiPertemuan;
            }
          });
        }
        final intId = int.tryParse(widget.transactionId!);
        if (intId != null && (_currentHandoverLocation.isEmpty || !_isHandoverSet)) {
          final loc = await trxProvider.checkHandoverFromChat(auth.token!, intId);
          if (mounted && loc != null && loc.isNotEmpty) {
            setState(() {
              _currentHandoverLocation = loc;
            });
          }
        }
        if (mounted && tx != null) {
          setState(() {
            final s = tx.status.toLowerCase();
            if (s == 'dalam_proses' ||
                s == 'lokasi_ditentukan' ||
                s == 'sedang_dipinjam' ||
                s == 'selesai') {
              _depositPaid = true;
            }
            if (tx.requesterConfirmedAt != null) {
              if (_isCurrentUserOwner(context)) {
                _ownerConfirmed = true;
              } else {
                _youConfirmed = true;
              }
            }
            if (tx.ownerConfirmedAt != null) {
              if (_isCurrentUserOwner(context)) {
                _youConfirmed = true;
              } else {
                _ownerConfirmed = true;
              }
            }
          });
        }
      }
    } catch (_) {}
  }

  void _konfirmasiSerahTerima() {
    if (!_isHandoverSet) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Silakan tentukan jadwal & lokasi handover terlebih dahulu.'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      _onTapHandover();
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Confirm Handover',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF130F26),
            ),
          ),
          content: Text(
            'Have you handed over or received "${widget.bookTitle}" at $_currentHandoverLocation?',
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
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8A88A5),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);

                bool success = true;
                if (widget.transactionId != null) {
                  try {
                    final auth = context.read<AuthProvider>();
                    if (auth.token != null) {
                      final trxProvider = context.read<TransactionProvider>();
                      success = await trxProvider.confirmHandoverApi(
                        auth.token!,
                        widget.transactionId!,
                      );
                      if (success) {
                        await trxProvider.fetchTransaksiById(
                          auth.token!,
                          widget.transactionId!,
                        );
                      }
                    }
                  } catch (_) {
                    success = false;
                  }
                }

                if (!mounted) return;

                if (!success) {
                  final errMsg =
                      context.read<TransactionProvider>().errorMessage ??
                          'Failed to confirm handover.';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errMsg),
                      backgroundColor: const Color(0xFFF05151),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  _youConfirmed = true;
                });

                final txAfter = _getTrx(context);
                final isOwner = _isCurrentUserOwner(context);
                final partnerAlsoConfirmed = _ownerConfirmed ||
                    (isOwner
                        ? (txAfter?.requesterConfirmedAt != null)
                        : (txAfter?.ownerConfirmedAt != null));

                setState(() {
                  if (partnerAlsoConfirmed ||
                      txAfter?.status.toLowerCase() == 'selesai') {
                    _currentStatus = 'selesai';
                  }
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      partnerAlsoConfirmed ||
                              txAfter?.status.toLowerCase() == 'selesai'
                          ? 'Handover completed! Transaction is now completed.'
                          : 'Your handover confirmation has been recorded.',
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
                'Yes, Confirm',
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

  void _bukaModalCekDepositPemilik() {
    final partnerName = _getPartnerName(context);
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _depositPaid
                          ? const Color(0xFFE8FAF0)
                          : const Color(0xFFFFF1F0),
                    ),
                    child: Center(
                      child: Icon(
                        _depositPaid
                            ? Icons.check_circle_rounded
                            : Icons.info_outline_rounded,
                        color: _depositPaid
                            ? const Color(0xFF2FD677)
                            : const Color(0xFFF05151),
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Status Deposit Peminjam',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF130F26),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _depositPaid
                        ? 'Peminjam sudah melunasi uang deposit'
                        : 'Peminjam belum membayar deposit',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _depositPaid
                          ? const Color(0xFF0C9A4B)
                          : const Color(0xFFDC2626),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F6FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Peminjam',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF7E7A92),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                partnerName,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF130F26),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Nominal Deposit',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF7E7A92),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.depositAmount,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF130F26),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Status Pembayaran',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF7E7A92),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: _depositPaid
                                    ? const Color(0xFFE8FAF0)
                                    : const Color(0xFFFFF1F0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _depositPaid ? 'Lunas' : 'Belum Dibayar',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _depositPaid
                                      ? const Color(0xFF0C9A4B)
                                      : const Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _depositPaid
                        ? 'Dana jaminan sebesar ${widget.depositAmount} telah diamankan oleh sistem Librava.'
                        : 'Harap pastikan $partnerName melunasi deposit sebelum melakukan serah terima fisik buku.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7E7A92),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
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

  void _onTapDeposit() {
    final isOwner = _isCurrentUserOwner(context);
    if (isOwner) {
      _bukaModalCekDepositPemilik();
    } else {
      _bukaModalBayarDeposit();
    }
  }

  void _bukaModalBayarDeposit() {
    // Yang meminjamkan (pemilik) tidak boleh mengisi form pembayaran deposit!
    if (_isCurrentUserOwner(context)) {
      _bukaModalCekDepositPemilik();
      return;
    }

    if (widget.type.toLowerCase() == 'barter') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Barter transactions do not require a security deposit.',
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_depositPaid) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Deposit Sudah Dibayar',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF130F26),
            ),
          ),
          content: Text(
            'Uang jaminan sebesar ${widget.depositAmount} sudah Anda bayarkan dan diamankan oleh sistem.\n\nDeposit akan dikembalikan penuh setelah buku dikembalikan ke pemilik.',
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF7E7A92),
              height: 1.4,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Tutup',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

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
                AuthProvider? auth;
                try {
                  auth = context.read<AuthProvider>();
                } catch (_) {}
                TransactionProvider? trxProvider;
                try {
                  trxProvider = context.read<TransactionProvider>();
                } catch (_) {}

                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(ctx);
                final depositNominal = double.tryParse(
                      widget.depositAmount.replaceAll(RegExp(r'[^0-9]'), ''),
                    ) ??
                    20000.0;

                // Memotong saldo dummy pengguna jika provider tersedia
                auth?.potongSaldoDummy(depositNominal);

                if (widget.transactionId != null && auth != null && auth.token != null && trxProvider != null) {
                  try {
                    await trxProvider.updateStatusApi(
                          auth.token!,
                          widget.transactionId!,
                          'DALAM_PROSES',
                        );
                    await auth.segarkanProfil();
                  } catch (_) {}
                }
                navigator.pop();
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Payment successful! Deposit is now secured.'),
                    backgroundColor: Color(0xFF2FD677),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _prosesPersetujuanPemilik(bool setujui) async {
    final auth = context.read<AuthProvider>();
    final trxProvider = context.read<TransactionProvider>();
    final messenger = ScaffoldMessenger.of(context);

    if (widget.transactionId == null || auth.token == null) {
      setState(() {
        _currentStatus = setujui ? 'disetujui' : 'ditolak';
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            setujui
                ? 'Borrow request accepted successfully!'
                : 'Borrow request declined.',
          ),
          backgroundColor: setujui ? const Color(0xFF2FD677) : const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoadingAction = true);

    try {
      final backendStatus = setujui ? 'DISETUJUI' : 'DITOLAK';
      final success = await trxProvider.updateStatusApi(
        auth.token!,
        widget.transactionId!,
        backendStatus,
      );

      if (!mounted) return;

      if (success) {
        setState(() {
          _currentStatus = setujui ? 'disetujui' : 'ditolak';
        });
        await trxProvider.fetchTransaksiById(
          auth.token!,
          widget.transactionId!,
        );
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              setujui
                  ? 'Request approved! Waiting for borrower to secure deposit and arrange handover.'
                  : 'Request declined.',
            ),
            backgroundColor: setujui ? const Color(0xFF2FD677) : const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              trxProvider.errorMessage ?? 'Failed to update transaction status.',
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingAction = false);
      }
    }
  }

  void _konfirmasiSetujuiPermintaan() {
    final partnerName = _getPartnerName(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Accept Request',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF130F26),
          ),
        ),
        content: Text(
          'Are you sure you want to approve the borrow request from $partnerName for "${widget.bookTitle}"?\n\nThe borrower will then secure the deposit and coordinate book handover.',
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
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF8A88A5),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _prosesPersetujuanPemilik(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2FD677),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Yes, Accept',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _konfirmasiTolakPermintaan() {
    final partnerName = _getPartnerName(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Decline Request',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF130F26),
          ),
        ),
        content: Text(
          'Are you sure you want to decline this borrow request from $partnerName for "${widget.bookTitle}"?',
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
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF8A88A5),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _prosesPersetujuanPemilik(false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Decline',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _bukaModalCekHandoverPemilik() async {
    final tx = _getTrx(context);
    if (tx != null && tx.lokasiPertemuan.trim().isNotEmpty) {
      _currentHandoverLocation = tx.lokasiPertemuan;
    }

    if (!_isHandoverSet) {
      try {
        final auth = context.read<AuthProvider>();
        final intId = int.tryParse(widget.transactionId ?? tx?.id ?? '');
        if (auth.token != null && intId != null) {
          final loc = await context.read<TransactionProvider>().checkHandoverFromChat(auth.token!, intId);
          if (mounted && loc != null && loc.isNotEmpty) {
            setState(() {
              _currentHandoverLocation = loc;
            });
          }
        }
      } catch (_) {}
    }
    _refreshTransactionData();

    if (!mounted) return;
    final partnerName = _getPartnerName(context);
    final isSet = _isHandoverSet;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSet
                          ? const Color(0xFFE8FAF0)
                          : const Color(0xFFFFF1F0),
                    ),
                    child: Center(
                      child: Icon(
                        isSet
                            ? Icons.place_rounded
                            : Icons.location_off_rounded,
                        color: isSet
                            ? const Color(0xFF2FD677)
                            : const Color(0xFFF05151),
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Status Serah Terima Buku',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF130F26),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isSet
                        ? 'Lokasi serah terima sudah ditentukan'
                        : 'Peminjam belum menentukan lokasi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSet
                          ? const Color(0xFF0C9A4B)
                          : const Color(0xFFDC2626),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F6FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Peminjam',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF7E7A92),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                partnerName,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF130F26),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Lokasi Handover',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF7E7A92),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                isSet ? _parseDisplayLocation(_currentHandoverLocation) : 'Belum ditentukan',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSet
                                      ? const Color(0xFF130F26)
                                      : const Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isSet && _parseDisplayTime(_currentHandoverLocation).isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Jadwal Pertemuan',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF7E7A92),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  _parseDisplayTime(_currentHandoverLocation),
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF130F26),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Status Handover',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF7E7A92),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSet
                                    ? const Color(0xFFE8FAF0)
                                    : const Color(0xFFFFF1F0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isSet ? 'Sudah Ditentukan' : 'Belum Ditentukan',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isSet
                                      ? const Color(0xFF0C9A4B)
                                      : const Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isSet
                        ? (_parseDisplayTime(_currentHandoverLocation).isNotEmpty
                            ? 'Silakan temui $partnerName di ${_parseDisplayLocation(_currentHandoverLocation)} pada ${_parseDisplayTime(_currentHandoverLocation)} untuk melakukan serah terima fisik buku.'
                            : 'Silakan temui $partnerName di ${_parseDisplayLocation(_currentHandoverLocation)} untuk melakukan serah terima fisik buku.')
                        : 'Harap tunggu $partnerName menentukan lokasi dan waktu pertemuan setelah deposit diselesaikan.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7E7A92),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
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

  void _onTapHandover() {
    _bukaModalSetHandover();
  }

  void _bukaModalSetHandover() {
    if (_isCurrentUserOwner(context)) {
      _bukaModalCekHandoverPemilik();
      return;
    }
    _bukaModalSetHandoverPeminjam();
  }

  void _bukaModalSetHandoverPeminjam() {
    _bukaModalSetHandoverForm();
  }

  void _bukaModalSetHandoverForm() {
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
              initialLocation: _isHandoverSet
                  ? _currentHandoverLocation
                  : 'Open Library Telkom University',
              isOwner: _isCurrentUserOwner(context),
              onClose: () => Navigator.pop(ctx),
              onHandoverConfirmed: (selectedLocation, [meetingTime]) async {
                final String timeStr = meetingTime != null
                    ? '${meetingTime.day} ${_getNamaBulan(meetingTime.month)} ${meetingTime.year}, ${meetingTime.hour.toString().padLeft(2, '0')}:${meetingTime.minute.toString().padLeft(2, '0')}'
                    : '';
                final combined = timeStr.isNotEmpty
                    ? '$selectedLocation | JADWAL: $timeStr'
                    : selectedLocation;

                setState(() {
                  _currentHandoverLocation = combined;
                });
                Navigator.pop(ctx);

                final trxProv = context.read<TransactionProvider>();
                trxProv.updateLokasiTransaksi(
                  id: widget.transactionId,
                  judulBuku: widget.bookTitle,
                  lokasi: combined,
                );

                try {
                  final auth = context.read<AuthProvider>();
                  final token = auth.token;
                  final txId = widget.transactionId ?? _getTrx(context)?.id;
                  if (token != null && txId != null) {
                    await trxProv.setMeetingApi(
                      token,
                      txId,
                      combined,
                      meetingTime?.toIso8601String(),
                    );
                    if (mounted) {
                      await trxProv.fetchTransaksiById(token, txId);
                    }
                  }
                } catch (_) {}
                if (mounted) {
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
                }
              },
            ),
          ),
        );
      },
    );
  }

  TransactionModel? _getTrx(BuildContext context) {
    try {
      final trxProvider = context.read<TransactionProvider>();
      if (widget.transactionId != null && widget.transactionId!.trim().isNotEmpty) {
        final txId = widget.transactionId!.trim().toLowerCase();
        final found = trxProvider.semuaTransaksi
            .where((t) => t.id.trim().toLowerCase() == txId)
            .firstOrNull;
        if (found != null) return found;
      }
      final title = widget.bookTitle.trim().toLowerCase();
      if (title.isNotEmpty) {
        final found = trxProvider.semuaTransaksi
            .where((t) => t.judulBuku.trim().toLowerCase() == title)
            .firstOrNull;
        if (found != null) return found;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  bool _isCurrentUserOwner(BuildContext context) {
    if (widget.isOwner != null) return widget.isOwner!;
    try {
      final auth = context.read<AuthProvider>();
      final user = auth.currentUser;
      if (user == null) return false;
      final uid = user.id.trim();
      final uname = user.nama.trim().toLowerCase();
      final uusername = user.username.trim().toLowerCase();

      // 1. Cek parameter eksplisit widget
      if (widget.ownerId != null && widget.ownerId!.trim().isNotEmpty) {
        if (uid.isNotEmpty && widget.ownerId!.trim() == uid) return true;
      }
      if (widget.ownerName.trim().isNotEmpty &&
          widget.ownerName.trim().toLowerCase() != 'pemilik buku') {
        final wOwnerName = widget.ownerName.trim().toLowerCase();
        if (uname.isNotEmpty &&
            (wOwnerName == uname ||
                wOwnerName.contains(uname) ||
                uname.contains(wOwnerName))) {
          return true;
        }
      }
      if (widget.ownerUsername.trim().isNotEmpty &&
          widget.ownerUsername.trim().toLowerCase() != '@pemilik') {
        final cleanWidgetUsername =
            widget.ownerUsername.replaceAll('@', '').trim().toLowerCase();
        final cleanUserUsername =
            uusername.replaceAll('@', '').trim().toLowerCase();
        if (cleanWidgetUsername == cleanUserUsername) return true;
      }

      // 2. Cek transaksi dari provider jika ada transactionId
      final tx = _getTrx(context);
      if (tx != null) {
        // Jika pemohon, pasti bukan owner
        if (uid.isNotEmpty &&
            tx.pemohonId.trim().isNotEmpty &&
            tx.pemohonId.trim() == uid) {
          return false;
        }
        if (uname.isNotEmpty &&
            tx.pemohonNama.trim().isNotEmpty &&
            tx.pemohonNama.trim().toLowerCase() == uname) {
          return false;
        }
        // Jika pemilik, pasti owner
        if (uid.isNotEmpty &&
            tx.pemilikId.trim().isNotEmpty &&
            tx.pemilikId.trim() == uid) {
          return true;
        }
        if (uname.isNotEmpty &&
            tx.pemilikNama.trim().isNotEmpty &&
            tx.pemilikNama.trim().toLowerCase() == uname) {
          return true;
        }
      }

      // 3. Cek daftar transaksi masuk di provider
      if (widget.transactionId != null && widget.transactionId!.isNotEmpty) {
        final trxProvider = context.read<TransactionProvider>();
        final txId = widget.transactionId!.trim().toLowerCase();
        final inMasuk = trxProvider.requestMasuk
            .any((t) => t.id.trim().toLowerCase() == txId);
        if (inMasuk) return true;
        final inSaya = trxProvider.requestSaya
            .any((t) => t.id.trim().toLowerCase() == txId);
        if (inSaya) return false;
      }
    } catch (_) {}
    return false;
  }

  String _getPartnerName(BuildContext context) {
    final tx = _getTrx(context);
    final isOwner = _isCurrentUserOwner(context);
    if (isOwner) {
      return (tx != null && tx.pemohonNama.isNotEmpty)
          ? tx.pemohonNama
          : 'Pemohon Buku';
    }
    return widget.ownerName.isNotEmpty
        ? widget.ownerName
        : (tx?.pemilikNama ?? 'Pemilik Buku');
  }

  String? _getPartnerId(BuildContext context) {
    final tx = _getTrx(context);
    final isOwner = _isCurrentUserOwner(context);
    if (isOwner) {
      return (tx != null && tx.pemohonId.isNotEmpty) ? tx.pemohonId : null;
    }
    return widget.ownerId ??
        (tx != null && tx.pemilikId.isNotEmpty ? tx.pemilikId : null);
  }

  String _getDisplayAuthor(BuildContext context) {
    if (widget.bookAuthor.isNotEmpty &&
        widget.bookAuthor != 'Penulis' &&
        widget.bookAuthor != 'Pemilik Buku') {
      return widget.bookAuthor;
    }
    final tx = _getTrx(context);
    if (tx != null && tx.penulisBuku.isNotEmpty && tx.penulisBuku != 'Penulis') {
      return tx.penulisBuku;
    }
    final title = (tx?.judulBuku ?? widget.bookTitle).toLowerCase();
    if (title.contains('basis data')) return 'Fathansyah';
    if (title.contains('atomic')) return 'James Clear';
    if (title.contains('midnight')) return 'Matt Haig';
    if (title.contains('clean code')) return 'Robert C. Martin';
    if (title.contains('laskar')) return 'Andrea Hirata';
    if (title.contains('filosofi')) return 'Henry Manampiring';
    if (tx != null && tx.pemilikNama.isNotEmpty && tx.pemilikNama != 'Pemilik Buku') {
      return tx.pemilikNama;
    }
    if (widget.ownerName.isNotEmpty && widget.ownerName != 'Pemilik Buku') {
      return widget.ownerName;
    }
    return widget.bookAuthor.isNotEmpty ? widget.bookAuthor : 'Penulis';
  }

  String _getDisplayCover(BuildContext context) {
    final raw = widget.coverPath;
    final tx = _getTrx(context);
    final foto = (tx != null &&
            tx.coverBuku.isNotEmpty &&
            tx.coverBuku != 'assets/images/book_the_unknown.jpg')
        ? tx.coverBuku
        : (raw.isNotEmpty && raw != 'assets/images/book_the_unknown.jpg'
            ? raw
            : null);
    final title = tx?.judulBuku ?? widget.bookTitle;
    return BookCoverHelper.getCover(fotoBuku: foto, judul: title);
  }

  void _bukaHalamanProfilPemilik() {
    final partnerName = _getPartnerName(context);
    final partnerId = _getPartnerId(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileViewPage(
          userId: partnerId,
          name: partnerName,
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
    final isOwner = _isCurrentUserOwner(context);
    final partnerName = _getPartnerName(context);
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
                  Text(
                    isOwner
                        ? 'Pengembalian Dikonfirmasi!'
                        : 'Deposit Dikembalikan!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF130F26),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isOwner
                        ? 'Fisik buku "${widget.bookTitle}" telah diterima kembali dari $partnerName. Transaksi kini berstatus selesai.'
                        : 'Buku "${widget.bookTitle}" telah dikembalikan kepada $partnerName. Jaminan peminjaman telah dikembalikan penuh ke saldo Anda.',
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
                            Text(
                              isOwner
                                  ? 'Transaction Status'
                                  : 'Refunded Amount',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF7E7A92),
                              ),
                            ),
                            Text(
                              isOwner ? 'Completed' : '+$depositAmount',
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
                            Text(
                              isOwner ? 'Borrower' : 'Current Wallet Balance',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF7E7A92),
                              ),
                            ),
                            Text(
                              isOwner ? partnerName : 'Rp $formattedSaldo',
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
                        _hasReviewed
                            ? 'Done'
                            : (isOwner
                                ? 'Review Requester'
                                : 'Review Owner'),
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
    final isOwner = _isCurrentUserOwner(context);
    final partnerName = _getPartnerName(context);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            isOwner
                ? 'Confirm Book Received'
                : 'Confirm Book Return',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF130F26),
            ),
          ),
          content: Text(
            isOwner
                ? 'Have you received the physical book "${widget.bookTitle}" back from $partnerName in good condition?\n\nOnce confirmed, this transaction will be completed.'
                : 'Have you returned the book "${widget.bookTitle}" to $partnerName?\n\nOnce confirmed, the transaction will be completed and your security deposit will be refunded.',
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
                'Cancel',
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

                // Jika peminjam yang menyelesaikan, kembalikan saldo jaminan ke dompet peminjam
                if (!isOwner) {
                  auth.tambahSaldoDummy(depositNominal);
                }

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

                if (!isOwner) {
                  final updatedSaldo =
                      auth.currentUser?.saldoDummy ?? 100000.0;
                  _tampilkanDialogPengembalianDepositSukses(
                    context: context,
                    depositAmount: widget.depositAmount,
                    updatedSaldo: updatedSaldo,
                  );
                }

                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      isOwner
                          ? 'Return receipt confirmed. The borrow transaction is now completed.'
                          : 'Book returned successfully! Transaction completed and security deposit refunded.',
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
              child: Text(
                isOwner ? 'Yes, Received' : 'Yes, Returned',
                style: const TextStyle(
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
                    'Leave Review & Rating',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF130F26),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Share your transaction experience with ${_getPartnerName(context)}',
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
                          ? 'Excellent! (5/5)'
                          : selectedRating == 4
                              ? 'Good (4/5)'
                              : selectedRating == 3
                                  ? 'Fair (3/5)'
                                  : selectedRating == 2
                                      ? 'Poor (2/5)'
                                      : 'Very Bad (1/5)',
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
                      hintText: 'Write your comments or thoughts (optional)...',
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
                                const Text('Your review has been submitted successfully!'),
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
                        'Submit Review',
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
            'Cancel Request?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF130F26),
            ),
          ),
          content: const Text(
            'Are you sure you want to cancel this book transaction?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7E7A92),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Back',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8A88A5),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);

                AuthProvider? auth;
                try {
                  auth = context.read<AuthProvider>();
                } catch (_) {}

                TransactionProvider? trxProvider;
                try {
                  trxProvider = context.read<TransactionProvider>();
                } catch (_) {}

                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                final depositNominal = double.tryParse(
                      widget.depositAmount.replaceAll(RegExp(r'[^0-9]'), ''),
                    ) ??
                    20000.0;

                setState(() {
                  _currentStatus = 'Cancelled';
                });

                // Jika deposit sudah dibayar sebelumnya dan transaksi dibatalkan, kembalikan saldo
                if (_depositPaid && !_isCurrentUserOwner(context)) {
                  auth?.tambahSaldoDummy(depositNominal);
                }

                if (widget.transactionId != null && auth?.token != null && trxProvider != null) {
                  try {
                    await trxProvider.updateStatusApi(
                      auth!.token!,
                      widget.transactionId!,
                      'DIBATALKAN',
                    );
                    await auth.segarkanProfil();
                  } catch (_) {}
                }

                if (!mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: const Text('Transaction request cancelled successfully.'),
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
                'Yes, Cancel',
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
    final cover = _getDisplayCover(context);
    final author = _getDisplayAuthor(context);
    final isOwner = _isCurrentUserOwner(context);

    final imageWidget = BookCoverHelper.buildCoverImage(
      cover,
      width: 92,
      height: 136,
      fallbackJudul: widget.bookTitle,
    );

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
              child: imageWidget,
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
                  author,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8A88A5),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOwner ? const Color(0xFFF0EEFF) : const Color(0xFFE8F1FD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isOwner
                          ? AppColors.primary.withValues(alpha: 0.25)
                          : const Color(0xFF388AF6).withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOwner ? Icons.share_rounded : Icons.bookmark_added_rounded,
                        size: 13,
                        color: isOwner ? AppColors.primary : const Color(0xFF388AF6),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isOwner ? 'Anda: Pemilik (Meminjamkan)' : 'Anda: Peminjam (Meminjam)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isOwner ? AppColors.primary : const Color(0xFF388AF6),
                        ),
                      ),
                    ],
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
    final isOverdue = _isOverdue;
    Color dotColor = const Color(0xFFFFD027);
    String titleText = _currentStatus;
    String descText =
        'Your request has been sent. Please wait for a response from the owner';

    final s = _currentStatus.toLowerCase();
    final isOwner = _isCurrentUserOwner(context);
    final partnerName = _getPartnerName(context);

    if (s == 'selesai') {
      dotColor = const Color(0xFF2FD677);
      titleText = 'Completed';
      descText = isOwner
          ? 'Transaction completed! The book "${widget.bookTitle}" has been returned by $partnerName in good condition.'
          : 'Transaction completed! The book has been successfully handed over and returned.';
    } else if (s == 'sedang_dipinjam') {
      dotColor = isOverdue ? const Color(0xFFDC2626) : const Color(0xFF388AF6);
      titleText = isOverdue ? 'Overdue Return' : 'Active Loan';
      descText = isOverdue
          ? (isOwner
              ? 'The loan is past its due date. Please coordinate with $partnerName to return the book.'
              : 'The book is past its return due date. Please return it to $partnerName immediately.')
          : (isOwner
              ? 'The book is currently borrowed by $partnerName. Please coordinate return when finished.'
              : 'The book is currently on loan. Please keep it safe and return on time.');
    } else if (s == 'dibatalkan' || s == 'ditolak') {
      dotColor = const Color(0xFFFF4D4F);
      titleText = _currentStatus == 'ditolak' ? 'Rejected' : 'Cancelled';
      descText = 'This transaction has been closed.';
    } else if (s == 'disetujui' || s == 'lokasi_ditentukan' || s == 'dalam_proses') {
      dotColor = isOverdue ? const Color(0xFFDC2626) : const Color(0xFF388AF6);
      titleText = isOverdue ? 'Overdue' : 'Approved / In Progress';
      final txForBanner = _getTrx(context);
      final effLoc = (txForBanner != null && txForBanner.lokasiPertemuan.trim().isNotEmpty)
          ? txForBanner.lokasiPertemuan
          : _currentHandoverLocation;
      final effLocTrim = effLoc.trim().toLowerCase();
      final effHandoverSet = effLocTrim.isNotEmpty &&
          effLocTrim != 'tentukan lokasi' &&
          effLocTrim != 'set handover' &&
          effLocTrim != 'pilih lokasi' &&
          effLocTrim != 'belum ditentukan';

      if (isOwner) {
        descText = _depositPaid
            ? (effHandoverSet
                ? 'Handover set at $effLoc. Please meet $partnerName to hand over the book.'
                : 'Deposit secured. Waiting for $partnerName to arrange handover location and meeting time.')
            : 'Request approved. Waiting for $partnerName to secure the deposit and set handover.';
      } else {
        descText = isOverdue
            ? 'Loan is past its due date. Please coordinate book return promptly.'
            : (_depositPaid
                ? (effHandoverSet
                    ? 'Handover set at $effLoc. Please meet $partnerName for book handover.'
                    : 'Deposit payment secured! Please determine handover schedule & location.')
                : 'Request approved. Complete the deposit payment and set the handover location.');
      }
    } else if (s == 'pending' || s == 'menunggu konfirmasi' || s == 'menunggu_konfirmasi') {
      dotColor = const Color(0xFFFFD027);
      if (isOwner) {
        titleText = 'Permohonan Masuk';
        descText = '$partnerName mengajukan permohonan untuk meminjam "${widget.bookTitle}". Silakan setujui atau tolak permintaan ini.';
      } else {
        titleText = _currentStatus;
        descText = 'Your request has been sent. Please wait for a response from the owner';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isOverdue ? const Color(0xFFFFF5F5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isOverdue ? Border.all(color: const Color(0xFFFCA5A5), width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: isOverdue
                  ? const Color(0xFFDC2626).withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.03),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          titleText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isOverdue ? const Color(0xFFB91C1C) : const Color(0xFF4A4960),
                          ),
                        ),
                      ),
                      if (isOverdue)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'OVERDUE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    descText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: isOverdue ? const Color(0xFF991B1B) : const Color(0xFF8A88A5),
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
            if (widget.dueDate != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                label: 'Due date',
                value:
                    '${widget.dueDate!.day}/${widget.dueDate!.month}/${widget.dueDate!.year}${_isOverdue ? ' (Overdue)' : ''}',
                valueColor: _isOverdue ? const Color(0xFFDC2626) : null,
              ),
            ],
            const SizedBox(height: 12),
            _buildInteractiveInfoRow(
              label: 'Deposit',
              value: widget.depositAmount,
              dotColor: _depositPaid ? const Color(0xFF2FD677) : const Color(0xFFF05151),
              onTap: _onTapDeposit,
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final tx = _getTrx(context);
                final effectiveLoc = (tx != null && tx.lokasiPertemuan.trim().isNotEmpty)
                    ? tx.lokasiPertemuan
                    : _currentHandoverLocation;
                final bool isOwner = _isCurrentUserOwner(context);
                final locTrim = effectiveLoc.trim().toLowerCase();
                final bool isHandoverSet = locTrim.isNotEmpty &&
                    locTrim != 'tentukan lokasi' &&
                    locTrim != 'set handover' &&
                    locTrim != 'pilih lokasi' &&
                    locTrim != 'belum ditentukan';
                final cleanLoc = _parseDisplayLocation(effectiveLoc);
                final String displayHandover = isOwner
                    ? (isHandoverSet ? cleanLoc : 'Belum ditentukan')
                    : (isHandoverSet ? cleanLoc : 'Tentukan lokasi');
                final Color handoverDotColor = isHandoverSet
                    ? const Color(0xFF2FD677)
                    : const Color(0xFFF05151);

                return _buildInteractiveInfoRow(
                  label: 'Handover',
                  value: displayHandover,
                  dotColor: handoverDotColor,
                  onTap: _onTapHandover,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value, Color? valueColor}) {
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF4A4960),
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
    final isOwner = _isCurrentUserOwner(context);
    final partnerRole = isOwner ? 'Requester' : 'Owner';
    final tx = _getTrx(context);
    final isDone = _currentStatus.toLowerCase() == 'selesai';

    final bool youIsConfirmed = _youConfirmed ||
        isDone ||
        (isOwner
            ? (tx?.ownerConfirmedAt != null)
            : (tx?.requesterConfirmedAt != null));

    final bool partnerIsConfirmed = _ownerConfirmed ||
        isDone ||
        (isOwner
            ? (tx?.requesterConfirmedAt != null)
            : (tx?.ownerConfirmedAt != null));

    final bool bothConfirmed = youIsConfirmed && partnerIsConfirmed;

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
                    color: youIsConfirmed
                        ? const Color(0xFF2FD677)
                        : const Color(0xFFFFD027),
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
                    color: partnerIsConfirmed
                        ? const Color(0xFF2FD677)
                        : const Color(0xFFFFD027),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  partnerRole,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4960),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  CupertinoIcons.info_circle_fill,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    bothConfirmed
                        ? 'Kedua pihak telah mengonfirmasi serah terima'
                        : 'Transaction will complete after both parties confirm',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8A88A5),
                    ),
                  ),
                ),
              ],
            ),
            if (!youIsConfirmed) ...[
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
                    'Confirm Handover',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ] else if (!partnerIsConfirmed) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FAF0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Color(0xFF2FD677),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have confirmed. Waiting for $partnerRole to confirm handover.',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0C9A4B),
                        ),
                      ),
                    ),
                  ],
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
                        'Book handover has been confirmed by both parties.',
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
    final isOwner = _isCurrentUserOwner(context);
    final partnerName = _getPartnerName(context);
    final partnerUsername = isOwner
        ? '@${partnerName.toLowerCase().replaceAll(' ', '')}'
        : widget.ownerUsername;

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
            Text(
              isOwner ? 'Requester information' : 'Owner information',
              style: const TextStyle(
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
                        partnerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF130F26),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        partnerUsername,
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
    final isOwner = _isCurrentUserOwner(context);

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
                Expanded(
                  child: Text(
                    isOwner
                        ? 'Confirm Book Return'
                        : 'Borrowed Book Return',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF130F26),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              isOwner
                  ? 'Book is currently borrowed by the student. Once the physical book is returned and received in good condition, confirm receipt to complete the transaction.'
                  : 'Book is currently on loan. When finished reading, confirm return with the owner to complete the transaction and release your security deposit.',
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
                      ? 'Processing...'
                      : (isOwner ? 'Confirm Book Received' : 'Confirm Book Return'),
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
                    'Transaction Review & Rating',
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
                'Transaction completed! Share a review and star rating for ${_getPartnerName(context)} to help build community trust.',
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
                    'Leave Review Now',
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
                    'Your review has been saved.',
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
    final isPending = s == 'pending' || s == 'menunggu konfirmasi' || s == 'menunggu_konfirmasi';
    final isOwner = _isCurrentUserOwner(context);
    final partnerName = _getPartnerName(context);

    // 1. Jika Pemilik Buku dan status masih PENDING:
    if (isOwner && isPending) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoadingAction ? null : _konfirmasiSetujuiPermintaan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2FD677),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Setujui',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isLoadingAction ? null : _konfirmasiTolakPermintaan,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFFDC2626), size: 18),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Tolak',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 2. Tampilan Standar:
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
                        userName: partnerName,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isOwner ? 'Message Requester' : 'Message Owner',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            isOwner ? 'Confirm Return' : 'Return Book',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
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
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _hasReviewed ? 'Edit Review' : 'Leave Review',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _hasReviewed
                                      ? const Color(0xFF0C9A4B)
                                      : const Color(0xFFD48806),
                                ),
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
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                isOwner ? 'Cancel' : 'Cancel Request',
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
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
    try {
      context.watch<TransactionProvider>();
    } catch (_) {}

    final currentTx = _getTrx(context);
    if (currentTx != null && currentTx.lokasiPertemuan.trim().isNotEmpty) {
      _currentHandoverLocation = currentTx.lokasiPertemuan;
    }

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
