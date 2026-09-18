import { Router } from 'express';
import { TransactionController } from '../controllers/transaction.controller';
import { authenticate } from '../middlewares/auth.middleware';
import { validate } from '../middlewares/validate.middleware';
import {
  createTransactionSchema,
  updateTransactionStatusSchema,
  setMeetingSchema,
} from '../schemas/transaction.schema';

const router = Router();

router.use(authenticate);

router.post('/', validate({ body: createTransactionSchema }), TransactionController.createTransaction);
router.get('/', TransactionController.getUserTransactions);
router.get('/:id', TransactionController.getTransactionById);
router.put('/:id/status', validate({ body: updateTransactionStatusSchema }), TransactionController.updateStatus);
router.put('/:id/meeting', validate({ body: setMeetingSchema }), TransactionController.setMeeting);
router.put('/:id/handover', TransactionController.confirmHandover);
router.put('/:id/return', TransactionController.confirmReturn);

export default router;
