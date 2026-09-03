import prisma from '../config/prisma';
import { Book } from '../types';
import { sanitizeText } from '../utils/sanitize';

export interface CreateBookDTO {
  owner_id: number;
  judul: string;
  penulis: string;
  penerbit?: string;
  isbn?: string;
  deskripsi?: string;
  status?: 'Tersedia' | 'Dipinjam' | 'Dibarter' | 'Tidak Tersedia';
  foto_buku?: string;
  kategori?: string;
}

export interface BookFilterParams {
  search?: string;
  kategori?: string;
  status?: string;
  owner_id?: number;
  limit?: number;
  offset?: number;
}

const mapBookWithRelations = (book: any): Book => ({
  id: book.id,
  owner_id: book.ownerId,
  judul: book.judul,
  penulis: book.penulis,
  penerbit: book.penerbit,
  isbn: book.isbn,
  deskripsi: book.deskripsi,
  status: book.status,
  foto_buku: book.fotoBuku,
  kategori: book.kategori,
  created_at: book.createdAt,
  updated_at: book.updatedAt,
  owner_nama: book.owner?.namaLengkap,
  owner_universitas: book.owner?.universitas,
  owner_foto: book.owner?.fotoProfil,
});

export class BookService {
  static async createBook(dto: CreateBookDTO): Promise<Book> {
    const created = await prisma.book.create({
      data: {
        ownerId: dto.owner_id,
        judul: sanitizeText(dto.judul) || dto.judul,
        penulis: sanitizeText(dto.penulis) || dto.penulis,
        penerbit: sanitizeText(dto.penerbit) || null,
        isbn: dto.isbn || null,
        deskripsi: sanitizeText(dto.deskripsi) || null,
        status: dto.status || 'Tersedia',
        fotoBuku: dto.foto_buku || null,
        kategori: dto.kategori || null,
      },
      include: {
        owner: true,
      },
    });

    return mapBookWithRelations(created);
  }

  static async getAllBooks(params: BookFilterParams): Promise<{ books: Book[]; total: number }> {
    const where: any = {};

    if (params.search) {
      where.OR = [
        { judul: { contains: params.search, mode: 'insensitive' } },
        { penulis: { contains: params.search, mode: 'insensitive' } },
        { penerbit: { contains: params.search, mode: 'insensitive' } },
      ];
    }

    if (params.kategori) {
      where.kategori = { contains: params.kategori, mode: 'insensitive' };
    }

    if (params.status) {
      where.status = params.status;
    }

    if (params.owner_id) {
      where.ownerId = params.owner_id;
    }

    const limit = params.limit || 20;
    const offset = params.offset || 0;

    const [books, total] = await Promise.all([
      prisma.book.findMany({
        where,
        include: {
          owner: true,
        },
        orderBy: {
          createdAt: 'desc',
        },
        take: limit,
        skip: offset,
      }),
      prisma.book.count({ where }),
    ]);

    return {
      books: books.map(mapBookWithRelations),
      total,
    };
  }

  static async getBookById(id: number): Promise<Book> {
    const book = await prisma.book.findUnique({
      where: { id },
      include: {
        owner: true,
      },
    });

    if (!book) {
      const error: any = new Error('Buku tidak ditemukan.');
      error.statusCode = 404;
      throw error;
    }

    return mapBookWithRelations(book);
  }

  static async updateBook(
    id: number,
    userId: number,
    userRole: string,
    updateData: Partial<CreateBookDTO>
  ): Promise<Book> {
    const existing = await this.getBookById(id);

    if (existing.owner_id !== userId && userRole !== 'admin') {
      const error: any = new Error('Anda tidak memiliki hak akses untuk mengubah buku ini.');
      error.statusCode = 403;
      throw error;
    }

    const data: any = {};
    if (updateData.judul !== undefined) data.judul = sanitizeText(updateData.judul) || updateData.judul;
    if (updateData.penulis !== undefined) data.penulis = sanitizeText(updateData.penulis) || updateData.penulis;
    if (updateData.penerbit !== undefined) data.penerbit = sanitizeText(updateData.penerbit);
    if (updateData.isbn !== undefined) data.isbn = updateData.isbn;
    if (updateData.deskripsi !== undefined) data.deskripsi = sanitizeText(updateData.deskripsi);
    if (updateData.status !== undefined) data.status = updateData.status;
    if (updateData.foto_buku !== undefined) data.fotoBuku = updateData.foto_buku;
    if (updateData.kategori !== undefined) data.kategori = updateData.kategori;

    const updated = await prisma.book.update({
      where: { id },
      data,
      include: {
        owner: true,
      },
    });

    return mapBookWithRelations(updated);
  }

  static async deleteBook(id: number, userId: number, userRole: string): Promise<void> {
    const existing = await this.getBookById(id);

    if (existing.owner_id !== userId && userRole !== 'admin') {
      const error: any = new Error('Anda tidak memiliki hak akses untuk menghapus buku ini.');
      error.statusCode = 403;
      throw error;
    }

    await prisma.book.delete({
      where: { id },
    });
  }
}
