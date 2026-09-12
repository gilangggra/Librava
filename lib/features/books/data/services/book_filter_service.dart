import '../../domain/models/book_model.dart';

class BookFilterService {
  List<BookModel> cariBuku(List<BookModel> books, String query) {
    final kataKunci = query.trim().toLowerCase();
    if (kataKunci.isEmpty) return books;

    return books.where((book) {
      final cocokJudul = book.judul.toLowerCase().contains(kataKunci);
      final cocokPenulis = book.penulis.toLowerCase().contains(kataKunci);
      return cocokJudul || cocokPenulis;
    }).toList();
  }

  List<BookModel> filterBuku(
    List<BookModel> books, {
    String? kategori,
    bool? hanyaYangTersedia,
    int? tahunMinimal,
    double? ratingMinimal,
  }) {
    return books.where((book) {
      if (kategori != null &&
          kategori.trim().isNotEmpty &&
          kategori.toLowerCase() != 'semua' &&
          book.kategori.toLowerCase() != kategori.toLowerCase()) {
        return false;
      }

      if (hanyaYangTersedia == true && !book.tersedia) {
        return false;
      }

      if (tahunMinimal != null && book.tahunTerbit < tahunMinimal) {
        return false;
      }

      if (ratingMinimal != null && book.rating < ratingMinimal) {
        return false;
      }

      return true;
    }).toList();
  }

  List<BookModel> cariDanFilter(
    List<BookModel> books, {
    String query = '',
    String? kategori,
    bool? hanyaYangTersedia,
    int? tahunMinimal,
    double? ratingMinimal,
  }) {
    final hasilCari = cariBuku(books, query);

    return filterBuku(
      hasilCari,
      kategori: kategori,
      hanyaYangTersedia: hanyaYangTersedia,
      tahunMinimal: tahunMinimal,
      ratingMinimal: ratingMinimal,
    );
  }
}
