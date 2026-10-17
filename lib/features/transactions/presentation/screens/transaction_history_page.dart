import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import 'transaction_detail_page.dart';

/// Halaman Riwayat Transaksi (SRS FR-TRX-02)
/// Menampilkan daftar seluruh transaksi pinjam & barter dengan filter status lengkap.
class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = const [
    'Semua',
    'Pinjam',
    'Barter',
    'Selesai',
    'Dibatalkan',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.token != null) {
        context.read<TransactionProvider>().fetchTransaksi(auth.token!);
      }
    });
  }

  String _getCoverForTransaction(TransactionModel trx) {
    if (trx.coverBuku.isNotEmpty &&
        trx.coverBuku != 'assets/images/book_the_unknown.jpg') {
      return trx.coverBuku;
    }
    final j = trx.judulBuku.toLowerCase();
    if (j.contains('atomic')) return 'assets/images/book_atomic_habits.jpg';
    if (j.contains('midnight')) return 'assets/images/book_midnight_lib.jpg';
    if (j.contains('clean code') || j.contains('pragmatic')) {
      return 'assets/images/bookshelf.jpg';
    }
    if (j.contains('basis data') ||
        j.contains('python') ||
        j.contains('jaringan')) {
      return 'assets/images/book_fruit_fly.jpg';
    }
    if (j.contains('laskar') || j.contains('filosofi')) {
      return 'assets/images/book_adversary.jpg';
    }
    return 'assets/images/book_the_unknown.jpg';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return const Color(0xFF52C41A);
      case 'sedang_dipinjam':
        return const Color(0xFF4C7BFE);
      case 'ditolak':
      case 'dibatalkan':
        return const Color(0xFFFF4D4F);
      case 'pending':
      case 'menunggu_konfirmasi':
      default:
        return const Color(0xFFFFDD2D);
    }
  }

  String _getStatusText(TransactionModel trx) {
    switch (trx.status.toLowerCase()) {
      case 'selesai':
        return 'Selesai';
      case 'sedang_dipinjam':
        return 'Sedang Dipinjam';
      case 'disetujui':
        return 'Disetujui';
      case 'deposit_dibayar':
        return 'Deposit Dibayar';
      case 'lokasi_ditentukan':
        return 'Lokasi Ditentukan';
      case 'ditolak':
        return 'Ditolak';
      case 'dibatalkan':
        return 'Dibatalkan';
      case 'pending':
      default:
        return 'Menunggu Konfirmasi';
    }
  }

  List<TransactionModel> _filterTransactions(List<TransactionModel> list) {
    switch (_selectedFilterIndex) {
      case 1: // Pinjam
        return list.where((t) => t.jenisTransaksi == 'pinjam').toList();
      case 2: // Barter
        return list.where((t) => t.jenisTransaksi == 'barter').toList();
      case 3: // Selesai
        return list.where((t) => t.status.toLowerCase() == 'selesai').toList();
      case 4: // Dibatalkan / Ditolak
        return list
            .where((t) =>
                t.status.toLowerCase() == 'dibatalkan' ||
                t.status.toLowerCase() == 'ditolak')
            .toList();
      case 0: // Semua
      default:
        return list;
    }
  }

  Widget _buildCoverWidget(String coverPath) {
    if (coverPath.startsWith('http://') || coverPath.startsWith('https://')) {
      return Image.network(
        coverPath,
        width: 64,
        height: 84,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 64,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFFE7E3FF),
              borderRadius: BorderRadius.circular(12),
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
      );
    }
    return Image.asset(
      coverPath,
      width: 64,
      height: 84,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 64,
          height: 84,
          decoration: BoxDecoration(
            color: const Color(0xFFE7E3FF),
            borderRadius: BorderRadius.circular(12),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final namaUser = auth.currentUser?.nama ?? 'User';
    final trxProvider = context.watch<TransactionProvider>();
    final allList = trxProvider.semuaTransaksi;
    final filteredList = _filterTransactions(allList);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.chevron_left,
            color: Color(0xFF130F26),
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF130F26),
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Tabs Row
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_filters.length, (index) {
                    final isSelected = _selectedFilterIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedFilterIndex = index;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFF3F2F8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _filters[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF6B667F),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEBE8F4)),

            // Transaction List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (auth.token != null) {
                    await trxProvider.fetchTransaksi(auth.token!);
                  }
                },
                child: filteredList.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.45,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFEFF9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.receipt_long_rounded,
                                      size: 36,
                                      color: Color(0xFF8A88A5),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Tidak Ada Transaksi',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF130F26),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Belum ada transaksi pada kategori ${_filters[_selectedFilterIndex].toLowerCase()}.',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF8A88A5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredList.length,
                        separatorBuilder: (_, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final trx = filteredList[index];
                          final subtitleText = trx.jenisTransaksi == 'barter'
                              ? 'Barter dengan ${trx.pemilikNama}'
                              : (trx.pemilikNama == namaUser
                                  ? 'Dipinjamkan ke ${trx.pemohonNama}'
                                  : 'Meminjam dari ${trx.pemilikNama}');

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TransactionDetailPage(
                                    transactionId: trx.id,
                                    bookTitle: trx.judulBuku,
                                    bookAuthor: trx.pemilikNama,
                                    coverPath: _getCoverForTransaction(trx),
                                    status: trx.status,
                                    depositAmount:
                                        '${trx.depositSimulasi.toInt()} Rupiah',
                                    ownerName: trx.pemilikNama,
                                    type: trx.jenisTransaksi == 'barter'
                                        ? 'Barter'
                                        : 'Borrow',
                                    dueDate: trx.dueDate ?? trx.effectiveDueDate,
                                    isOverdue: trx.isOverdue,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _buildCoverWidget(
                                      _getCoverForTransaction(trx),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: trx.jenisTransaksi ==
                                                        'barter'
                                                    ? const Color(0xFFF3EAFF)
                                                    : const Color(0xFFE8F1FD),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                trx.jenisTransaksi.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: trx.jenisTransaksi ==
                                                          'barter'
                                                      ? const Color(0xFF722ED1)
                                                      : const Color(0xFF1890FF),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              trx.tanggal,
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                color: Color(0xFF8A88A5),
                                              ),
                                            ),
                                            if (trx.isOverdue) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFFEE2E2),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'OVERDUE',
                                                  style: TextStyle(
                                                    fontSize: 9.5,
                                                    fontWeight:
                                                        FontWeight.w800,
                                                    color: Color(0xFFDC2626),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          trx.judulBuku,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF130F26),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          subtitleText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontStyle: FontStyle.italic,
                                            color: Color(0xFF7E7A92),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: trx.isOverdue
                                                    ? const Color(0xFFDC2626)
                                                    : _getStatusColor(trx.status),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                trx.isOverdue
                                                    ? '${_getStatusText(trx)} (Terlambat)'
                                                    : _getStatusText(trx),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: trx.isOverdue
                                                      ? const Color(0xFFDC2626)
                                                      : const Color(0xFF4A4960),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    CupertinoIcons.chevron_right,
                                    size: 18,
                                    color: Color(0xFF8A88A5),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
