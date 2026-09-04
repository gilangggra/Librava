import { Router, Response, NextFunction } from 'express';
import { uploadImage } from '../middlewares/upload.middleware';
import { authenticate } from '../middlewares/auth.middleware';
import { AuthenticatedRequest } from '../types';

const router = Router();

router.post(
  '/image',
  authenticate,
  (req: AuthenticatedRequest, res: Response, next: NextFunction): void => {
    uploadImage.single('image')(req, res, (err: any) => {
      if (err) {
        res.status(400).json({
          success: false,
          message: err.message || 'Gagal mengunggah gambar.',
        });
        return;
      }

      if (!req.file) {
        res.status(400).json({
          success: false,
          message: 'Berkas gambar (field: image) wajib diunggah.',
        });
        return;
      }

      const host = req.get('host') || 'localhost:5000';
      const protocol = req.protocol;
      const fileUrl = `${protocol}://${host}/uploads/${req.file.filename}`;

      res.status(201).json({
        success: true,
        message: 'Gambar berhasil diunggah.',
        data: {
          filename: req.file.filename,
          original_name: req.file.originalname,
          mimetype: req.file.mimetype,
          size: req.file.size,
          url: fileUrl,
          path: `/uploads/${req.file.filename}`,
        },
      });
    });
  }
);

export default router;
