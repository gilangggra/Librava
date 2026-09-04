import { Router } from 'express';
import { BookController } from '../controllers/book.controller';
import { authenticate } from '../middlewares/auth.middleware';
import { validate } from '../middlewares/validate.middleware';
import { createBookSchema, updateBookSchema } from '../schemas/book.schema';

const router = Router();

router.get('/', BookController.getAllBooks);
router.get('/:id', BookController.getBookById);
router.get('/user/my-books', authenticate, BookController.getMyBooks);
router.post('/', authenticate, validate({ body: createBookSchema }), BookController.createBook);
router.put('/:id', authenticate, validate({ body: updateBookSchema }), BookController.updateBook);
router.delete('/:id', authenticate, BookController.deleteBook);

export default router;
