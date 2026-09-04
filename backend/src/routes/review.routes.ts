import { Router } from 'express';
import { ReviewController } from '../controllers/review.controller';
import { authenticate } from '../middlewares/auth.middleware';
import { validate } from '../middlewares/validate.middleware';
import { createReviewSchema } from '../schemas/review.schema';

const router = Router();

router.get('/user/:userId', ReviewController.getUserReviews);
router.post('/', authenticate, validate({ body: createReviewSchema }), ReviewController.createReview);

export default router;
