import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_constants.dart';
import '../../domain/models/admin_book_model.dart';

class AdminBookCover extends StatelessWidget {
  final AdminBookModel buku;
  final double lebar;
  final double tinggi;
  final double radius;

  const AdminBookCover({
    super.key,
    required this.buku,
    required this.lebar,
    required this.tinggi,
    this.radius = 10,
  });

  Widget _buildCoverKosong() {
    return Container(
      width: lebar,
      height: tinggi,
      color: const Color(0xFFE7E3FF),
      child: Icon(
        Icons.book_rounded,
        color: AppColors.primary,
        size: lebar * 0.45,
      ),
    );
  }

  Widget _buildGambar() {
    if (buku.punyaFotoOnline) {
      final foto = buku.fotoBuku!;
      final fullUrl = (foto.startsWith('http://') || foto.startsWith('https://'))
          ? foto
          : '${ApiConstants.baseUrl.replaceAll('/api', '')}${foto.startsWith('/') ? foto : '/$foto'}';
      return Image.network(
        fullUrl,
        width: lebar,
        height: tinggi,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildCoverKosong(),
      );
    }

    if (buku.punyaFotoAsset) {
      return Image.asset(
        buku.fotoBuku!,
        width: lebar,
        height: tinggi,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildCoverKosong(),
      );
    }

    return _buildCoverKosong();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: _buildGambar(),
    );
  }
}
