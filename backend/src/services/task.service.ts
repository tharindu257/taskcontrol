import prisma from '../config/database';
import { ApiError } from '../utils/apiError';
import { TaskStatus, Priority, TaskType, ActivityType } from '@prisma/client';

interface TaskFilters {
  status?: TaskStatus;
  priority?: Priority;
  type?: TaskType;
  assigneeId?: string;
  search?: string;
}

export class TaskService {
  async listByProject(projectId: string, filters: TaskFilters = {}) {
    const where: any = { projectId };

    if (filters.status) where.status = filters.status;
    if (filters.priority) where.priority = filters.priority;
    if (filters.type) where.type = filters.type;
    if (filters.assigneeId) where.assigneeId = filters.assigneeId;
    if (filters.search) {
      where.OR = [
        { title: { contains: filters.search } },
        { key: { contains: filters.search } },
      ];
    }

    return prisma.task.findMany({
      where,
      include: {
        assignee: { select: { id: true, username: true, fullName: true, avatar: true } },
        creator: { select: { id: true, username: true, fullName: true, avatar: true } },
        labels: { include: { label: true } },
        _count: { select: { comments: true } },
      },
      orderBy: { position: 'asc' },
    });
  }

  async getById(taskId: string) {
    const task = await prisma.task.findUnique({
      where: { id: taskId },
      include: {
        assignee: { select: { id: true, username: true, fullName: true, avatar: true } },
        creator: { select: { id: true, username: true, fullName: true, avatar: true } },
        labels: { include: { label: true } },
        comments: {
          include: { author: { select: { id: true, username: true, fullName: true, avatar: true } } },
          orderBy: { createdAt: 'asc' },
        },
        activities: {
          include: { user: { select: { id: true, username: true, fullName: true, avatar: true } } },
          orderBy: { createdAt: 'desc' },
          take: 20,
        },
        _count: { select: { comments: true } },
      },
    });

    if (!task) throw ApiError.notFound('Task not found');
    return task;
  }

  async create(
    projectId: string,
    data: {
      title: string;
      description?: string;
      type?: TaskType;
      priority?: Priority;
      status?: TaskStatus;
      assigneeId?: string | null;
      boardId: string;
      dueDate?: string | null;
      labelIds?: string[];
    },
    userId: string
  ) {
    // Generate task key
    const project = await prisma.project.findUnique({ where: { id: projectId } });
    if (!project) throw ApiError.notFound('Project not found');

    const task = await prisma.$transaction(async (tx) => {
      // Increment task counter
      const updatedProject = await tx.project.update({
        where: { id: projectId },
        data: { taskCounter: { increment: 1 } },
      });

      const key = `${project.key}-${updatedProject.taskCounter}`;

      // Get max position for the status column
      const maxPosTask = await tx.task.findFirst({
        where: { boardId: data.boardId, status: data.status || 'TO_DO' },
        orderBy: { position: 'desc' },
      });
      const position = (maxPosTask?.position ?? -1) + 1;

      const newTask = await tx.task.create({
        data: {
          projectId,
          boardId: data.boardId,
          key,
          title: data.title,
          description: data.description,
          type: data.type || 'TASK',
          priority: data.priority || 'MEDIUM',
          status: data.status || 'TO_DO',
          assigneeId: data.assigneeId,
          creatorId: userId,
          dueDate: data.dueDate ? new Date(data.dueDate) : null,
          position,
        },
      });

      // Add labels
      if (data.labelIds && data.labelIds.length > 0) {
        await tx.taskLabel.createMany({
          data: data.labelIds.map((labelId) => ({ taskId: newTask.id, labelId })),
        });
      }

      // Log activity
      await tx.activity.create({
        data: {
          taskId: newTask.id,
          userId,
          action: 'CREATED',
          changes: { title: data.title },
        },
      });

      return newTask;
    });

    return this.getById(task.id);
  }

  async update(
    taskId: string,
    data: {
      title?: string;
      description?: string | null;
      type?: TaskType;
      priority?: Priority;
      status?: TaskStatus;
      assigneeId?: string | null;
      dueDate?: string | null;
      position?: number;
    },
    userId: string
  ) {
    const existing = await prisma.task.findUnique({ where: { id: taskId } });
    if (!existing) throw ApiError.notFound('Task not found');

    // Track changes for activity log
    const changes: Record<string, { from: any; to: any }> = {};
    if (data.status && data.status !== existing.status) changes.status = { from: existing.status, to: data.status };
    if (data.priority && data.priority !== existing.priority) changes.priority = { from: existing.priority, to: data.priority };
    if (data.assigneeId !== undefined && data.assigneeId !== existing.assigneeId) changes.assignee = { from: existing.assigneeId, to: data.assigneeId };

    const task = await prisma.$transaction(async (tx) => {
      const updated = await tx.task.update({
        where: { id: taskId },
        data: {
          ...(data.title !== undefined && { title: data.title }),
          ...(data.description !== undefined && { description: data.description }),
          ...(data.type !== undefined && { type: data.type }),
          ...(data.priority !== undefined && { priority: data.priority }),
          ...(data.status !== undefined && { status: data.status }),
          ...(data.assigneeId !== undefined && { assigneeId: data.assigneeId }),
          ...(data.dueDate !== undefined && { dueDate: data.dueDate ? new Date(data.dueDate) : null }),
          ...(data.position !== undefined && { position: data.position }),
        },
      });

      // Log activities
      if (changes.status) {
        await tx.activity.create({
          data: { taskId, userId, action: 'STATUS_CHANGED', changes: changes.status },
        });
      }
      if (changes.priority) {
        await tx.activity.create({
          data: { taskId, userId, action: 'PRIORITY_CHANGED', changes: changes.priority },
        });
      }
      if (changes.assignee) {
        await tx.activity.create({
          data: { taskId, userId, action: 'ASSIGNEE_CHANGED', changes: changes.assignee },
        });
      }
      if (data.title || data.description !== undefined) {
        await tx.activity.create({
          data: { taskId, userId, action: 'TASK_EDITED', changes: { fields: Object.keys(data) } },
        });
      }

      return updated;
    });

    return this.getById(task.id);
  }

  async updateStatus(taskId: string, status: TaskStatus, userId: string) {
    return this.update(taskId, { status }, userId);
  }

  async moveTask(taskId: string, data: { status?: TaskStatus; position: number }, userId: string) {
    return this.update(taskId, data, userId);
  }

  async delete(taskId: string) {
    const task = await prisma.task.findUnique({ where: { id: taskId } });
    if (!task) throw ApiError.notFound('Task not found');
    await prisma.task.delete({ where: { id: taskId } });
  }
}

export const taskService = new TaskService();
