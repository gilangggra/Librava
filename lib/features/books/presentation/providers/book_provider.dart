import 'package:flutter/foundation.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/services/book_filter_service.dart';
import '../../domain/models/book_model.dart';

class BookProvider extends ChangeNotifier {
  final BookFilterService _filterService;
  final BookRepository _repository;

  List<BookModel> _books = [];
  String _searchQuery = '';
  String _selectedKategori = 'Semua';
  bool _onlyAvailable = false;
  double? _minRating;

  BookProvider({
    BookFilterService? filterService,
    BookRepository? repository,
  })  : _filterService = filterService ?? BookFilterService(),
        _repository = repository ?? BookRepository() {
    _loadInitialBooks();
  }

  void _loadInitialBooks() {
    _books = _repository.getInitialBooks();
  }

  List<BookModel> get allBooks => List.unmodifiable(_books);
  String get searchQuery => _searchQuery;
  String get selectedKategori => _selectedKategori;
  bool get onlyAvailable => _onlyAvailable;
  double? get minRating => _minRating;

  List<String> get availableCategories {
    final kategoriSet = _books.map((b) => b.kategori).toSet().toList();
    kategoriSet.sort();
    return ['Semua', ...kategoriSet];
  }

  List<BookModel> get filteredBooks {
    return _filterService.cariDanFilter(
      _books,
      query: _searchQuery,
      kategori: _selectedKategori,
      hanyaYangTersedia: _onlyAvailable ? true : null,
      ratingMinimal: _minRating,
    );
  }

  int get totalFilteredCount => filteredBooks.length;

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void setKategori(String kategori) {
    if (_selectedKategori == kategori) return;
    _selectedKategori = kategori;
    notifyListeners();
  }

  void setOnlyAvailable(bool value) {
    if (_onlyAvailable == value) return;
    _onlyAvailable = value;
    notifyListeners();
  }

  void setMinRating(double? rating) {
    if (_minRating == rating) return;
    _minRating = rating;
    notifyListeners();
  }

  void resetFilter() {
    _searchQuery = '';
    _selectedKategori = 'Semua';
    _onlyAvailable = false;
    _minRating = null;
    notifyListeners();
  }

  void tambahBuku(BookModel buku) {
    _books.add(buku);
    notifyListeners();
  }
}
