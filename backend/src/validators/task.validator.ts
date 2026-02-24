import { z } from 'zod';

export const createTaskSchema = z.object({
  title: z.string().min(1, 'Title is required').max(200),
  description: z.string().max(5000).optional(),
  type: z.enum(['TASK', 'BUG', 'FEATURE', 'STORY']).optional(),
  priority: z.enum(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']).optional(),
  status: z.enum(['TO_DO', 'IN_PROGRESS', 'IN_REVIEW', 'DONE']).optional(),
  assigneeId: z.string().optional().nullable(),
  boardId: z.string().min(1, 'Board ID is required'),
  dueDate: z.string().datetime().optional().nullable(),
  labelIds: z.array(z.string()).optional(),
});

export const updateTaskSchema = z.object({
  title: z.string().min(1).max(200).optional(),
  description: z.string().max(5000).optional().nullable(),
  type: z.enum(['TASK', 'BUG', 'FEATURE', 'STORY']).optional(),
  priority: z.enum(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']).optional(),
  status: z.enum(['TO_DO', 'IN_PROGRESS', 'IN_REVIEW', 'DONE']).optional(),
  assigneeId: z.string().optional().nullable(),
  dueDate: z.string().datetime().optional().nullable(),
  position: z.number().int().min(0).optional(),
});

export const updateTaskStatusSchema = z.object({
  status: z.enum(['TO_DO', 'IN_PROGRESS', 'IN_REVIEW', 'DONE']),
});

export const moveTaskSchema = z.object({
  status: z.enum(['TO_DO', 'IN_PROGRESS', 'IN_REVIEW', 'DONE']).optional(),
  position: z.number().int().min(0),
});
