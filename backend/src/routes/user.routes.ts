import { Router } from 'express';
import { userController } from '../controllers/user.controller';
import { authenticate } from '../middleware/auth.middleware';

const router = Router();

router.use(authenticate);

router.get('/search', userController.search);
router.get('/:id', userController.getProfile);
router.put('/me', userController.updateProfile);

export default router;
