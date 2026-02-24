import { Response, NextFunction } from 'express';
import { labelService } from '../services/label.service';
import { AuthRequest } from '../types';

export class LabelController {
  async listByProject(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const labels = await labelService.listByProject(req.params.id);
      res.json({ success: true, data: labels });
    } catch (error) {
      next(error);
    }
  }

  async create(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { name, color } = req.body;
      const label = await labelService.create(req.params.id, name, color || '#0052CC');
      res.status(201).json({ success: true, data: label });
    } catch (error) {
      next(error);
    }
  }

  async update(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const label = await labelService.update(req.params.id, req.body);
      res.json({ success: true, data: label });
    } catch (error) {
      next(error);
    }
  }

  async delete(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      await labelService.delete(req.params.id);
      res.json({ success: true, message: 'Label deleted' });
    } catch (error) {
      next(error);
    }
  }
}

export const labelController = new LabelController();
