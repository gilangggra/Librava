import { Router } from 'express';
import rateLimit from 'express-rate-limit';
import { AuthController } from '../controllers/auth.controller';
import { authenticate } from '../middlewares/auth.middleware';
import { validate } from '../middlewares/validate.middleware';
import { registerSchema, loginSchema, updateProfileSchema } from '../schemas/auth.schema';
import { z } from 'zod';

const router = Router();

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: process.env.NODE_ENV === 'test' ? 1000 : 5,
  skipSuccessfulRequests: true,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Terlalu banyak percobaan login gagal dari IP ini. Silakan coba lagi setelah 15 menit.',
  },
});

const registerLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: process.env.NODE_ENV === 'test' ? 1000 : 50,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Terlalu banyak akun dibuat dari IP ini. Silakan coba lagi nanti.',
  },
});

router.post('/register', registerLimiter, validate({ body: registerSchema }), AuthController.register);
router.post('/login', loginLimiter, validate({ body: loginSchema }), AuthController.login);
router.post('/google', validate({ body: z.object({ id_token: z.string().min(1) }) }), AuthController.googleLogin);
router.get('/profile', authenticate, AuthController.getProfile);
router.get('/profile/:id', AuthController.getProfileById);
router.put('/profile', authenticate, validate({ body: updateProfileSchema }), AuthController.updateProfile);

export default router;
