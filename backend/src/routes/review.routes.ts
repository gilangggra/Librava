import { Router } from 'express';
import { ReviewController } from '../controllers/review.controller';
import { authenticate } from '../middlewares/auth.middleware';

const router = Router();

router.get('/user/:userId', ReviewController.getUserReviews);
router.post('/', authenticate, ReviewController.createReview);

export default router;
