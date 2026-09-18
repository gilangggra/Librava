import prisma from '../config/prisma';
import { Review } from '../types';

export interface CreateReviewDTO {
  transaction_id: number;
  rating: number;
  komentar?: string;
}

const mapReviewWithRelations = (r: any): Review => ({
  id: r.id,
  transaction_id: r.transactionId,
  reviewer_id: r.reviewerId,
  reviewee_id: r.revieweeId,
  rating: r.rating,
  komentar: r.komentar || undefined,
  created_at: r.createdAt,
  reviewer_nama: r.reviewer?.namaLengkap,
});

export class ReviewService {
  static async createReview(reviewerId: number, dto: CreateReviewDTO): Promise<Review> {
    if (dto.rating < 1 || dto.rating > 5) {
      const error: any = new Error('Rating harus berada di antara angka 1 sampai 5.');
      error.statusCode = 400;
      throw error;
    }

    const tx = await prisma.transaction.findUnique({
      where: { id: dto.transaction_id },
    });

    if (!tx) {
      const error: any = new Error('Transaksi tidak ditemukan.');
      error.statusCode = 404;
      throw error;
    }

    if (tx.status !== 'SELESAI') {
      const error: any = new Error('Ulasan hanya dapat diberikan pada transaksi yang sudah selesai.');
      error.statusCode = 400;
      throw error;
    }

    if (tx.requesterId !== reviewerId && tx.ownerId !== reviewerId) {
      const error: any = new Error('Anda bukan peserta dalam transaksi ini.');
      error.statusCode = 403;
      throw error;
    }

    const revieweeId = tx.requesterId === reviewerId ? tx.ownerId : tx.requesterId;

    const existingReview = await prisma.review.findFirst({
      where: {
        transactionId: dto.transaction_id,
        reviewerId,
      },
    });

    if (existingReview) {
      const error: any = new Error('Anda sudah memberikan ulasan untuk transaksi ini.');
      error.statusCode = 400;
      throw error;
    }

    const review = await prisma.review.create({
      data: {
        transactionId: dto.transaction_id,
        reviewerId,
        revieweeId,
        rating: dto.rating,
        komentar: dto.komentar || null,
      },
      include: {
        reviewer: true,
      },
    });

    return mapReviewWithRelations(review);
  }

  static async getUserReviews(
    userId: number
  ): Promise<{ reviews: Review[]; average_rating: number; total_reviews: number }> {
    const [reviews, aggregate] = await Promise.all([
      prisma.review.findMany({
        where: { revieweeId: userId },
        include: {
          reviewer: true,
        },
        orderBy: {
          createdAt: 'desc',
        },
      }),
      prisma.review.aggregate({
        where: { revieweeId: userId },
        _avg: {
          rating: true,
        },
        _count: {
          id: true,
        },
      }),
    ]);

    const avg = aggregate._avg.rating || 0;
    const count = aggregate._count.id || 0;

    return {
      reviews: reviews.map(mapReviewWithRelations),
      average_rating: Math.round(avg * 10) / 10,
      total_reviews: count,
    };
  }
}
