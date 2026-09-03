import { Router } from 'express';
import { ChatController } from '../controllers/chat.controller';
import { authenticate } from '../middlewares/auth.middleware';

const router = Router();

router.use(authenticate);

router.get('/:transactionId', ChatController.getMessages);
router.post('/:transactionId', ChatController.sendMessage);

export default router;
