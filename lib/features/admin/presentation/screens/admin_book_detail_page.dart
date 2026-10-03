import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/admin_book_model.dart';
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 1),
    );
  }
}
