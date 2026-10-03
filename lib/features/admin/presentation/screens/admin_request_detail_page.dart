import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/admin_transaction_model.dart';
import '../widgets/admin_bottom_nav.dart';

class AdminRequestDetailPage extends StatelessWidget {
  final AdminTransactionModel request;

  const AdminRequestDetailPage({super.key, required this.request});

  String _isiAtauStrip(String? teks) {
    if (teks == null || teks.trim().isEmpty) return '-';
    return teks;
  }

  String _formatTanggalWaktu(String isoString) {
    if (isoString.isEmpty) return '-';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final bulan = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][dt.month - 1];
      final jam = dt.hour.toString().padLeft(2, '0');
      final menit = dt.minute.toString().padLeft(2, '0');
      return '$bulan ${dt.day}, ${dt.year}, $jam:$menit';
    } catch (_) {
      return isoString.split('T').first;
    }
  }

  Color _warnaStatus(String statusTampil) {
    if (statusTampil == 'Accepted') return const Color(0xFF22C55E);
    if (statusTampil == 'Rejected') return const Color(0xFFEF4444);
    return const Color(0xFFF59E0B);
  }

  Widget _buildCoverBuku() {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFE7E3FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.book_rounded,
        color: AppColors.primary,
        size: 42,
      ),
    );
  }

  Widget _buildChipTipe() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEAFE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        request.tipeTampil,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildChipStatus(String statusTampil) {
    final warna = _warnaStatus(statusTampil);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusTampil,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: warna,
        ),
      ),
    );
  }

  Widget _buildKartuBuku(String statusTampil) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCoverBuku(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.bookJudul.isEmpty ? '-' : request.bookJudul,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF130F26),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isiAtauStrip(request.requesterNama),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7E7A92),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChipTipe(),
                    _buildChipStatus(statusTampil),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarisInfo(String label, String nilai, {Color? warnaHuruf}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF7E7A92),
              ),
            ),
          ),
          Expanded(
            child: Text(
              nilai,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: warnaHuruf ?? const Color(0xFF130F26),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKartuInfo(String statusTampil) {
    final warnaStatus = _warnaStatus(statusTampil);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction Information',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF130F26),
            ),
          ),
          const SizedBox(height: 14),
          _buildBarisInfo(
            'Request ID',
            request.id.startsWith('RQX-') || request.id.startsWith('REQ-')
                ? request.id
                : 'RQX-${request.id}',
          ),
          _buildBarisInfo('Requester', _isiAtauStrip(request.requesterNama)),
          _buildBarisInfo('Owner', _isiAtauStrip(request.ownerNama)),
          _buildBarisInfo(
            'Requested date',
            _formatTanggalWaktu(request.createdAt),
          ),
          _buildBarisInfo(
            'Status',
            statusTampil,
            warnaHuruf: warnaStatus,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusTampil = request.statusTampil;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      CupertinoIcons.chevron_left,
                      color: Color(0xFF130F26),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Request view',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF130F26),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildKartuBuku(statusTampil),
              const SizedBox(height: 14),
              _buildKartuInfo(statusTampil),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 4),
    );
  }
}
