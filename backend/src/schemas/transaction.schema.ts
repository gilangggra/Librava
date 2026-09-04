import { z } from 'zod';

export const createTransactionSchema = z.object({
  book_id: z.number(),
  tipe_transaksi: z.enum(['BORROW', 'BARTER'] as const),
  barter_book_id: z.number().optional().nullable(),
  deposit_dummy: z.number().nonnegative().optional().default(0),
  durasi_hari: z.number().int().positive().optional().default(7),
  lokasi_pertemuan: z.string().optional().nullable(),
  waktu_pertemuan: z.string().or(z.date()).optional().nullable(),
});

export const updateTransactionStatusSchema = z.object({
  status: z.enum([
    'MENUNGGU_KONFIRMASI',
    'DISETUJUI',
    'DITOLAK',
    'DIBATALKAN',
    'DALAM_PROSES',
    'SELESAI',
  ] as const),
});

export const setMeetingSchema = z.object({
  lokasi_pertemuan: z.string().min(1, 'Lokasi pertemuan wajib diisi.').optional(),
  lokasi: z.string().optional(),
  waktu_pertemuan: z.string().or(z.date()).optional(),
  waktu: z.string().or(z.date()).optional(),
}).refine((data) => !!(data.lokasi_pertemuan || data.lokasi), {
  message: 'Lokasi pertemuan wajib diisi.',
  path: ['lokasi_pertemuan'],
});
