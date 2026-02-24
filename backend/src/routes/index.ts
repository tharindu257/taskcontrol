import { Router } from 'express';
import authRoutes from './auth.routes';
import userRoutes from './user.routes';
import projectRoutes from './project.routes';
import boardRoutes from './board.routes';
import taskRoutes from './task.routes';
import commentRoutes from './comment.routes';
import labelRoutes from './label.routes';

export const router = Router();

router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/projects', projectRoutes);
router.use('/boards', boardRoutes);
router.use('/tasks', taskRoutes);
router.use('/comments', commentRoutes);
router.use('/labels', labelRoutes);
