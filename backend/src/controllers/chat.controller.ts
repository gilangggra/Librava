import { Response, NextFunction } from 'express';
import { ChatService } from '../services/chat.service';
import { AuthenticatedRequest } from '../types';

export class ChatController {
  static async getMessages(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user?.id;
      const userRole = req.user?.role || 'mahasiswa';
      const transactionId = parseInt(req.params.transactionId as string, 10);

      if (isNaN(transactionId) || !userId) {
        res.status(400).json({ success: false, message: 'ID transaksi tidak valid.' });
        return;
      }

      const messages = await ChatService.getMessages(transactionId, userId, userRole);

      res.status(200).json({
        success: true,
        message: 'Berhasil mengambil pesan chat transaksi.',
        data: messages,
      });
    } catch (error) {
      next(error);
    }
  }

  static async sendMessage(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user?.id;
      const transactionId = parseInt(req.params.transactionId as string, 10);
      const { pesan } = req.body;

      if (isNaN(transactionId) || !userId) {
        res.status(400).json({ success: false, message: 'ID transaksi tidak valid.' });
        return;
      }

      if (!pesan || !pesan.trim()) {
        res.status(400).json({ success: false, message: 'Isi pesan tidak boleh kosong.' });
        return;
      }

      const chat = await ChatService.sendMessage(transactionId, userId, pesan.trim());

      res.status(201).json({
        success: true,
        message: 'Pesan berhasil dikirim.',
        data: chat,
      });
    } catch (error) {
      next(error);
    }
  }
}
