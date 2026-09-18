import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/auth.service';
import { AuthenticatedRequest } from '../types';

export class AuthController {
  static async register(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { email, password, nama_lengkap, nim, universitas, foto_profil, role } = req.body;

      if (!email || !password || !nama_lengkap) {
        res.status(400).json({
          success: false,
          message: 'Email, password, dan nama lengkap wajib diisi.',
        });
        return;
      }

      if (password.length < 6) {
        res.status(400).json({
          success: false,
          message: 'Password minimal 6 karakter.',
        });
        return;
      }

      const result = await AuthService.register({
        email,
        password,
        nama_lengkap,
        nim,
        universitas,
        foto_profil,
        role,
      });

      res.status(201).json({
        success: true,
        message: 'Registrasi berhasil.',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  static async login(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        res.status(400).json({
          success: false,
          message: 'Email dan password wajib diisi.',
        });
        return;
      }

      const result = await AuthService.login({ email, password });

      res.status(200).json({
        success: true,
        message: 'Login berhasil.',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getProfile(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user?.id;
      if (!userId) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      const profile = await AuthService.getProfile(userId);

      res.status(200).json({
        success: true,
        message: 'Berhasil mengambil profil pengguna.',
        data: profile,
      });
    } catch (error) {
      next(error);
    }
  }

  static async updateProfile(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user?.id;
      if (!userId) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      const updated = await AuthService.updateProfile(userId, req.body);

      res.status(200).json({
        success: true,
        message: 'Profil berhasil diperbarui.',
        data: updated,
      });
    } catch (error) {
      next(error);
    }
  }
}
