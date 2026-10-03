import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/admin_book_model.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_book_cover.dart';
import '../widgets/admin_bottom_nav.dart';
import 'admin_book_detail_page.dart';

class AdminBooksPage extends StatefulWidget {
  const AdminBooksPage({super.key});

  @override
  State<AdminBooksPage> createState() => _AdminBooksPageState();
}

class _AdminBooksPageState extends State<AdminBooksPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = context.read<AdminProvider>();
      _searchController.text = adminProvider.kataKunciBuku;
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
      await adminProvider.fetchBuku(token);
    } else if (adminProvider.jumlahBuku == 0) {
      adminProvider.tandaiSesiBukuTidakValid();
    }
  }

  void _bukaDetail(AdminBookModel buku) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminBookDetailPage(buku: buku),
      ),
    );
  }

  Color _warnaStatus(String status) {
    if (status == 'Tersedia') {
      return const Color(0xFF22C55E);
    } else if (status == 'Dipinjam') {
      return const Color(0xFFF59E0B);
    }
    return AppColors.primary;
  }

  Widget _buildChipGenre(String genre) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEAFE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        genre,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildBarisStatus(AdminBookModel buku) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _warnaStatus(buku.status),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          buku.statusTampil,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF7E7A92),
          ),
        ),
      ],
    );
  }

  Widget _buildKartuBuku(AdminBookModel buku) {
    final daftarGenre = buku.daftarGenre;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _bukaDetail(buku),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              AdminBookCover(buku: buku, lebar: 68, tinggi: 84),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      buku.judul,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF130F26),
                      ),
                    ),
                    Text(
                      buku.penulis,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF7E7A92),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildBarisStatus(buku),
                    if (daftarGenre.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: daftarGenre.map(_buildChipGenre).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _bukaDetail(buku),
                icon: const Icon(
                  CupertinoIcons.chevron_right,
                  size: 22,
                  color: AppColors.primary,
                ),
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
        onChanged: adminProvider.cariBuku,
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
    if (adminProvider.isLoadingBuku && adminProvider.jumlahBuku == 0) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (adminProvider.errorBuku != null && adminProvider.jumlahBuku == 0) {
      return _buildPesanTengah(
        icon: CupertinoIcons.wifi_exclamationmark,
        judul: 'Data buku gagal dimuat',
        subjudul: adminProvider.errorBuku,
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

    final daftar = adminProvider.daftarBukuTampil;

    if (daftar.isEmpty) {
      final sedangMencari = adminProvider.kataKunciBuku.trim().isNotEmpty;
      return _buildPesanTengah(
        icon: CupertinoIcons.book,
        judul: sedangMencari ? 'Buku tidak ditemukan' : 'Belum ada buku',
        subjudul: sedangMencari
            ? 'Coba kata kunci lain seperti judul, penulis, atau genre.'
            : null,
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: daftar.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildKartuBuku(daftar[index]),
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
                'Book data',
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
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 1),
    );
  }
}
