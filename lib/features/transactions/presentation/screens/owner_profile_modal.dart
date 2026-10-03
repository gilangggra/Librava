import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../chat/presentation/screens/chat_room_page.dart';

/// Modal dialog yang menampilkan profil pemilik buku sebenarnya (Owner Profile),
/// bukan profil pengguna yang sedang login.
class OwnerProfileModalContent extends StatelessWidget {
  final String ownerName;
  final String ownerUsername;
  final String? bookTitle;
  final String? bookAuthor;
  final String? transactionId;
  final VoidCallback onClose;
  final VoidCallback? onMessagePressed;

  const OwnerProfileModalContent({
    super.key,
    required this.ownerName,
    required this.ownerUsername,
    this.bookTitle,
    this.bookAuthor,
    this.transactionId,
    required this.onClose,
    this.onMessagePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFEEFF),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Baris Atas: Label & Tombol Tutup
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Owner Profile',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    color: Colors.transparent,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 24,
                      color: Color(0xFF130F26),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Foto Profil & Indikator Status Online
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: const Color(0xFFE5E2F3),
                  child: const Icon(
                    CupertinoIcons.person_fill,
                    size: 46,
                    color: Color(0xFF130F26),
                  ),
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2FD677),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Nama & Username Pemilik
            Text(
              ownerName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF130F26),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              ownerUsername,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8A88A5),
              ),
            ),
            const SizedBox(height: 12),

            // Badges: Mahasiswa Telkom University & Verified
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildBadge(
                  icon: CupertinoIcons.checkmark_seal_fill,
                  label: 'Verified Student',
                  color: const Color(0xFF2FD677),
                ),
                _buildBadge(
                  icon: CupertinoIcons.building_2_fill,
                  label: 'Telkom University',
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Kartu Statistik Pemilik
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF130F26).withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(child: _buildStatItem('4.9 ★', 'Rating (42)')),
                  Container(
                    width: 1,
                    height: 28,
                    color: const Color(0xFFE8E6F2),
                  ),
                  Expanded(child: _buildStatItem('12', 'Shared Books')),
                  Container(
                    width: 1,
                    height: 28,
                    color: const Color(0xFFE8E6F2),
                  ),
                  Expanded(child: _buildStatItem('< 15m', 'Avg. Response')),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Kartu Info Buku yang Dipinjam
            if (bookTitle != null && bookTitle!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE4E1F4),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEEFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        CupertinoIcons.book_fill,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Book requested:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8A88A5),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bookTitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF130F26),
                            ),
                          ),
                          if (bookAuthor != null && bookAuthor!.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Text(
                              bookAuthor!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6E6B87),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Tombol Kirim Pesan & Tutup
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (onMessagePressed != null) {
                    onMessagePressed!();
                  } else {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatRoomPage(
                          userName: ownerName,
                          isOnline: true,
                          transactionId: transactionId,
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  CupertinoIcons.chat_bubble_text_fill,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  'Message $ownerName',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: TextButton(
                onPressed: onClose,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6E6B87),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF130F26),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8A88A5),
          ),
        ),
      ],
    );
  }
}
