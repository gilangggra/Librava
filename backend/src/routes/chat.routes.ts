import { Router } from 'express';
import { ChatController } from '../controllers/chat.controller';
import { authenticate } from '../middlewares/auth.middleware';
import { validate } from '../middlewares/validate.middleware';
import { sendMessageSchema } from '../schemas/chat.schema';

const router = Router();

router.use(authenticate);

router.get('/:transactionId', ChatController.getMessages);
router.post('/:transactionId', validate({ body: sendMessageSchema }), ChatController.sendMessage);

export default router;
