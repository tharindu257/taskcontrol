import { Router } from 'express';
import { taskController } from '../controllers/task.controller';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validate.middleware';
import { updateTaskSchema, updateTaskStatusSchema, moveTaskSchema } from '../validators/task.validator';

const router = Router();

router.use(authenticate);

router.get('/:id', taskController.getById);
router.put('/:id', validate(updateTaskSchema), taskController.update);
router.delete('/:id', taskController.delete);
router.patch('/:id/status', validate(updateTaskStatusSchema), taskController.updateStatus);
router.patch('/:id/move', validate(moveTaskSchema), taskController.moveTask);

export default router;
