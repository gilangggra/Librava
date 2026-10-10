import { Request, Response, NextFunction } from 'express';
import { AuthenticatedRequest } from '../types';
import { BookRatingService } from '../services/book-rating.service';

export class BookRatingController {
  static async getReviews(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const data = await BookRatingService.getReviews(Number(req.params.id));
      res.json({ success: true, message: 'Berhasil mengambil review buku.', data });
    } catch (error) { next(error); }
  }

  static async upsert(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const review = await BookRatingService.upsert(Number(req.params.id), req.user!.id, req.body.rating, req.body.komentar);
      res.status(200).json({ success: true, message: 'Rating buku berhasil disimpan.', data: review });
    } catch (error) { next(error); }
  }

  static async remove(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const requestedUserId = req.query.user_id ? Number(req.query.user_id) : req.user!.id;
      if (!Number.isInteger(requestedUserId) || requestedUserId <= 0) {
        res.status(400).json({ success: false, message: 'user_id tidak valid.' });
        return;
      }
      if (req.user!.role !== 'admin' && requestedUserId !== req.user!.id) {
        res.status(403).json({ success: false, message: 'Anda hanya dapat menghapus review sendiri.' });
        return;
      }
      await BookRatingService.remove(Number(req.params.id), req.user!.id, req.user!.role, requestedUserId);
      res.json({ success: true, message: 'Review buku berhasil dihapus.' });
    } catch (error) { next(error); }
  }
}
