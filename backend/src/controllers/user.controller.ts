import { Request, Response, NextFunction } from 'express';
import prisma from '../config/database';
import { AuthRequest } from '../types';

export class UserController {
  async search(req: Request, res: Response, next: NextFunction) {
    try {
      const { q } = req.query;
      if (!q || typeof q !== 'string') {
        res.json({ success: true, data: [] });
        return;
      }

      const users = await prisma.user.findMany({
        where: {
          OR: [
            { username: { contains: q } },
            { fullName: { contains: q } },
            { email: { contains: q } },
          ],
          isActive: true,
        },
        select: { id: true, username: true, fullName: true, avatar: true, email: true },
        take: 20,
      });

      res.json({ success: true, data: users });
    } catch (error) {
      next(error);
    }
  }

  async getProfile(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const user = await prisma.user.findUnique({
        where: { id: req.params.id as string },
        select: { id: true, username: true, fullName: true, avatar: true, createdAt: true },
      });

      if (!user) {
        res.status(404).json({ success: false, message: 'User not found' });
        return;
      }

      res.json({ success: true, data: user });
    } catch (error) {
      next(error);
    }
  }

  async updateProfile(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { fullName, avatar } = req.body;
      const user = await prisma.user.update({
        where: { id: req.user!.userId },
        data: { ...(fullName !== undefined && { fullName }), ...(avatar !== undefined && { avatar }) },
        select: { id: true, username: true, email: true, fullName: true, avatar: true, role: true },
      });

      res.json({ success: true, data: user });
    } catch (error) {
      next(error);
    }
  }
}

export const userController = new UserController();
