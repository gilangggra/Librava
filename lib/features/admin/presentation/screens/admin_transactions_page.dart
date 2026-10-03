import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/admin_transaction_model.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_bottom_nav.dart';
import 'admin_transaction_detail_page.dart';

class AdminTransactionsPage extends StatefulWidget {
  const AdminTransactionsPage({super.key});

  @override
  State<AdminTransactionsPage> createState() => _AdminTransactionsPageState();
}

class _AdminTransactionsPageState extends State<AdminTransactionsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = context.read<AdminProvider>();
      _searchController.text = adminProvider.kataKunciTransaksi;
      _muatData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _muatData() async {
    final adminProvider = context.read<AdminProvider>();
    final token = context.read<AuthProvider>().token;

    if (token != null && token.isNotEmpty) {
      await adminProvider.fetchTransaksi(token);
    } else if (adminProvider.jumlahTransaksi == 0) {
      adminProvider.tandaiSesiTransaksiTidakValid();
    }
  }

  void _bukaDetail(AdminTransactionModel transaksi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminTransactionDetailPage(transaksi: transaksi),
      ),
    );
  }

  Color _warnaStatus(String statusTampil) {
    if (statusTampil == 'Completed') return const Color(0xFF22C55E);
    if (statusTampil == 'Accepted' || statusTampil == 'In Progress') return AppColors.primary;
    if (statusTampil == 'Rejected' || statusTampil == 'Cancelled') return const Color(0xFFEF4444);
    return const Color(0xFFF59E0B);
  }

  Widget _buildChipTipe(String tipe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEAFE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tipe,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildChipStatus(String statusTampil) {
    final warna = _warnaStatus(statusTampil);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusTampil,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: warna,
        ),
      ),
    );
  }

  Widget _buildCoverKecil() {
    return Container(
      width: 64,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFE7E3FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.book_rounded,
        color: AppColors.primary,
        size: 28,
      ),
    );
  }

  Widget _buildAvatarKecil(String inisial) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFFF0EFF9),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          inisial,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF7E7A92),
          ),
        ),
      ),
    );
  }

  Widget _buildKartuTransaksi(AdminTransactionModel tx) {
    final statusTampil = tx.statusTampil;
    final inisial = tx.requesterNama.isNotEmpty
        ? tx.requesterNama[0].toUpperCase()
        : '?';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _bukaDetail(tx),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCoverKecil(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                tx.bookJudul.isEmpty ? '-' : tx.bookJudul,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF130F26),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildChipStatus(statusTampil),
                          ],
                        ),
                        Text(
                          tx.requesterNama.isEmpty ? '-' : tx.requesterNama,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF7E7A92),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildChipTipe(tx.tipeTampil),
                            const SizedBox(width: 8),
                            _buildAvatarKecil(inisial),
                            const SizedBox(width: 6),
                            Text(
                              tx.requesterNama.split(' ').first,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7E7A92),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _bukaDetail(tx),
                    icon: const Icon(
                      CupertinoIcons.chevron_right,
                      size: 22,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKotakSearch(AdminProvider adminProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1A34).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: adminProvider.cariTransaksi,
        style: const TextStyle(fontSize: 15, color: Color(0xFF130F26)),
        decoration: const InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: Color(0xFFB4B2C5), fontSize: 15),
          prefixIcon: Icon(
            CupertinoIcons.search,
            color: Color(0xFFB4B2C5),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPesanTengah({
    required IconData icon,
    required String judul,
    String? subjudul,
    Widget? tombol,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const SizedBox(height: 80),
        Icon(icon, size: 56, color: const Color(0xFFB4B2C5)),
        const SizedBox(height: 14),
        Text(
          judul,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF130F26),
          ),
        ),
        if (subjudul != null) ...[
          const SizedBox(height: 6),
          Text(
            subjudul,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF7E7A92)),
          ),
        ],
        if (tombol != null) ...[
          const SizedBox(height: 18),
          Center(child: tombol),
        ],
      ],
    );
  }

  Widget _buildIsiDaftar(AdminProvider adminProvider) {
    if (adminProvider.isLoadingTransaksi && adminProvider.jumlahTransaksi == 0) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (adminProvider.errorTransaksi != null && adminProvider.jumlahTransaksi == 0) {
      return _buildPesanTengah(
        icon: CupertinoIcons.wifi_exclamationmark,
        judul: 'Data transaksi gagal dimuat',
        subjudul: adminProvider.errorTransaksi,
        tombol: ElevatedButton(
          onPressed: _muatData,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Coba lagi',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    final daftar = adminProvider.daftarTransaksiTampil;

    if (daftar.isEmpty) {
      final sedangMencari = adminProvider.kataKunciTransaksi.trim().isNotEmpty;
      return _buildPesanTengah(
        icon: CupertinoIcons.arrow_right_arrow_left,
        judul: sedangMencari ? 'Transaksi tidak ditemukan' : 'Belum ada transaksi',
        subjudul: sedangMencari
            ? 'Coba kata kunci lain seperti judul buku atau nama pengguna.'
            : null,
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: daftar.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildKartuTransaksi(daftar[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text(
                'Transaction data',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF130F26),
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildKotakSearch(adminProvider),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _muatData,
                child: _buildIsiDaftar(adminProvider),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 3),
    );
  }
}
