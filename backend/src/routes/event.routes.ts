import { Router } from 'express';
import { EventController } from '../controllers/event.controller';
import { authenticate, authorizeAdmin } from '../middlewares/auth.middleware';
import { validate } from '../middlewares/validate.middleware';
import { eventIdSchema, eventQuerySchema, eventSchema, eventUpdateSchema } from '../schemas/event.schema';

const router = Router();

router.get('/', validate({ query: eventQuerySchema }), EventController.list);
router.get('/:id', validate({ params: eventIdSchema }), EventController.getById);
router.post('/', authenticate, authorizeAdmin, validate({ body: eventSchema }), EventController.create);
router.put('/:id', authenticate, authorizeAdmin, validate({ params: eventIdSchema, body: eventUpdateSchema }), EventController.update);
router.delete('/:id', authenticate, authorizeAdmin, validate({ params: eventIdSchema }), EventController.remove);
router.post('/:id/register', authenticate, validate({ params: eventIdSchema }), EventController.register);

export default router;
