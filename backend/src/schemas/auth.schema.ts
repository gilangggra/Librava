import { z } from 'zod';

export const registerSchema = z.object({
  email: z.string().email('Format email tidak valid.').max(255),
  password: z.string().min(6, 'Password minimal 6 karakter.').max(100),
  nama_lengkap: z.string().min(2, 'Nama lengkap minimal 2 karakter.').max(255),
  nim: z.string().max(50).optional().nullable(),
  universitas: z.string().max(100).optional().default('Telkom University'),
  foto_profil: z.string().optional().nullable(),
  role: z.enum(['mahasiswa', 'admin'] as const).optional().default('mahasiswa'),
});

export const loginSchema = z.object({
  email: z.string().email('Format email tidak valid.'),
  password: z.string().min(1, 'Password wajib diisi.'),
});

export const updateProfileSchema = z.object({
  nama_lengkap: z.string().min(2).max(255).optional(),
  nim: z.string().max(50).optional().nullable(),
  universitas: z.string().max(100).optional(),
  foto_profil: z.string().optional().nullable(),
  password: z.string().min(6, 'Password minimal 6 karakter.').optional(),
});
