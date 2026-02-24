import { Router } from 'express';
import { projectController } from '../controllers/project.controller';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validate.middleware';
import { createProjectSchema, updateProjectSchema, addMemberSchema } from '../validators/project.validator';
import { boardController } from '../controllers/board.controller';
import { taskController } from '../controllers/task.controller';
import { labelController } from '../controllers/label.controller';

const router = Router();

router.use(authenticate);

// Projects
router.get('/', projectController.list);
router.post('/', validate(createProjectSchema), projectController.create);
router.get('/:id', projectController.getById);
router.put('/:id', validate(updateProjectSchema), projectController.update);
router.delete('/:id', projectController.delete);

// Members
router.get('/:id/members', projectController.getMembers);
router.post('/:id/members', validate(addMemberSchema), projectController.addMember);
router.delete('/:id/members/:userId', projectController.removeMember);

// Boards (nested under projects)
router.get('/:id/boards', boardController.listByProject);
router.post('/:id/boards', boardController.create);

// Tasks (nested under projects)
router.get('/:id/tasks', taskController.listByProject);
router.post('/:id/tasks', taskController.create);

// Labels (nested under projects)
router.get('/:id/labels', labelController.listByProject);
router.post('/:id/labels', labelController.create);

export default router;
