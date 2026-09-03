import { Router } from 'express';
import { TransactionController } from '../controllers/transaction.controller';
import { authenticate } from '../middlewares/auth.middleware';

const router = Router();

router.use(authenticate);

router.post('/', TransactionController.createTransaction);
router.get('/', TransactionController.getUserTransactions);
router.get('/:id', TransactionController.getTransactionById);
router.put('/:id/status', TransactionController.updateStatus);
router.put('/:id/meeting', TransactionController.setMeeting);
router.put('/:id/handover', TransactionController.confirmHandover);

export default router;
