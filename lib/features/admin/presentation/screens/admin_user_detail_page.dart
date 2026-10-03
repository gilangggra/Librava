import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/admin_user_model.dart';
import '../widgets/admin_bottom_nav.dart';

class AdminUserDetailPage extends StatelessWidget {
  final AdminUserModel user;

  const AdminUserDetailPage({super.key, required this.user});

  String _isiAtauStrip(String? teks) {
    if (teks == null || teks.trim().isEmpty) {
      return '-';
    }
    return teks;
  }

  String get _labelRole {
    return user.role == 'admin' ? 'Admin' : 'User';
  }

  Widget _buildAvatarKosong() {
    return Container(
      color: const Color(0xFFF2F2F2),
      child: const Align(
        alignment: Alignment.bottomCenter,
        child: Icon(
          CupertinoIcons.person_fill,
          size: 92,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 106,
      height: 106,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1A34).withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: user.punyaFotoOnline
            ? Image.network(
                user.fotoProfil!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildAvatarKosong(),
              )
            : _buildAvatarKosong(),
      ),
    );
  }

  Widget _buildBarisInfo(String label, String nilai) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE9E8EF), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF7E7A92),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              nilai,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF7E7A92),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKartuUser() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 10),
          Text(
            _labelRole,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF130F26),
            ),
          ),
          const SizedBox(height: 18),
          _buildBarisInfo('Name', _isiAtauStrip(user.nama)),
          _buildBarisInfo('Email', _isiAtauStrip(user.email)),
          _buildBarisInfo('NIM', _isiAtauStrip(user.nim)),
          _buildBarisInfo('University', _isiAtauStrip(user.universitas)),
          _buildBarisInfo('Joined', _isiAtauStrip(user.tanggalDaftar)),
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
                  'User view',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF130F26),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              _buildKartuUser(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 2),
    );
  }
}
