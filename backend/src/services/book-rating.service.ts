import prisma from '../config/prisma';

export class BookRatingService {
  static async getReviews(bookId: number) {
    const [reviews, aggregate] = await Promise.all([
      prisma.bookRating.findMany({
        where: { bookId },
        include: { user: { select: { id: true, namaLengkap: true, fotoProfil: true } } },
        orderBy: { createdAt: 'desc' },
      }),
      prisma.bookRating.aggregate({
        where: { bookId },
        _avg: { rating: true },
        _count: { id: true },
      }),
    ]);

    return {
      reviews: reviews.map((review) => ({
        id: review.id,
        book_id: review.bookId,
        user_id: review.userId,
        rating: review.rating,
        komentar: review.komentar,
        created_at: review.createdAt,
        updated_at: review.updatedAt,
        user: {
          id: review.user.id,
          nama_lengkap: review.user.namaLengkap,
          foto_profil: review.user.fotoProfil,
        },
      })),
      average_rating: Math.round((aggregate._avg.rating || 0) * 10) / 10,
      total_reviews: aggregate._count.id,
    };
  }

  static async upsert(bookId: number, userId: number, rating: number, komentar?: string | null) {
    const book = await prisma.book.findUnique({ where: { id: bookId }, select: { id: true } });
    if (!book) {
      const error: any = new Error('Buku tidak ditemukan.');
      error.statusCode = 404;
      throw error;
    }

    const review = await prisma.bookRating.upsert({
      where: { bookId_userId: { bookId, userId } },
      create: { bookId, userId, rating, komentar: komentar || null },
      update: { rating, komentar: komentar || null },
    });
    return review;
  }

  static async remove(bookId: number, userId: number, role: string, targetUserId = userId) {
    const existing = await prisma.bookRating.findUnique({ where: { bookId_userId: { bookId, userId: targetUserId } } });
    if (!existing && role !== 'admin') {
      const error: any = new Error('Review tidak ditemukan.');
      error.statusCode = 404;
      throw error;
    }
    if (role === 'admin') {
      await prisma.bookRating.deleteMany({ where: { bookId, userId: targetUserId } });
    } else {
      await prisma.bookRating.delete({ where: { bookId_userId: { bookId, userId: targetUserId } } });
    }
  }
}
