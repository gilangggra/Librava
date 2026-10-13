import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/books/domain/models/book_review_model.dart';

void main() {
  group('BookReviewModel & BookReviewsData Unit Tests', () {
    test('BookReviewModel.fromApiJson mem-parsing ulasan tunggal dengan benar', () {
      final json = {
        'id': 1,
        'book_id': 5,
        'user_id': 12,
        'rating': 5,
        'komentar': 'Buku yang sangat inspiratif!',
        'created_at': '2026-10-12T10:00:00.000Z',
        'user': {
          'id': 12,
          'nama_lengkap': 'Ahmad Fauzi',
          'foto_profil': 'https://example.com/avatar.png',
        },
      };

      final review = BookReviewModel.fromApiJson(json);

      expect(review.id, 1);
      expect(review.bookId, 5);
      expect(review.userId, 12);
      expect(review.rating, 5);
      expect(review.komentar, 'Buku yang sangat inspiratif!');
      expect(review.userName, 'Ahmad Fauzi');
      expect(review.userPhoto, 'https://example.com/avatar.png');
    });

    test('BookReviewsData.fromApiJson mem-parsing agregat ulasan dan rata-rata rating', () {
      final dataJson = {
        'reviews': [
          {
            'id': 1,
            'book_id': 1,
            'user_id': 2,
            'rating': 5,
            'komentar': 'Keren!',
            'user': {'nama_lengkap': 'Budi'},
          },
          {
            'id': 2,
            'book_id': 1,
            'user_id': 3,
            'rating': 4,
            'komentar': 'Cukup menarik.',
            'user': {'nama_lengkap': 'Citra'},
          },
        ],
        'average_rating': 4.5,
        'total_reviews': 2,
      };

      final result = BookReviewsData.fromApiJson(dataJson);

      expect(result.reviews.length, 2);
      expect(result.averageRating, 4.5);
      expect(result.totalReviews, 2);
      expect(result.reviews.first.userName, 'Budi');
      expect(result.reviews.last.userName, 'Citra');
    });
  });
}
