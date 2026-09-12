import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/auth/domain/models/user_model.dart';
import 'package:librava/features/books/data/services/book_filter_service.dart';
import 'package:librava/features/books/domain/models/book_model.dart';
import 'package:librava/features/books/presentation/providers/book_provider.dart';

void main() {
  group('BookFilterService Unit Tests', () {
    late BookFilterService filterService;
    late List<BookModel> dummyBooks;

    setUp(() {
      filterService = BookFilterService();
      dummyBooks = const [
        BookModel(
          id: '1',
          judul: 'Clean Code',
          penulis: 'Robert C. Martin',
          kategori: 'Teknologi',
          tahunTerbit: 2008,
          tersedia: true,
          rating: 4.8,
        ),
        BookModel(
          id: '2',
          judul: 'Flutter Apprentice',
          penulis: 'Ray Wenderlich',
          kategori: 'Teknologi',
          tahunTerbit: 2021,
          tersedia: true,
          rating: 4.6,
        ),
        BookModel(
          id: '3',
          judul: 'Design Patterns',
          penulis: 'Gang of Four',
          kategori: 'Teknologi',
          tahunTerbit: 1994,
          tersedia: false,
          rating: 4.9,
        ),
        BookModel(
          id: '4',
          judul: 'Don\'t Make Me Think',
          penulis: 'Steve Krug',
          kategori: 'Desain',
          tahunTerbit: 2014,
          tersedia: true,
          rating: 4.5,
        ),
        BookModel(
          id: '5',
          judul: 'The Lean Startup',
          penulis: 'Eric Ries',
          kategori: 'Bisnis',
          tahunTerbit: 2011,
          tersedia: false,
          rating: 4.4,
        ),
      ];
    });

    test('cariBuku harus mengembalikan seluruh buku jika query kosong atau hanya spasi', () {
      final hasilKosong = filterService.cariBuku(dummyBooks, '');
      final hasilSpasi = filterService.cariBuku(dummyBooks, '   ');

      expect(hasilKosong.length, 5);
      expect(hasilSpasi.length, 5);
    });

    test('cariBuku berhasil mencari berdasarkan judul (case-insensitive & substring)', () {
      final hasil = filterService.cariBuku(dummyBooks, 'clean');
      expect(hasil.length, 1);
      expect(hasil.first.judul, 'Clean Code');

      final hasilUppercase = filterService.cariBuku(dummyBooks, 'FLUTTER');
      expect(hasilUppercase.length, 1);
      expect(hasilUppercase.first.judul, 'Flutter Apprentice');
    });

    test('cariBuku berhasil mencari berdasarkan nama penulis', () {
      final hasil = filterService.cariBuku(dummyBooks, 'martin');
      expect(hasil.length, 1);
      expect(hasil.first.penulis, 'Robert C. Martin');
    });

    test('cariBuku mengembalikan list kosong jika tidak ada yang cocok', () {
      final hasil = filterService.cariBuku(dummyBooks, 'Buku Tidak Ada 123');
      expect(hasil.isEmpty, true);
    });

    test('filterBuku berdasarkan kategori tertentu', () {
      final hasilTeknologi = filterService.filterBuku(dummyBooks, kategori: 'Teknologi');
      expect(hasilTeknologi.length, 3);
      expect(hasilTeknologi.every((b) => b.kategori == 'Teknologi'), true);

      final hasilDesain = filterService.filterBuku(dummyBooks, kategori: 'Desain');
      expect(hasilDesain.length, 1);
      expect(hasilDesain.first.judul, 'Don\'t Make Me Think');

      final hasilSemua = filterService.filterBuku(dummyBooks, kategori: 'Semua');
      expect(hasilSemua.length, 5);
    });

    test('filterBuku hanya yang berstatus tersedia', () {
      final hasilTersedia = filterService.filterBuku(dummyBooks, hanyaYangTersedia: true);
      expect(hasilTersedia.length, 3);
      expect(hasilTersedia.every((b) => b.tersedia == true), true);
    });

    test('filterBuku berdasarkan rating minimal', () {
      final hasilRatingTinggi = filterService.filterBuku(dummyBooks, ratingMinimal: 4.8);
      expect(hasilRatingTinggi.length, 2);
      expect(hasilRatingTinggi.map((b) => b.id), containsAll(['1', '3']));
    });

    test('filterBuku berdasarkan tahun minimal', () {
      final hasilTahunBaru = filterService.filterBuku(dummyBooks, tahunMinimal: 2015);
      expect(hasilTahunBaru.length, 1);
      expect(hasilTahunBaru.first.judul, 'Flutter Apprentice');
    });

    test('cariDanFilter menggabungkan pencarian teks dan filter kategori & ketersediaan', () {
      final hasil = filterService.cariDanFilter(
        dummyBooks,
        query: 'code',
        kategori: 'Teknologi',
        hanyaYangTersedia: true,
      );

      expect(hasil.length, 1);
      expect(hasil.first.judul, 'Clean Code');
    });
  });

  group('BookProvider State Management Unit Tests', () {
    late BookProvider provider;

    setUp(() {
      provider = BookProvider();
    });

    test('Inisialisasi awal provider memuat buku dan kategori default', () {
      expect(provider.allBooks.isNotEmpty, true);
      expect(provider.searchQuery, '');
      expect(provider.selectedKategori, 'Semua');
      expect(provider.onlyAvailable, false);
      expect(provider.availableCategories, contains('Semua'));
      expect(provider.availableCategories, contains('Teknologi'));
    });

    test('setSearchQuery memperbarui state dan memfilter daftar buku secara reaktif', () {
      bool notified = false;
      provider.addListener(() => notified = true);

      provider.setSearchQuery('Clean Code');

      expect(notified, true);
      expect(provider.searchQuery, 'Clean Code');
      expect(provider.filteredBooks.length, 1);
      expect(provider.filteredBooks.first.judul, contains('Clean Code'));
    });

    test('setKategori memperbarui filter kategori dan menghasilkan subset buku', () {
      provider.setKategori('Desain');

      expect(provider.selectedKategori, 'Desain');
      expect(provider.filteredBooks.every((b) => b.kategori == 'Desain'), true);
    });

    test('setOnlyAvailable hanya menampilkan buku yang berstatus tersedia', () {
      provider.setOnlyAvailable(true);

      expect(provider.onlyAvailable, true);
      expect(provider.filteredBooks.every((b) => b.tersedia), true);
    });

    test('setMinRating memfilter buku dengan rating di atas atau sama dengan nilai batas', () {
      provider.setMinRating(4.8);

      expect(provider.filteredBooks.every((b) => b.rating >= 4.8), true);
    });

    test('resetFilter mengembalikan seluruh filter ke nilai default', () {
      provider.setSearchQuery('Sprint');
      provider.setKategori('Bisnis');
      provider.setOnlyAvailable(true);
      provider.setMinRating(4.5);

      expect(provider.searchQuery, 'Sprint');

      provider.resetFilter();

      expect(provider.searchQuery, '');
      expect(provider.selectedKategori, 'Semua');
      expect(provider.onlyAvailable, false);
      expect(provider.minRating, isNull);
      expect(provider.filteredBooks.length, provider.allBooks.length);
    });

    test('tambahBuku menambahkan buku baru ke koleksi', () {
      final bukuBaru = const BookModel(
        id: 'bk_999',
        judul: 'Buku Pemrograman Baru',
        penulis: 'Penulis Hebat',
        kategori: 'Teknologi',
        tahunTerbit: 2026,
      );

      final totalAwal = provider.allBooks.length;
      provider.tambahBuku(bukuBaru);

      expect(provider.allBooks.length, totalAwal + 1);
      expect(provider.allBooks.last.id, 'bk_999');
    });
  });

  group('JSON Serialization Tests', () {
    test('BookModel fromJson dan toJson bekerja dengan tepat', () {
      final jsonSample = {
        'id': 'bk_123',
        'judul': 'Clean Code',
        'penulis': 'Robert C. Martin',
        'kategori': 'Teknologi',
        'tahunTerbit': 2008,
        'tersedia': true,
        'rating': 4.8,
        'deskripsi': 'Panduan menulis kode bersih.',
      };

      final book = BookModel.fromJson(jsonSample);
      expect(book.id, 'bk_123');
      expect(book.judul, 'Clean Code');
      expect(book.penulis, 'Robert C. Martin');
      expect(book.rating, 4.8);

      final exportedJson = book.toJson();
      expect(exportedJson['id'], 'bk_123');
      expect(exportedJson['judul'], 'Clean Code');
      expect(exportedJson['tahunTerbit'], 2008);
    });

    test('UserModel fromJson dan toJson bekerja dengan tepat', () {
      final userJson = {
        'id': 'usr_001',
        'nama': 'Gilang Ramadan',
        'email': 'gilang@telkomuniversity.ac.id',
        'universitas': 'Telkom University',
        'role': 'mahasiswa',
      };

      final user = UserModel.fromJson(userJson);
      expect(user.id, 'usr_001');
      expect(user.nama, 'Gilang Ramadan');
      expect(user.email, 'gilang@telkomuniversity.ac.id');

      final exportedJson = user.toJson();
      expect(exportedJson['nama'], 'Gilang Ramadan');
      expect(exportedJson['role'], 'mahasiswa');
    });
  });
}
