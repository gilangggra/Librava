import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../network/api_constants.dart';

class BookCoverHelper {
  static const Map<String, String> _titleToAssetMap = {
    'clean code': 'assets/images/cover_clean_code.jpg',
    'pragmatic': 'assets/images/cover_pragmatic_programmer.jpg',
    'python': 'assets/images/cover_algoritma_python.jpg',
    'algoritma': 'assets/images/cover_algoritma_python.jpg',
    'filosofi teras': 'assets/images/cover_filosofi_teras.jpg',
    'filosofi': 'assets/images/cover_filosofi_teras.jpg',
    'basis data': 'assets/images/cover_sistem_basis_data.jpg',
    'database': 'assets/images/cover_sistem_basis_data.jpg',
    'atomic': 'assets/images/cover_atomic_habits.jpg',
    'habits': 'assets/images/cover_atomic_habits.jpg',
    'laskar': 'assets/images/cover_laskar_pelangi.jpg',
    'pelangi': 'assets/images/cover_laskar_pelangi.jpg',
    'jaringan': 'assets/images/cover_jaringan_komputer.jpg',
    'belajar html': 'assets/images/cover_belajar_html.jpg',
    'html': 'assets/images/cover_belajar_html.jpg',
    'everyday things': 'assets/images/cover_design_everyday_things.jpg',
    'design of everyday': 'assets/images/cover_design_everyday_things.jpg',
    'zero to one': 'assets/images/cover_zero_to_one.jpg',
    'bodo amat': 'assets/images/cover_bodo_amat.jpg',
    'thinking': 'assets/images/cover_thinking_fast_slow.jpg',
    'refactoring': 'assets/images/cover_refactoring.jpg',
    'introduction to algorithms':
        'assets/images/cover_introduction_to_algorithms.jpg',
    'sapiens': 'assets/images/cover_sapiens.jpg',
    'cosmos': 'assets/images/cover_cosmos.jpg',
    'bumi': 'assets/images/cover_bumi.jpg',
    'laut bercerita': 'assets/images/cover_laut_bercerita.jpg',
    'negeri 5 menara': 'assets/images/cover_negeri_5_menara.jpg',
    'one piece': 'assets/images/cover_one_piece_vol1.jpg',
    'midnight': 'assets/images/book_midnight_lib.jpg',
    'fruit fly': 'assets/images/book_fruit_fly.jpg',
    'adversary': 'assets/images/book_adversary.jpg',
  };

  /// Resolves the cover image path/URL for a given book.
  /// If [fotoBuku] maps to an existing bundled asset (e.g. `/uploads/cover_*.jpg`),
  /// it returns the local asset path directly for instant, offline-reliable loading.
  static String getCover({String? fotoBuku, required String judul}) {
    if (fotoBuku != null && fotoBuku.trim().isNotEmpty) {
      final trimmed = fotoBuku.trim();

      // If already an asset path
      if (trimmed.startsWith('assets/')) {
        return trimmed;
      }

      // If it refers to one of the default bundled covers
      final filename = trimmed.split('/').last.split(r'\').last;
      if (filename.startsWith('cover_') && filename.endsWith('.jpg')) {
        return 'assets/images/$filename';
      }

      // If it is a full network URL
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return trimmed;
      }

      // Server upload path (e.g. /uploads/user_custom_photo.jpg)
      final clean = trimmed.startsWith('/') ? trimmed : '/$trimmed';
      return '${ApiConstants.baseUrl.replaceAll('/api', '')}$clean';
    }

    // Match by title
    return getCoverForJudul(judul);
  }

  /// Maps a title to its specific matching local asset cover
  static String getCoverForJudul(String judul) {
    final lower = judul.toLowerCase().trim();
    for (final entry in _titleToAssetMap.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    return 'assets/images/book_the_unknown.jpg';
  }

  /// Helper to build the book cover Image widget with seamless fallback
  static Widget buildCoverImage(
    String pathOrUrl, {
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    String? fallbackJudul,
    BorderRadius? borderRadius,
  }) {
    final isNetwork =
        pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://');

    Widget fallback() {
      if (fallbackJudul != null && fallbackJudul.isNotEmpty) {
        final fallbackAsset = getCoverForJudul(fallbackJudul);
        return Image.asset(
          fallbackAsset,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) =>
              _defaultPlaceholder(width, height),
        );
      }
      return _defaultPlaceholder(width, height);
    }

    Widget imageWidget;
    if (isNetwork) {
      imageWidget = Image.network(
        pathOrUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => fallback(),
      );
    } else {
      imageWidget = Image.asset(
        pathOrUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => fallback(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: imageWidget,
      );
    }
    return imageWidget;
  }

  static Widget _defaultPlaceholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE7E3FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.book_rounded,
          color: AppColors.primary,
          size: 32,
        ),
      ),
    );
  }
}
