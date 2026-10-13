// lib/features/books/domain/models/book_review_model.dart

/// Model untuk data ulasan dan rating buku.
/// Didesain sederhana dan rapi agar mudah dipahami mahasiswa (pemula).
class BookReviewModel {
  final int id;
  final int bookId;
  final int userId;
  final int rating;
  final String? komentar;
  final DateTime? createdAt;
  final String userName;
  final String? userPhoto;

  const BookReviewModel({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.rating,
    this.komentar,
    this.createdAt,
    this.userName = 'Pengguna Librava',
    this.userPhoto,
  });

  /// Factory untuk mem-parsing data response dari backend API (/books/:id/reviews)
  factory BookReviewModel.fromApiJson(Map<String, dynamic> json) {
    final userMap = json['user'] as Map<String, dynamic>?;

    return BookReviewModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      bookId: (json['book_id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      komentar: json['komentar'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      userName: userMap?['nama_lengkap'] as String? ?? 'Pengguna Librava',
      userPhoto: userMap?['foto_profil'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'user_id': userId,
      'rating': rating,
      'komentar': komentar,
      'created_at': createdAt?.toIso8601String(),
      'user': {
        'id': userId,
        'nama_lengkap': userName,
        'foto_profil': userPhoto,
      },
    };
  }
}

/// Wadah data untuk menampung ringkasan rating dan daftar ulasan
class BookReviewsData {
  final List<BookReviewModel> reviews;
  final double averageRating;
  final int totalReviews;

  const BookReviewsData({
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
  });

  factory BookReviewsData.fromApiJson(Map<String, dynamic> json) {
    final rawList = json['reviews'] as List<dynamic>? ?? [];
    final reviews = rawList
        .map((item) => BookReviewModel.fromApiJson(item as Map<String, dynamic>))
        .toList();

    return BookReviewsData(
      reviews: reviews,
      averageRating: ((json['average_rating'] as num?)?.toDouble()) ?? 0.0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? reviews.length,
    );
  }
}
