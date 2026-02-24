import { Response, NextFunction } from 'express';
import { boardService } from '../services/board.service';
import { AuthRequest } from '../types';

export class BoardController {
  async listByProject(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const boards = await boardService.listByProject(req.params.id);
      res.json({ success: true, data: boards });
    } catch (error) {
      next(error);
    }
  }

  async getById(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const board = await boardService.getById(req.params.id);
      res.json({ success: true, data: board });
    } catch (error) {
      next(error);
    }
  }

  async create(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { name } = req.body;
      const board = await boardService.create(req.params.id, name);
      res.status(201).json({ success: true, data: board });
    } catch (error) {
      next(error);
    }
  }

  async update(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { name } = req.body;
      const board = await boardService.update(req.params.id, name);
      res.json({ success: true, data: board });
    } catch (error) {
      next(error);
    }
  }

  async delete(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      await boardService.delete(req.params.id);
      res.json({ success: true, message: 'Board deleted' });
    } catch (error) {
      next(error);
    }
  }
}

export const boardController = new BoardController();
