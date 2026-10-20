import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../network/api_constants.dart';

class AvatarHelper {
  static const Map<String, String> _nameToAssetMap = {
    'budi': 'assets/images/avatar_budi.jpg',
    'budi santoso': 'assets/images/avatar_budi.jpg',
    'citra': 'assets/images/avatar_citra.jpg',
    'citra lestari': 'assets/images/avatar_citra.jpg',
    'sari': 'assets/images/avatar_sari.jpg',
    'sari dewi': 'assets/images/avatar_sari.jpg',
    'andi': 'assets/images/avatar_andi.jpg',
    'andi pratama': 'assets/images/avatar_andi.jpg',
    'rina': 'assets/images/avatar_rina.jpg',
    'rina kartika': 'assets/images/avatar_rina.jpg',
    'admin': 'assets/images/avatar_admin.jpg',
    'librava admin': 'assets/images/avatar_admin.jpg',
  };

  /// Resolves the avatar path/URL for a given user.
  /// If [fotoProfil] matches a bundled avatar asset (e.g. `/uploads/avatar_*.jpg`),
  /// it maps directly to `assets/images/avatar_*.jpg` for instantaneous, offline-ready display.
  static String getAvatarUrl({String? fotoProfil, String? nama}) {
    if (fotoProfil != null && fotoProfil.trim().isNotEmpty) {
      final trimmed = fotoProfil.trim();

      if (trimmed.startsWith('assets/')) {
        return trimmed;
      }

      final filename = trimmed.split('/').last.split(r'\').last;
      if (filename.startsWith('avatar_') && (filename.endsWith('.jpg') || filename.endsWith('.png'))) {
        return 'assets/images/$filename';
      }

      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return trimmed;
      }

      final cleanPath = trimmed.replaceFirst(RegExp(r'^/+'), '');
      return '${ApiConstants.baseUrl.replaceAll('/api', '')}/$cleanPath';
    }

    if (nama != null && nama.trim().isNotEmpty) {
      final lower = nama.trim().toLowerCase();
      for (final entry in _nameToAssetMap.entries) {
        if (lower.contains(entry.key)) {
          return entry.value;
        }
      }
    }

    return '';
  }

  /// Builds an Avatar widget (circular) with smooth image rendering and robust fallbacks.
  static Widget buildAvatarWidget({
    String? fotoProfil,
    String? nama,
    double radius = 42,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
  }) {
    final avatarUrl = getAvatarUrl(fotoProfil: fotoProfil, nama: nama);
    final diameter = radius * 2;

    Widget fallbackIcon = Center(
      child: Text(
        nama != null && nama.trim().isNotEmpty
            ? nama.trim()[0].toUpperCase()
            : 'U',
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );

    Widget imageContent;

    if (avatarUrl.isEmpty) {
      imageContent = fallbackIcon;
    } else if (avatarUrl.startsWith('assets/')) {
      imageContent = Image.asset(
        avatarUrl,
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallbackIcon,
      );
    } else {
      imageContent = Image.network(
        avatarUrl,
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // If network fails, try matching name to local asset
          if (nama != null && nama.trim().isNotEmpty) {
            final lower = nama.trim().toLowerCase();
            for (final entry in _nameToAssetMap.entries) {
              if (lower.contains(entry.key)) {
                return Image.asset(
                  entry.value,
                  width: diameter,
                  height: diameter,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => fallbackIcon,
                );
              }
            }
          }
          return fallbackIcon;
        },
      );
    }

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF0EFFE),
        border: border,
        boxShadow: boxShadow,
      ),
      child: ClipOval(child: imageContent),
    );
  }
}
