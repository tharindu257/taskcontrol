import prisma from '../config/database';
import { ApiError } from '../utils/apiError';

export class CommentService {
  async listByTask(taskId: string) {
    return prisma.comment.findMany({
      where: { taskId },
      include: {
        author: { select: { id: true, username: true, fullName: true, avatar: true } },
      },
      orderBy: { createdAt: 'asc' },
    });
  }

  async create(taskId: string, content: string, userId: string) {
    const task = await prisma.task.findUnique({ where: { id: taskId } });
    if (!task) throw ApiError.notFound('Task not found');

    const comment = await prisma.$transaction(async (tx) => {
      const newComment = await tx.comment.create({
        data: { taskId, content, authorId: userId },
        include: {
          author: { select: { id: true, username: true, fullName: true, avatar: true } },
        },
      });

      await tx.activity.create({
        data: {
          taskId,
          userId,
          action: 'COMMENT_ADDED',
          changes: { commentId: newComment.id },
        },
      });

      return newComment;
    });

    return comment;
  }

  async update(commentId: string, content: string, userId: string) {
    const comment = await prisma.comment.findUnique({ where: { id: commentId } });
    if (!comment) throw ApiError.notFound('Comment not found');
    if (comment.authorId !== userId) throw ApiError.forbidden('You can only edit your own comments');

    return prisma.comment.update({
      where: { id: commentId },
      data: { content, edited: true },
      include: {
        author: { select: { id: true, username: true, fullName: true, avatar: true } },
      },
    });
  }

  async delete(commentId: string, userId: string) {
    const comment = await prisma.comment.findUnique({ where: { id: commentId } });
    if (!comment) throw ApiError.notFound('Comment not found');
    if (comment.authorId !== userId) throw ApiError.forbidden('You can only delete your own comments');

    await prisma.comment.delete({ where: { id: commentId } });
  }
}

export const commentService = new CommentService();
