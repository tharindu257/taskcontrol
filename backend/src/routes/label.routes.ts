import { Router } from 'express';
import { labelController } from '../controllers/label.controller';
import { authenticate } from '../middleware/auth.middleware';

const router = Router();

router.use(authenticate);

router.put('/:id', labelController.update);
router.delete('/:id', labelController.delete);

export default router;
