import prisma from '../config/database';
import { ApiError } from '../utils/apiError';

export class BoardService {
  async listByProject(projectId: string) {
    return prisma.board.findMany({
      where: { projectId },
      orderBy: { createdAt: 'asc' },
    });
  }

  async getById(boardId: string) {
    const board = await prisma.board.findUnique({
      where: { id: boardId },
      include: {
        tasks: {
          include: {
            assignee: { select: { id: true, username: true, fullName: true, avatar: true } },
            creator: { select: { id: true, username: true, fullName: true, avatar: true } },
            labels: { include: { label: true } },
            _count: { select: { comments: true } },
          },
          orderBy: { position: 'asc' },
        },
      },
    });

    if (!board) throw ApiError.notFound('Board not found');
    return board;
  }

  async create(projectId: string, name: string) {
    return prisma.board.create({
      data: { projectId, name, type: 'KANBAN' },
    });
  }

  async update(boardId: string, name: string) {
    return prisma.board.update({
      where: { id: boardId },
      data: { name },
    });
  }

  async delete(boardId: string) {
    const board = await prisma.board.findUnique({
      where: { id: boardId },
      include: { _count: { select: { tasks: true } } },
    });
    if (!board) throw ApiError.notFound('Board not found');
    if (board._count.tasks > 0) {
      throw ApiError.badRequest('Cannot delete a board that has tasks. Move or delete tasks first.');
    }
    await prisma.board.delete({ where: { id: boardId } });
  }
}

export const boardService = new BoardService();
