class UserReviewItem {
  final int id;
  final int rating;
  final String komentar;
  final String createdAt;
  final int reviewerId;
  final String reviewerNama;
  final String? reviewerFoto;
  final int? transactionId;

  const UserReviewItem({
    required this.id,
    required this.rating,
    required this.komentar,
    required this.createdAt,
    required this.reviewerId,
    required this.reviewerNama,
    this.reviewerFoto,
    this.transactionId,
  });

  factory UserReviewItem.fromJson(Map<String, dynamic> json) {
    final reviewer = json['reviewer'] as Map<String, dynamic>?;
    return UserReviewItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      komentar: json['komentar'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? json['createdAt'] as String? ?? '',
      reviewerId: (reviewer?['id'] as num?)?.toInt() ??
          (json['reviewer_id'] as num?)?.toInt() ??
          0,
      reviewerNama: reviewer?['nama_lengkap'] as String? ??
          reviewer?['namaLengkap'] as String? ??
          'Mahasiswa Librava',
      reviewerFoto: reviewer?['foto_profil'] as String? ??
          reviewer?['fotoProfil'] as String?,
      transactionId: (json['transaction_id'] as num?)?.toInt() ??
          (json['transactionId'] as num?)?.toInt(),
    );
  }
}

class UserReviewsData {
  final int userId;
  final int totalReviews;
  final double averageRating;
  final List<UserReviewItem> reviews;

  const UserReviewsData({
    required this.userId,
    required this.totalReviews,
    required this.averageRating,
    required this.reviews,
  });

  factory UserReviewsData.fromJson(Map<String, dynamic> json) {
    final rawList = json['reviews'] as List<dynamic>? ?? [];
    final parsedReviews = rawList
        .map((r) => UserReviewItem.fromJson(r as Map<String, dynamic>))
        .toList();

    return UserReviewsData(
      userId: (json['userId'] as num?)?.toInt() ??
          (json['user_id'] as num?)?.toInt() ??
          0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ??
          (json['total_reviews'] as num?)?.toInt() ??
          parsedReviews.length,
      averageRating: (json['averageRating'] as num?)?.toDouble() ??
          (json['average_rating'] as num?)?.toDouble() ??
          5.0,
      reviews: parsedReviews,
    );
  }
}
