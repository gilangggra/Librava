import { z } from 'zod';

export const sendMessageSchema = z.object({
  pesan: z.string()
    .trim()
    .min(1, 'Pesan tidak boleh kosong.')
    .max(2000, 'Pesan maksimal 2000 karakter.'),
});
