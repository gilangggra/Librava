import 'package:flutter/foundation.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/services/book_api_service.dart';
import '../../data/services/book_filter_service.dart';
import '../../domain/models/book_model.dart';

class BookProvider extends ChangeNotifier {
  final BookFilterService _filterService;
  final BookRepository _repository;
  final BookApiService _apiService;

  List<BookModel> _books = [];
  List<BookModel> _myBooks = [];
  String _searchQuery = '';
  String _selectedKategori = 'Semua';
  bool _onlyAvailable = false;
  double? _minRating;
  bool _isLoading = false;
  String? _errorMessage;

  BookProvider({
    BookFilterService? filterService,
    BookRepository? repository,
    BookApiService? apiService,
  })  : _filterService = filterService ?? BookFilterService(),
        _repository = repository ?? BookRepository(),
        _apiService = apiService ?? BookApiService() {
    _loadInitialBooks();
  }

  void _loadInitialBooks() {
    _books = _repository.getInitialBooks();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<BookModel> get allBooks => List.unmodifiable(_books);
  List<BookModel> get koleksiSaya => List.unmodifiable(
        _myBooks.isNotEmpty ? _myBooks : _books.take(3).toList(),
      );
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

  Future<void> fetchBooksFromApi({
    String? search,
    String? kategori,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.getBooks(
        search: search,
        kategori: kategori == 'Semua' ? null : kategori,
        limit: 100,
      );
      _books = result.books;
    } catch (_) {
      _books = _repository.getInitialBooks();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyBooks(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.getMyBooks(token);
      _myBooks = result.books;
    } catch (_) {
      if (_myBooks.isEmpty && _books.isNotEmpty) {
        _myBooks = _books.take(3).toList();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

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
    _myBooks.insert(0, buku);
    notifyListeners();
  }

  Future<BookModel?> tambahBukuApi({
    required String token,
    required String judul,
    required String penulis,
    String? penerbit,
    String? isbn,
    String? deskripsi,
    String? kategori,
    String? fotoBuku,
  }) async {
    try {
      final book = await _apiService.createBook(
        token: token,
        judul: judul,
        penulis: penulis,
        penerbit: penerbit,
        isbn: isbn,
        deskripsi: deskripsi,
        kategori: kategori,
        fotoBuku: fotoBuku,
      );
      _books.insert(0, book);
      _myBooks.insert(0, book);
      notifyListeners();
      return book;
    } catch (_) {
      final fallbackBook = BookModel(
        id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
        judul: judul,
        penulis: penulis,
        kategori: kategori ?? 'Umum',
        tahunTerbit: 0,
        deskripsi: deskripsi ?? '',
        fotoBuku: fotoBuku,
      );
      _books.insert(0, fallbackBook);
      _myBooks.insert(0, fallbackBook);
      notifyListeners();
      return fallbackBook;
    }
  }
}
