import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/admin_transaction_model.dart';
import '../widgets/admin_bottom_nav.dart';

class AdminTransactionDetailPage extends StatelessWidget {
  final AdminTransactionModel transaksi;

  const AdminTransactionDetailPage({super.key, required this.transaksi});

  String _isiAtauStrip(String? teks) {
    if (teks == null || teks.trim().isEmpty) return '-';
    return teks;
  }

  Color _warnaStatus(String statusTampil) {
    if (statusTampil == 'Completed') return const Color(0xFF22C55E);
    if (statusTampil == 'Accepted' || statusTampil == 'In Progress') return AppColors.primary;
    if (statusTampil == 'Rejected' || statusTampil == 'Cancelled') return const Color(0xFFEF4444);
    return const Color(0xFFF59E0B);
  }

  Widget _buildCoverBuku() {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFE7E3FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.book_rounded,
        color: AppColors.primary,
        size: 36,
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
        transaksi.tipeTampil,
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

  Widget _buildKartuRingkasan() {
    final statusTampil = transaksi.statusTampil;

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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaksi.bookJudul.isEmpty ? 'Judul tidak ada' : transaksi.bookJudul,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF130F26),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isiAtauStrip(transaksi.requesterNama),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7E7A92),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
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

  Widget _buildBarisInfo(String label, Widget nilaiWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF7E7A92),
              ),
            ),
          ),
          Expanded(child: nilaiWidget),
        ],
      ),
    );
  }

  Widget _buildTeksNilai(String teks, {Color? warna}) {
    return Text(
      teks,
      style: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        color: warna ?? const Color(0xFF130F26),
      ),
    );
  }

  Widget _buildKartuInfo() {
    final statusTampil = transaksi.statusTampil;
    final warnaStatus = _warnaStatus(statusTampil);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
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
          const SizedBox(height: 12),
          _buildBarisInfo(
            'Transaction ID',
            _buildTeksNilai(
              transaksi.id.startsWith('TRX-') ? transaksi.id : 'TRX-${transaksi.id}',
            ),
          ),
          _buildBarisInfo('Requester', _buildTeksNilai(_isiAtauStrip(transaksi.requesterNama))),
          _buildBarisInfo('Owner', _buildTeksNilai(_isiAtauStrip(transaksi.ownerNama))),
          _buildBarisInfo('Type', _buildTeksNilai(transaksi.tipeTampil)),
          _buildBarisInfo('Deposit', _buildTeksNilai(transaksi.depositFormatted)),
          _buildBarisInfo(
            'Meeting location',
            _buildTeksNilai(_isiAtauStrip(transaksi.lokasiPertemuan)),
          ),
          _buildBarisInfo(
            'Handover status',
            _buildTeksNilai(statusTampil, warna: warnaStatus),
          ),
          _buildBarisInfo(
            'Transaction status',
            _buildTeksNilai(statusTampil, warna: warnaStatus),
          ),
        ],
      ),
    );
  }

  Widget _buildTitikTimeline(bool aktif) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: aktif ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
        border: Border.all(
          color: aktif ? const Color(0xFF16A34A) : const Color(0xFFD97706),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildGarisTimeline(bool aktif) {
    return Container(
      width: 2,
      height: 22,
      color: aktif ? const Color(0xFF22C55E) : const Color(0xFFDDD9F0),
    );
  }

  Widget _buildItemTimeline(String label, String tanggal, bool aktif, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            _buildTitikTimeline(aktif),
            if (!isLast) _buildGarisTimeline(aktif),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF130F26),
                  ),
                ),
                Text(
                  tanggal,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF7E7A92),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _buatTimeline() {
    final tanggalDibuat = transaksi.tanggalDibuat;
    final statusSekarang = transaksi.status;

    final semuaLangkah = [
      {'label': 'Request sent', 'aktif': true},
      {
        'label': 'Accepted by owner',
        'aktif': ['DISETUJUI', 'DALAM_PROSES', 'SELESAI'].contains(statusSekarang),
      },
      {
        'label': 'Deposit completed',
        'aktif': ['DALAM_PROSES', 'SELESAI'].contains(statusSekarang),
      },
      {
        'label': 'Handover scheduled',
        'aktif': ['DALAM_PROSES', 'SELESAI'].contains(statusSekarang),
      },
      {
        'label': 'Book handover',
        'aktif': statusSekarang == 'SELESAI',
      },
      {
        'label': 'Completed',
        'aktif': statusSekarang == 'SELESAI',
      },
    ];

    return semuaLangkah
        .map((langkah) => {
              'label': langkah['label'],
              'tanggal': (langkah['aktif'] as bool) ? tanggalDibuat : '-',
              'aktif': langkah['aktif'],
            })
        .toList();
  }

  Widget _buildKartuTimeline() {
    final timeline = _buatTimeline();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timeline',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF130F26),
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(
            timeline.length,
            (i) => _buildItemTimeline(
              timeline[i]['label'] as String,
              timeline[i]['tanggal'] as String,
              timeline[i]['aktif'] as bool,
              i == timeline.length - 1,
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
              Row(
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
                    'Transaction view',
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
              _buildKartuRingkasan(),
              const SizedBox(height: 14),
              _buildKartuInfo(),
              const SizedBox(height: 14),
              _buildKartuTimeline(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 3),
    );
  }
}
