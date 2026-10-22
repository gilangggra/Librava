import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/admin_book_model.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_book_cover.dart';
import '../widgets/admin_bottom_nav.dart';

class AdminBookDetailPage extends StatelessWidget {
  final AdminBookModel buku;

  const AdminBookDetailPage({super.key, required this.buku});

  String _isiAtauStrip(String teks) {
    return teks.trim().isEmpty ? '-' : teks;
  }

  Widget _buildBarisInfo(String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7E7A92),
              ),
            ),
          ),
          Expanded(
            child: Text(
              nilai,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7E7A92),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKotakInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _buildBarisInfo('Author', _isiAtauStrip(buku.penulis)),
          _buildBarisInfo('Genre', buku.genreTampil),
          _buildBarisInfo('Status', buku.statusTampil),
          _buildBarisInfo('Publisher', _isiAtauStrip(buku.penerbit)),
          _buildBarisInfo('Owner', _isiAtauStrip(buku.pemilikNama)),
          _buildBarisInfo('Moderation', buku.statusModerasi),
          if (buku.catatanModerasi != null &&
              buku.catatanModerasi!.trim().isNotEmpty)
            _buildBarisInfo('Catatan', buku.catatanModerasi!),
        ],
      ),
    );
  }

  Widget _buildKartuBuku() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 85),
          padding: const EdgeInsets.fromLTRB(28, 105, 28, 26),
          decoration: BoxDecoration(
            color: const Color(0xFFE6E3FB),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Text(
                buku.judul,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF130F26),
                ),
              ),
              const SizedBox(height: 14),
              _buildKotakInfo(),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E1A34).withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AdminBookCover(
            buku: buku,
            lebar: 144,
            tinggi: 178,
            radius: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildTentangBuku() {
    final adaDeskripsi = buku.deskripsi.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About this book',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF130F26),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            adaDeskripsi ? buku.deskripsi : 'Belum ada deskripsi untuk buku ini.',
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF9A97AD),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModerasiActions(BuildContext context) {
    // 1. Jika Buku SUDAH DISETUJUI -> Tampilkan banner disetujui (tanpa tombol setujui)
    if (buku.isDisetujui) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FADF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF6CE9A6), width: 1.2),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF027A48),
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buku Telah Disetujui (Approved)',
                          style: TextStyle(
                            color: Color(0xFF027A48),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Buku ini telah lolos kurasi dan aktif di katalog publik.',
                          style: TextStyle(
                            color: Color(0xFF027A48),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text(
                  'Tolak / Batalkan Persetujuan',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () => _dialogTolak(context),
              ),
            ),
          ],
        ),
      );
    }

    // 2. Jika Buku DITOLAK -> Tampilkan banner ditolak & opsi setujui kembali
    if (buku.isDitolak) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFCA5A5), width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cancel_rounded,
                    color: Color(0xFFDC2626),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Buku Ditolak (Rejected)',
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          buku.catatanModerasi != null &&
                                  buku.catatanModerasi!.trim().isNotEmpty
                              ? 'Alasan: ${buku.catatanModerasi}'
                              : 'Buku ini ditolak dan tidak ditampilkan pada katalog umum.',
                          style: const TextStyle(
                            color: Color(0xFF991B1B),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text(
                  'Setujui Buku untuk Katalog',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: () => _prosesModerasi(context, 'APPROVE'),
              ),
            ),
          ],
        ),
      );
    }

    // 3. Jika Buku MASIH PENDING -> Tampilkan tombol Setujui dan Tolak side-by-side
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aksi Kurasi Admin',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF130F26),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline,
                      color: Colors.white, size: 20),
                  label: const Text(
                    'Setujui',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () => _prosesModerasi(context, 'APPROVE'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.cancel_outlined,
                      color: Colors.white, size: 20),
                  label: const Text(
                    'Tolak',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () => _dialogTolak(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _dialogTolak(BuildContext context) {
    final catatanController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text(
            'Tolak Buku',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Berikan alasan mengapa buku ini ditolak agar pemilik dapat memperbaikinya:',
                style: TextStyle(fontSize: 13, color: Color(0xFF555268)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: catatanController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Contoh: Foto sampul buram, deskripsi kurang lengkap.',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFA09DB2)),
                  filled: true,
                  fillColor: const Color(0xFFF3F2F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Color(0xFF7E7A92))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final catatan = catatanController.text.trim();
                Navigator.pop(ctx);
                _prosesModerasi(context, 'REJECT', catatan);
              },
              child: const Text('Tolak Buku',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _prosesModerasi(BuildContext context, String action,
      [String? catatan]) async {
    final auth = context.read<AuthProvider>();
    try {
      await context.read<AdminProvider>().moderateBook(
            token: auth.token,
            bookId: buku.id,
            action: action,
            catatan: catatan,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == 'APPROVE'
                  ? 'Buku "${buku.judul}" berhasil disetujui untuk katalog!'
                  : 'Buku "${buku.judul}" berhasil ditolak.',
            ),
            backgroundColor: action == 'APPROVE'
                ? const Color(0xFF16A34A)
                : const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui moderasi: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  CupertinoIcons.chevron_left,
                  color: Color(0xFF130F26),
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Book view',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF130F26),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _buildKartuBuku(),
              const SizedBox(height: 22),
              _buildTentangBuku(),
              const SizedBox(height: 22),
              _buildModerasiActions(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 1),
    );
  }
}
