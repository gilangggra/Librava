import '../../domain/models/book_model.dart';

class BookRepository {
  /// Mengembalikan koleksi awal (kosong secara default, data riil diambil dari API backend/database)
  List<BookModel> getInitialBooks() {
    return [];
  }
}
