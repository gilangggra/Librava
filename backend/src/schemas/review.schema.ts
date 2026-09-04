import { z } from 'zod';

export const createReviewSchema = z.object({
  transaction_id: z.number(),
  rating: z.number()
    .int('Rating harus berupa bilangan bulat.')
    .min(1, 'Rating harus bernilai antara 1 dan 5.')
    .max(5, 'Rating harus bernilai antara 1 dan 5.'),
  komentar: z.string().max(1000).optional().nullable(),
});
