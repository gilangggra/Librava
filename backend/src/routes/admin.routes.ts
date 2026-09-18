import { Router } from 'express';
import { AdminController } from '../controllers/admin.controller';
import { authenticate, authorizeAdmin } from '../middlewares/auth.middleware';

const router = Router();

router.use(authenticate, authorizeAdmin);

router.get('/dashboard', AdminController.getDashboard);
router.get('/users', AdminController.getUsers);
router.get('/transactions', AdminController.getTransactions);

export default router;
