import { z } from 'zod';

export const createBookSchema = z.object({
  judul: z.string().min(1, 'Judul dan Penulis buku wajib diisi.').max(255),
  penulis: z.string().min(1, 'Judul dan Penulis buku wajib diisi.').max(255),
  penerbit: z.string().max(255).optional().nullable(),
  isbn: z.string().max(50).optional().nullable(),
  deskripsi: z.string().optional().nullable(),
  status: z.enum(['Tersedia', 'Dipinjam', 'Dibarter', 'Hilang', 'Tidak Tersedia'] as const).optional().default('Tersedia'),
  foto_buku: z.string().optional().nullable(),
  kategori: z.string().max(100).optional().nullable(),
});

export const updateBookSchema = z.object({
  judul: z.string().min(1).max(255).optional(),
  penulis: z.string().min(1).max(255).optional(),
  penerbit: z.string().max(255).optional().nullable(),
  isbn: z.string().max(50).optional().nullable(),
  deskripsi: z.string().optional().nullable(),
  status: z.enum(['Tersedia', 'Dipinjam', 'Dibarter', 'Hilang', 'Tidak Tersedia'] as const).optional(),
  foto_buku: z.string().optional().nullable(),
  kategori: z.string().max(100).optional().nullable(),
});

export const queryBookSchema = z.object({
  search: z.string().optional(),
  kategori: z.string().optional(),
  status: z.string().optional(),
  owner_id: z.string().transform((val) => (val ? parseInt(val, 10) : undefined)).optional(),
  limit: z.string().transform((val) => (val ? parseInt(val, 10) : 20)).optional(),
  offset: z.string().transform((val) => (val ? parseInt(val, 10) : 0)).optional(),
});
