import { Response, NextFunction } from 'express';
import { commentService } from '../services/comment.service';
import { AuthRequest } from '../types';

export class CommentController {
  async listByTask(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const comments = await commentService.listByTask(req.params.id);
      res.json({ success: true, data: comments });
    } catch (error) {
      next(error);
    }
  }

  async create(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { content } = req.body;
      const comment = await commentService.create(req.params.id, content, req.user!.userId);
      res.status(201).json({ success: true, data: comment });
    } catch (error) {
      next(error);
    }
  }

  async update(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { content } = req.body;
      const comment = await commentService.update(req.params.id, content, req.user!.userId);
      res.json({ success: true, data: comment });
    } catch (error) {
      next(error);
    }
  }

  async delete(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      await commentService.delete(req.params.id, req.user!.userId);
      res.json({ success: true, message: 'Comment deleted' });
    } catch (error) {
      next(error);
    }
  }
}

export const commentController = new CommentController();
