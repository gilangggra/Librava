import { Router } from 'express';
import { AdminController } from '../controllers/admin.controller';
import { authenticate, authorizeAdmin } from '../middlewares/auth.middleware';
import { BookService } from '../services/book.service';
import { validate } from '../middlewares/validate.middleware';
import { moderationSchema } from '../schemas/event.schema';

const router = Router();

router.use(authenticate, authorizeAdmin);

router.get('/dashboard', AdminController.getDashboard);
router.get('/users', AdminController.getUsers);
router.get('/transactions', AdminController.getTransactions);
router.get('/books/pending', async (req, res, next) => {
	try {
		res.json({ success: true, message: 'Berhasil mengambil buku pending.', data: await BookService.getPendingBooks() });
	} catch (error) { next(error); }
});
router.patch('/books/:id/moderasi', validate({ body: moderationSchema }), async (req, res, next) => {
	try {
		const book = await BookService.moderateBook(Number(req.params.id), req.body.action, req.body.catatan);
		res.json({ success: true, message: 'Moderasi buku berhasil diperbarui.', data: book });
	} catch (error) { next(error); }
});

export default router;
