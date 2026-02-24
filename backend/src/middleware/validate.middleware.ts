import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';
import { ApiError } from '../utils/apiError';

export function validate(schema: ZodSchema) {
  return (req: Request, _res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      const zodError = result.error as ZodError;
      const messages = zodError.issues.map((issue: any) => issue.message).join(', ');
      return next(ApiError.badRequest(messages));
    }
    req.body = result.data;
    next();
  };
}
