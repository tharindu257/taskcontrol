import { z } from 'zod';

export const createProjectSchema = z.object({
  name: z.string().min(1, 'Project name is required').max(100),
  key: z
    .string()
    .min(2, 'Key must be at least 2 characters')
    .max(10)
    .regex(/^[A-Z][A-Z0-9]*$/, 'Key must be uppercase letters/numbers, starting with a letter'),
  description: z.string().max(500).optional(),
  visibility: z.enum(['PUBLIC', 'PRIVATE']).optional(),
});

export const updateProjectSchema = z.object({
  name: z.string().min(1).max(100).optional(),
  description: z.string().max(500).optional(),
  visibility: z.enum(['PUBLIC', 'PRIVATE']).optional(),
});

export const addMemberSchema = z.object({
  userId: z.string().min(1, 'User ID is required'),
  role: z.enum(['ADMIN', 'MEMBER', 'VIEWER']).optional(),
});
