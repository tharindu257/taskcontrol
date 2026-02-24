import { Router } from 'express';
import { commentController } from '../controllers/comment.controller';
import { authenticate } from '../middleware/auth.middleware';

const router = Router();

router.use(authenticate);

// Nested under tasks: /api/tasks/:id/comments is handled in task routes
// These are for direct comment operations
router.get('/task/:id', commentController.listByTask);
router.post('/task/:id', commentController.create);
router.put('/:id', commentController.update);
router.delete('/:id', commentController.delete);

export default router;
