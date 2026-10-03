import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/admin_user_model.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_bottom_nav.dart';
import 'admin_user_detail_page.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = context.read<AdminProvider>();
      _searchController.text = adminProvider.kataKunci;
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
      await adminProvider.fetchMahasiswa(token);
    } else if (adminProvider.jumlahMahasiswa == 0) {
      adminProvider.tandaiSesiTidakValid();
    }
  }

  void _bukaDetail(AdminUserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminUserDetailPage(user: user),
      ),
    );
  }

  Widget _buildAvatar(AdminUserModel user, {double ukuran = 78}) {
    final avatarKosong = Container(
      width: ukuran,
      height: ukuran,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E2E2), width: 2),
      ),
      child: ClipOval(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Icon(
            CupertinoIcons.person_fill,
            size: ukuran * 0.85,
            color: Colors.black,
          ),
        ),
      ),
    );

    if (!user.punyaFotoOnline) {
      return avatarKosong;
    }

    return ClipOval(
      child: Image.network(
        user.fotoProfil!,
        width: ukuran,
        height: ukuran,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => avatarKosong,
      ),
    );
  }

  Widget _buildBarisInfo(IconData icon, String teks) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF7E7A92)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            teks,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF7E7A92),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKartuUser(AdminUserModel user) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _bukaDetail(user),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildAvatar(user),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF130F26),
                      ),
                    ),
                    Text(
                      user.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF7E7A92),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildBarisInfo(CupertinoIcons.mail, user.email),
                    const SizedBox(height: 4),
                    _buildBarisInfo(
                      CupertinoIcons.number,
                      user.punyaNim ? 'NIM ${user.nim}' : 'NIM belum diisi',
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _bukaDetail(user),
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
        onChanged: adminProvider.cariMahasiswa,
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
    if (adminProvider.isLoadingMahasiswa && adminProvider.jumlahMahasiswa == 0) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (adminProvider.errorMahasiswa != null &&
        adminProvider.jumlahMahasiswa == 0) {
      return _buildPesanTengah(
        icon: CupertinoIcons.wifi_exclamationmark,
        judul: 'Data mahasiswa gagal dimuat',
        subjudul: adminProvider.errorMahasiswa,
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

    final daftar = adminProvider.daftarMahasiswaTampil;

    if (daftar.isEmpty) {
      final sedangMencari = adminProvider.kataKunci.trim().isNotEmpty;
      return _buildPesanTengah(
        icon: CupertinoIcons.person_2,
        judul: sedangMencari
            ? 'Mahasiswa tidak ditemukan'
            : 'Belum ada mahasiswa terdaftar',
        subjudul: sedangMencari
            ? 'Coba kata kunci lain seperti nama, email, atau NIM.'
            : null,
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: daftar.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildKartuUser(daftar[index]),
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
                'User data',
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
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 2),
    );
  }
}
