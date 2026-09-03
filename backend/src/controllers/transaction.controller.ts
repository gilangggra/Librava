import { Response, NextFunction } from 'express';
import { TransactionService } from '../services/transaction.service';
import { AuthenticatedRequest, TransactionStatus } from '../types';

export class TransactionController {
  static async createTransaction(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user?.id;
      if (!userId) {
        res.status(401).json({ success: false, message: 'Unauthorized' });
        return;
      }

      const { book_id, tipe_transaksi, barter_book_id, deposit_dummy, lokasi_pertemuan, waktu_pertemuan } = req.body;

      if (!book_id || !tipe_transaksi) {
        res.status(400).json({
          success: false,
          message: 'book_id dan tipe_transaksi (BORROW/BARTER) wajib diisi.',
        });
        return;
      }

      const tx = await TransactionService.createTransaction({
        requester_id: userId,
        book_id: parseInt(book_id, 10),
        tipe_transaksi,
        barter_book_id: barter_book_id ? parseInt(barter_book_id, 10) : undefined,
        deposit_dummy: deposit_dummy !== undefined ? parseFloat(deposit_dummy) : 0,
        lokasi_pertemuan,
        waktu_pertemuan,
      });

      res.status(201).json({
        success: true,
        message: 'Pengajuan transaksi berhasil dibuat.',
        data: tx,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getUserTransactions(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user?.id;
      if (!userId) {
        res.status(401).json({ success: false, message: 'Unauthorized' });
        return;
      }

      const { role, status } = req.query;

      const transactions = await TransactionService.getUserTransactions(userId, {
        roleFilter: role as 'requester' | 'owner',
        status: status as string,
      });

      res.status(200).json({
        success: true,
        message: 'Berhasil mengambil daftar transaksi.',
        data: transactions,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getTransactionById(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user?.id;
      const userRole = req.user?.role || 'mahasiswa';
      const id = parseInt(req.params.id as string, 10);

      if (isNaN(id) || !userId) {
        res.status(400).json({ success: false, message: 'ID transaksi tidak valid.' });
        return;
      }

      const tx = await TransactionService.getTransactionById(id, userId, userRole);

      res.status(200).json({
        success: true,
        message: 'Berhasil mengambil detail transaksi.',
        data: tx,
      });
    } catch (error) {
      next(error);
    }
  }

  static async updateStatus(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user?.id;
      const userRole = req.user?.role || 'mahasiswa';
      const id = parseInt(req.params.id as string, 10);
      const { status } = req.body;

      if (isNaN(id) || !userId) {
        res.status(400).json({ success: false, message: 'ID transaksi tidak valid.' });
        return;
      }

      if (!status) {
        res.status(400).json({ success: false, message: 'Status baru wajib diisi.' });
        return;
      }

      const updated = await TransactionService.updateStatus(id, userId, userRole, status as TransactionStatus);

      res.status(200).json({
        success: true,
        message: `Status transaksi berhasil diperbarui menjadi ${status}.`,
        data: updated,
      });
    } catch (error) {
      next(error);
    }
  }

  static async setMeeting(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user?.id;
      const userRole = req.user?.role || 'mahasiswa';
      const id = parseInt(req.params.id as string, 10);
      const { lokasi_pertemuan, waktu_pertemuan } = req.body;

      if (isNaN(id) || !userId) {
        res.status(400).json({ success: false, message: 'ID transaksi tidak valid.' });
        return;
      }

      if (!lokasi_pertemuan) {
        res.status(400).json({ success: false, message: 'Lokasi pertemuan wajib diisi.' });
        return;
      }

      const updated = await TransactionService.setMeetingDetails(
        id,
        userId,
        userRole,
        lokasi_pertemuan,
        waktu_pertemuan
      );

      res.status(200).json({
        success: true,
        message: 'Lokasi dan jadwal pertemuan berhasil ditentukan.',
        data: updated,
      });
    } catch (error) {
      next(error);
    }
  }

  static async confirmHandover(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user?.id;
      const userRole = req.user?.role || 'mahasiswa';
      const id = parseInt(req.params.id as string, 10);

      if (isNaN(id) || !userId) {
        res.status(400).json({ success: false, message: 'ID transaksi tidak valid.' });
        return;
      }

      const updated = await TransactionService.confirmHandover(id, userId, userRole);

      res.status(200).json({
        success: true,
        message: 'Serah terima buku berhasil dikonfirmasi. Transaksi selesai.',
        data: updated,
      });
    } catch (error) {
      next(error);
    }
  }
}
