import { Router } from 'express';
import authRoutes from './auth.routes';
import bookRoutes from './book.routes';
import transactionRoutes from './transaction.routes';
import chatRoutes from './chat.routes';
import reviewRoutes from './review.routes';
import adminRoutes from './admin.routes';

const router = Router();

router.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Librava API',
    endpoints: {
      health: 'GET /api/health',
      auth: {
        register: 'POST /api/auth/register',
        login: 'POST /api/auth/login',
        profile: 'GET /api/auth/profile',
        update_profile: 'PUT /api/auth/profile',
      },
      books: {
        list: 'GET /api/books',
        detail: 'GET /api/books/:id',
        my_books: 'GET /api/books/user/my-books',
        create: 'POST /api/books',
        update: 'PUT /api/books/:id',
        delete: 'DELETE /api/books/:id',
      },
      transactions: {
        create: 'POST /api/transactions',
        list: 'GET /api/transactions',
        detail: 'GET /api/transactions/:id',
        update_status: 'PUT /api/transactions/:id/status',
        set_meeting: 'PUT /api/transactions/:id/meeting',
        handover: 'PUT /api/transactions/:id/handover',
      },
      chats: {
        list: 'GET /api/chats/:transactionId',
        send: 'POST /api/chats/:transactionId',
      },
      reviews: {
        create: 'POST /api/reviews',
        user_reviews: 'GET /api/reviews/user/:userId',
      },
      admin: {
        dashboard: 'GET /api/admin/dashboard',
        users: 'GET /api/admin/users',
        transactions: 'GET /api/admin/transactions',
      },
    },
  });
});

router.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
  });
});

router.use('/auth', authRoutes);
router.use('/books', bookRoutes);
router.use('/transactions', transactionRoutes);
router.use('/chats', chatRoutes);
router.use('/reviews', reviewRoutes);
router.use('/admin', adminRoutes);

export default router;
