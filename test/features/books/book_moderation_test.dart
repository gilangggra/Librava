import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/admin/domain/models/admin_book_model.dart';
import 'package:librava/features/books/domain/models/book_model.dart';

void main() {
  group('Book Moderation Model Tests (SRS FR-ADM-07 & FR-BUK-003)', () {
    test('BookModel.fromApiJson parses status_moderasi and catatan_moderasi properly', () {
      final jsonPending = {
        'id': 101,
        'judul': 'Sistem Operasi Modern',
        'penulis': 'Andrew S. Tanenbaum',
        'kategori': 'Informatika',
        'status': 'Tersedia',
        'status_moderasi': 'PENDING',
        'catatan_moderasi': null,
      };

      final bookPending = BookModel.fromApiJson(jsonPending);
      expect(bookPending.statusModerasi, 'PENDING');
      expect(bookPending.isPending, isTrue);
      expect(bookPending.isDisetujui, isFalse);
      expect(bookPending.isDitolak, isFalse);
      expect(bookPending.catatanModerasi, isNull);

      final jsonDitolak = {
        'id': 102,
        'judul': 'Buku Rusak',
        'penulis': 'Anonim',
        'kategori': 'Umum',
        'status': 'Tersedia',
        'status_moderasi': 'DITOLAK',
        'catatan_moderasi': 'Foto buku tidak jelas dan blur.',
      };

      final bookDitolak = BookModel.fromApiJson(jsonDitolak);
      expect(bookDitolak.statusModerasi, 'DITOLAK');
      expect(bookDitolak.isPending, isFalse);
      expect(bookDitolak.isDisetujui, isFalse);
      expect(bookDitolak.isDitolak, isTrue);
      expect(bookDitolak.catatanModerasi, 'Foto buku tidak jelas dan blur.');
    });

    test('BookModel.copyWith updates status_moderasi and catatan_moderasi correctly', () {
      const initialBook = BookModel(
        id: '1',
        judul: 'Clean Architecture',
        penulis: 'Robert C. Martin',
        kategori: 'Teknologi',
        tahunTerbit: 2017,
        statusModerasi: 'PENDING',
      );

      final approvedBook = initialBook.copyWith(
        statusModerasi: 'DISETUJUI',
      );

      expect(approvedBook.statusModerasi, 'DISETUJUI');
      expect(approvedBook.isDisetujui, isTrue);
      expect(approvedBook.isPending, isFalse);
    });

    test('AdminBookModel.fromJson parses moderation attributes', () {
      final json = {
        'id': '99',
        'judul': 'Rekayasa Perangkat Lunak',
        'penulis': 'Roger S. Pressman',
        'penerbit': 'McGraw-Hill',
        'kategori': 'Informatika',
        'status': 'Tersedia',
        'status_moderasi': 'PENDING',
        'catatan_moderasi': 'Perlu verifikasi',
        'owner_nama': 'Budi Santoso',
      };

      final adminBook = AdminBookModel.fromJson(json);
      expect(adminBook.id, '99');
      expect(adminBook.statusModerasi, 'PENDING');
      expect(adminBook.isPending, isTrue);
      expect(adminBook.catatanModerasi, 'Perlu verifikasi');
    });
  });
}
