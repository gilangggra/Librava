import { z } from 'zod';

const eventFields = z.object({
  judul: z.string().min(1).max(255),
  deskripsi: z.string().min(1),
  kategori: z.string().max(100).optional().nullable(),
  lokasi: z.string().min(1).max(255),
  tanggal_mulai: z.coerce.date(),
  tanggal_selesai: z.coerce.date().optional().nullable(),
  kuota: z.number().int().min(1).max(100000).default(100),
  foto_event: z.string().optional().nullable(),
  status: z.enum(['APPROVED', 'PENDING', 'REJECTED']).optional().default('APPROVED'),
});

const validEventDates = <T extends { tanggal_mulai?: Date; tanggal_selesai?: Date | null }>(value: T) =>
  !value.tanggal_mulai || !value.tanggal_selesai || value.tanggal_selesai >= value.tanggal_mulai;

export const eventSchema = eventFields.refine((value) => validEventDates(value), {
  message: 'Tanggal selesai tidak boleh sebelum tanggal mulai.',
  path: ['tanggal_selesai'],
});

export const eventUpdateSchema = eventFields.partial().refine((value) => validEventDates(value), {
  message: 'Tanggal selesai tidak boleh sebelum tanggal mulai.',
  path: ['tanggal_selesai'],
});

export const eventQuerySchema = z.object({
  search: z.string().optional(),
  kategori: z.string().optional(),
  status: z.string().optional(),
  mulai_dari: z.coerce.date().optional(),
  sampai_dengan: z.coerce.date().optional(),
});

export const eventIdSchema = z.object({
  id: z.coerce.number().int().positive(),
});

export const moderationSchema = z.object({
  action: z.enum(['APPROVE', 'REJECT']),
  catatan: z.string().max(2000).optional().nullable(),
});

export const eventStatusSchema = z.object({
  status: z.enum(['APPROVED', 'PENDING', 'REJECTED']).optional(),
  action: z.enum(['APPROVE', 'REJECT']).optional(),
  catatan: z.string().max(2000).optional().nullable(),
}).refine((data) => data.status !== undefined || data.action !== undefined, {
  message: 'Harus menyertakan status atau action.',
});

