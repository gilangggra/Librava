import 'package:flutter/material.dart';
import '../../../../core/utils/book_cover_helper.dart';
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

  @override
  Widget build(BuildContext context) {
    final coverPath = BookCoverHelper.getCover(
      fotoBuku: buku.fotoBuku,
      judul: buku.judul,
    );
    return BookCoverHelper.buildCoverImage(
      coverPath,
      width: lebar,
      height: tinggi,
      fallbackJudul: buku.judul,
      borderRadius: BorderRadius.circular(radius),
    );
  }
}
