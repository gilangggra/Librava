import { Router } from 'express';
import { EventController } from '../controllers/event.controller';
import { authenticate, authorizeAdmin } from '../middlewares/auth.middleware';
import { validate } from '../middlewares/validate.middleware';
import { eventIdSchema, eventQuerySchema, eventSchema, eventStatusSchema, eventUpdateSchema } from '../schemas/event.schema';

const router = Router();

router.get('/', validate({ query: eventQuerySchema }), EventController.list);
router.get('/user/my-events', authenticate, EventController.getMyEvents);
router.get('/:id', validate({ params: eventIdSchema }), EventController.getById);
router.post('/', authenticate, validate({ body: eventSchema }), EventController.create);
router.put('/:id', authenticate, authorizeAdmin, validate({ params: eventIdSchema, body: eventUpdateSchema }), EventController.update);
router.patch('/:id/status', authenticate, authorizeAdmin, validate({ params: eventIdSchema, body: eventStatusSchema }), EventController.updateStatus);
router.put('/:id/status', authenticate, authorizeAdmin, validate({ params: eventIdSchema, body: eventStatusSchema }), EventController.updateStatus);
router.post('/:id/moderate', authenticate, authorizeAdmin, validate({ params: eventIdSchema, body: eventStatusSchema }), EventController.updateStatus);
router.delete('/:id', authenticate, authorizeAdmin, validate({ params: eventIdSchema }), EventController.remove);
router.post('/:id/register', authenticate, validate({ params: eventIdSchema }), EventController.register);

export default router;
