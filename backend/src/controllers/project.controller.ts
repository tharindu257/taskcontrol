import { Response, NextFunction } from 'express';
import { projectService } from '../services/project.service';
import { AuthRequest } from '../types';

export class ProjectController {
  async list(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const projects = await projectService.list(req.user!.userId);
      res.json({ success: true, data: projects });
    } catch (error) {
      next(error);
    }
  }

  async getById(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const project = await projectService.getById(req.params.id, req.user!.userId);
      res.json({ success: true, data: project });
    } catch (error) {
      next(error);
    }
  }

  async create(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const project = await projectService.create(req.body, req.user!.userId);
      res.status(201).json({ success: true, data: project });
    } catch (error) {
      next(error);
    }
  }

  async update(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const project = await projectService.update(req.params.id, req.body, req.user!.userId);
      res.json({ success: true, data: project });
    } catch (error) {
      next(error);
    }
  }

  async delete(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      await projectService.delete(req.params.id, req.user!.userId);
      res.json({ success: true, message: 'Project deleted' });
    } catch (error) {
      next(error);
    }
  }

  async addMember(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { userId, role } = req.body;
      const member = await projectService.addMember(req.params.id, userId, role, req.user!.userId);
      res.status(201).json({ success: true, data: member });
    } catch (error) {
      next(error);
    }
  }

  async removeMember(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      await projectService.removeMember(req.params.id, req.params.userId, req.user!.userId);
      res.json({ success: true, message: 'Member removed' });
    } catch (error) {
      next(error);
    }
  }

  async getMembers(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const members = await projectService.getMembers(req.params.id);
      res.json({ success: true, data: members });
    } catch (error) {
      next(error);
    }
  }
}

export const projectController = new ProjectController();
