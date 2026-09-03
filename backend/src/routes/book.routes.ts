import { Router } from 'express';
import { BookController } from '../controllers/book.controller';
import { authenticate } from '../middlewares/auth.middleware';

const router = Router();

router.get('/', BookController.getAllBooks);
router.get('/:id', BookController.getBookById);
router.get('/user/my-books', authenticate, BookController.getMyBooks);
router.post('/', authenticate, BookController.createBook);
router.put('/:id', authenticate, BookController.updateBook);
router.delete('/:id', authenticate, BookController.deleteBook);

export default router;
