import { Response, NextFunction } from 'express';
import { AdminService } from '../services/admin.service';
import { AuthenticatedRequest } from '../types';

export class AdminController {
  static async getDashboard(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const stats = await AdminService.getDashboardStats();
      res.status(200).json({
        success: true,
        message: 'Berhasil mengambil statistik dashboard admin.',
        data: stats,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getUsers(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const { search } = req.query;
      const users = await AdminService.getAllUsers(search as string);
      res.status(200).json({
        success: true,
        message: 'Berhasil mengambil daftar seluruh pengguna.',
        data: users,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getTransactions(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const { status, type } = req.query;
      const transactions = await AdminService.getAllTransactions(status as string, type as string);
      res.status(200).json({
        success: true,
        message: 'Berhasil mengambil seluruh daftar transaksi sistem.',
        data: transactions,
      });
    } catch (error) {
      next(error);
    }
  }
}
