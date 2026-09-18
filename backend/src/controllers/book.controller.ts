import { Request, Response, NextFunction } from 'express';
import { BookService } from '../services/book.service';
import { AuthenticatedRequest } from '../types';

export class BookController {
  static async createBook(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user?.id;
      if (!userId) {
        res.status(401).json({ success: false, message: 'Unauthorized' });
        return;
      }

      const { judul, penulis, penerbit, isbn, deskripsi, status, foto_buku, kategori } = req.body;

      if (!judul || !penulis) {
        res.status(400).json({
          success: false,
          message: 'Judul dan Penulis buku wajib diisi.',
        });
        return;
      }

      const book = await BookService.createBook({
        owner_id: userId,
        judul,
        penulis,
        penerbit,
        isbn,
        deskripsi,
        status,
        foto_buku,
        kategori,
      });

      res.status(201).json({
        success: true,
        message: 'Buku berhasil ditambahkan.',
        data: book,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getAllBooks(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { search, kategori, status, owner_id, limit, offset } = req.query;

      const result = await BookService.getAllBooks({
        search: search as string,
        kategori: kategori as string,
        status: status as string,
        owner_id: owner_id ? parseInt(owner_id as string, 10) : undefined,
        limit: limit ? parseInt(limit as string, 10) : 20,
        offset: offset ? parseInt(offset as string, 10) : 0,
      });

      res.status(200).json({
        success: true,
        message: 'Berhasil mengambil daftar buku.',
        data: result.books,
        meta: {
          total: result.total,
          limit: limit ? parseInt(limit as string, 10) : 20,
          offset: offset ? parseInt(offset as string, 10) : 0,
        },
      });
    } catch (error) {
      next(error);
    }
  }

  static async getMyBooks(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user?.id;
      if (!userId) {
        res.status(401).json({ success: false, message: 'Unauthorized' });
        return;
      }

      const result = await BookService.getAllBooks({
        owner_id: userId,
        limit: 100,
        offset: 0,
      });

      res.status(200).json({
        success: true,
        message: 'Berhasil mengambil daftar buku saya.',
        data: result.books,
        meta: { total: result.total },
      });
    } catch (error) {
      next(error);
    }
  }

  static async getBookById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = parseInt(req.params.id as string, 10);
      if (isNaN(id)) {
        res.status(400).json({ success: false, message: 'ID buku tidak valid.' });
        return;
      }

      const book = await BookService.getBookById(id);

      res.status(200).json({
        success: true,
        message: 'Berhasil mengambil detail buku.',
        data: book,
      });
    } catch (error) {
      next(error);
    }
  }

  static async updateBook(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = parseInt(req.params.id as string, 10);
      const userId = req.user?.id;
      const userRole = req.user?.role || 'mahasiswa';

      if (isNaN(id)) {
        res.status(400).json({ success: false, message: 'ID buku tidak valid.' });
        return;
      }

      if (!userId) {
        res.status(401).json({ success: false, message: 'Unauthorized' });
        return;
      }

      const updated = await BookService.updateBook(id, userId, userRole, req.body);

      res.status(200).json({
        success: true,
        message: 'Buku berhasil diperbarui.',
        data: updated,
      });
    } catch (error) {
      next(error);
    }
  }

  static async deleteBook(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = parseInt(req.params.id as string, 10);
      const userId = req.user?.id;
      const userRole = req.user?.role || 'mahasiswa';

      if (isNaN(id)) {
        res.status(400).json({ success: false, message: 'ID buku tidak valid.' });
        return;
      }

      if (!userId) {
        res.status(401).json({ success: false, message: 'Unauthorized' });
        return;
      }

      await BookService.deleteBook(id, userId, userRole);

      res.status(200).json({
        success: true,
        message: 'Buku berhasil dihapus.',
      });
    } catch (error) {
      next(error);
    }
  }
}
