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
  int _selectedTab = 0;

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

    await Future.wait([
      adminProvider.fetchBuku(token),
      adminProvider.fetchBukuPending(token),
    ]);
  }

  Future<void> _bukaDetail(AdminBookModel buku) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminBookDetailPage(buku: buku),
      ),
    );
    if (mounted) {
      _muatData();
    }
  }

  Color _warnaStatus(String status) {
    final s = status.trim().toLowerCase();
    if (s == 'tersedia' || s == 'available') {
      return const Color(0xFF22C55E);
    } else if (s == 'dipinjam' || s == 'borrowed') {
      return const Color(0xFFF59E0B);
    } else if (s == 'dibarter' || s == 'bartered') {
      return const Color(0xFF8B5CF6);
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
    Color warna;
    String teksStatus = buku.statusTampil;
    if (buku.isPending) {
      warna = const Color(0xFFF59E0B);
      teksStatus = 'Pending Verification';
    } else if (buku.isDitolak) {
      warna = const Color(0xFFDC2626);
      teksStatus = 'Rejected';
    } else {
      warna = _warnaStatus(buku.status);
    }

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: warna,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          teksStatus,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF7E7A92),
            fontWeight: FontWeight.w500,
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

  Widget _buildTabs(AdminProvider adminProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFEBE8F8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedTab = 0);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        _selectedTab == 0 ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _selectedTab == 0
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'All Books (${adminProvider.jumlahBuku})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _selectedTab == 0
                            ? AppColors.primary
                            : const Color(0xFF7E7A92),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedTab = 1);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        _selectedTab == 1 ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _selectedTab == 1
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Antrean Pending',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _selectedTab == 1
                              ? const Color(0xFFD97706)
                              : const Color(0xFF7E7A92),
                        ),
                      ),
                      if (adminProvider.jumlahBukuPending > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${adminProvider.jumlahBukuPending}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIsiDaftar(AdminProvider adminProvider) {
    final sedangLoading = _selectedTab == 0
        ? (adminProvider.isLoadingBuku && adminProvider.jumlahBuku == 0)
        : (adminProvider.isLoadingBukuPending &&
            adminProvider.jumlahBukuPending == 0);

    if (sedangLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final error = _selectedTab == 0
        ? adminProvider.errorBuku
        : adminProvider.errorBukuPending;
    final jumlah = _selectedTab == 0
        ? adminProvider.jumlahBuku
        : adminProvider.jumlahBukuPending;

    if (error != null && jumlah == 0) {
      return _buildPesanTengah(
        icon: CupertinoIcons.wifi_exclamationmark,
        judul: 'Failed to load book data',
        subjudul: error,
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
            'Try again',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    List<AdminBookModel> daftar;
    if (_selectedTab == 0) {
      daftar = adminProvider.daftarBukuTampil;
    } else {
      final kata = adminProvider.kataKunciBuku.trim().toLowerCase();
      daftar = kata.isEmpty
          ? adminProvider.daftarBukuPending
          : adminProvider.daftarBukuPending.where((buku) {
              return buku.judul.toLowerCase().contains(kata) ||
                  buku.penulis.toLowerCase().contains(kata) ||
                  buku.kategori.toLowerCase().contains(kata);
            }).toList();
    }

    if (daftar.isEmpty) {
      final sedangMencari = adminProvider.kataKunciBuku.trim().isNotEmpty;
      return _buildPesanTengah(
        icon: CupertinoIcons.book,
        judul: sedangMencari
            ? 'Book not found'
            : (_selectedTab == 0
                ? 'No books in the catalog'
                : 'No books awaiting verification'),
        subjudul: sedangMencari
            ? 'Try searching with another keyword such as title, author, or genre.'
            : (_selectedTab == 1
                ? 'All student book submissions have been curated.'
                : null),
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
            const SizedBox(height: 14),
            _buildTabs(adminProvider),
            const SizedBox(height: 14),
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
