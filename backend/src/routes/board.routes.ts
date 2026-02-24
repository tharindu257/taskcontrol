import { Router } from 'express';
import { boardController } from '../controllers/board.controller';
import { authenticate } from '../middleware/auth.middleware';

const router = Router();

router.use(authenticate);

router.get('/:id', boardController.getById);
router.put('/:id', boardController.update);
router.delete('/:id', boardController.delete);

export default router;
