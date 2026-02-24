import prisma from '../config/database';
import { ApiError } from '../utils/apiError';

export class LabelService {
  async listByProject(projectId: string) {
    return prisma.label.findMany({
      where: { projectId },
      orderBy: { name: 'asc' },
    });
  }

  async create(projectId: string, name: string, color: string) {
    const existing = await prisma.label.findUnique({
      where: { projectId_name: { projectId, name } },
    });
    if (existing) throw ApiError.conflict('Label with this name already exists in the project');

    return prisma.label.create({
      data: { projectId, name, color },
    });
  }

  async update(labelId: string, data: { name?: string; color?: string }) {
    const label = await prisma.label.findUnique({ where: { id: labelId } });
    if (!label) throw ApiError.notFound('Label not found');

    if (data.name && data.name !== label.name) {
      const existing = await prisma.label.findUnique({
        where: { projectId_name: { projectId: label.projectId, name: data.name } },
      });
      if (existing) throw ApiError.conflict('Label with this name already exists');
    }

    return prisma.label.update({
      where: { id: labelId },
      data,
    });
  }

  async delete(labelId: string) {
    const label = await prisma.label.findUnique({ where: { id: labelId } });
    if (!label) throw ApiError.notFound('Label not found');
    await prisma.label.delete({ where: { id: labelId } });
  }

  async addToTask(taskId: string, labelId: string) {
    return prisma.taskLabel.create({
      data: { taskId, labelId },
      include: { label: true },
    });
  }

  async removeFromTask(taskId: string, labelId: string) {
    await prisma.taskLabel.delete({
      where: { taskId_labelId: { taskId, labelId } },
    });
  }
}

export const labelService = new LabelService();
