import { Request, Response, NextFunction } from 'express';
import { ReviewService } from '../services/review.service';
import { AuthenticatedRequest } from '../types';

export class ReviewController {
  static async createReview(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user?.id;
      if (!userId) {
        res.status(401).json({ success: false, message: 'Unauthorized' });
        return;
      }

      const { transaction_id, rating, komentar } = req.body;

      if (!transaction_id || rating === undefined) {
        res.status(400).json({
          success: false,
          message: 'transaction_id dan rating (1-5) wajib diisi.',
        });
        return;
      }

      const review = await ReviewService.createReview(userId, {
        transaction_id: parseInt(transaction_id, 10),
        rating: parseInt(rating, 10),
        komentar,
      });

      res.status(201).json({
        success: true,
        message: 'Ulasan berhasil dikirim.',
        data: review,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getUserReviews(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = parseInt(req.params.userId as string, 10);
      if (isNaN(userId)) {
        res.status(400).json({ success: false, message: 'User ID tidak valid.' });
        return;
      }

      const result = await ReviewService.getUserReviews(userId);

      res.status(200).json({
        success: true,
        message: 'Berhasil mengambil daftar ulasan user.',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }
}
