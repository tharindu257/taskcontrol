import { Response, NextFunction } from 'express';
import { taskService } from '../services/task.service';
import { AuthRequest } from '../types';

export class TaskController {
  async listByProject(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { status, priority, type, assigneeId, search } = req.query;
      const tasks = await taskService.listByProject(req.params.id, {
        status: status as any,
        priority: priority as any,
        type: type as any,
        assigneeId: assigneeId as string,
        search: search as string,
      });
      res.json({ success: true, data: tasks });
    } catch (error) {
      next(error);
    }
  }

  async getById(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const task = await taskService.getById(req.params.id);
      res.json({ success: true, data: task });
    } catch (error) {
      next(error);
    }
  }

  async create(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const task = await taskService.create(req.params.id, req.body, req.user!.userId);
      res.status(201).json({ success: true, data: task });
    } catch (error) {
      next(error);
    }
  }

  async update(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const task = await taskService.update(req.params.id, req.body, req.user!.userId);
      res.json({ success: true, data: task });
    } catch (error) {
      next(error);
    }
  }

  async updateStatus(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { status } = req.body;
      const task = await taskService.updateStatus(req.params.id, status, req.user!.userId);
      res.json({ success: true, data: task });
    } catch (error) {
      next(error);
    }
  }

  async moveTask(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const task = await taskService.moveTask(req.params.id, req.body, req.user!.userId);
      res.json({ success: true, data: task });
    } catch (error) {
      next(error);
    }
  }

  async delete(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      await taskService.delete(req.params.id);
      res.json({ success: true, message: 'Task deleted' });
    } catch (error) {
      next(error);
    }
  }
}

export const taskController = new TaskController();
