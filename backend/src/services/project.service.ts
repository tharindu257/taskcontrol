import prisma from '../config/database';
import { ApiError } from '../utils/apiError';
import { MemberRole } from '@prisma/client';

export class ProjectService {
  async list(userId: string) {
    return prisma.project.findMany({
      where: {
        OR: [
          { ownerId: userId },
          { members: { some: { userId } } },
        ],
      },
      include: {
        owner: { select: { id: true, username: true, fullName: true, avatar: true } },
        _count: { select: { tasks: true, members: true } },
      },
      orderBy: { updatedAt: 'desc' },
    });
  }

  async getById(projectId: string, userId: string) {
    const project = await prisma.project.findUnique({
      where: { id: projectId },
      include: {
        owner: { select: { id: true, username: true, fullName: true, avatar: true } },
        members: {
          include: { user: { select: { id: true, username: true, fullName: true, avatar: true } } },
        },
        boards: true,
        _count: { select: { tasks: true } },
      },
    });

    if (!project) throw ApiError.notFound('Project not found');

    // Check access
    const isMember = project.ownerId === userId || project.members.some((m) => m.userId === userId);
    if (!isMember && project.visibility === 'PRIVATE') {
      throw ApiError.forbidden('You do not have access to this project');
    }

    return project;
  }

  async create(data: { name: string; key: string; description?: string; visibility?: 'PUBLIC' | 'PRIVATE' }, userId: string) {
    const existing = await prisma.project.findUnique({ where: { key: data.key } });
    if (existing) throw ApiError.conflict('Project key already exists');

    const project = await prisma.$transaction(async (tx) => {
      const proj = await tx.project.create({
        data: {
          name: data.name,
          key: data.key,
          description: data.description,
          visibility: data.visibility || 'PRIVATE',
          ownerId: userId,
        },
      });

      // Add owner as ADMIN member
      await tx.projectMember.create({
        data: { projectId: proj.id, userId, role: 'ADMIN' },
      });

      // Create default Kanban board
      await tx.board.create({
        data: { projectId: proj.id, name: 'Main Board', type: 'KANBAN' },
      });

      return proj;
    });

    return this.getById(project.id, userId);
  }

  async update(projectId: string, data: { name?: string; description?: string; visibility?: 'PUBLIC' | 'PRIVATE' }, userId: string) {
    await this.checkMemberRole(projectId, userId, ['ADMIN']);

    return prisma.project.update({
      where: { id: projectId },
      data,
      include: {
        owner: { select: { id: true, username: true, fullName: true, avatar: true } },
        _count: { select: { tasks: true, members: true } },
      },
    });
  }

  async delete(projectId: string, userId: string) {
    const project = await prisma.project.findUnique({ where: { id: projectId } });
    if (!project) throw ApiError.notFound('Project not found');
    if (project.ownerId !== userId) throw ApiError.forbidden('Only the owner can delete this project');

    await prisma.project.delete({ where: { id: projectId } });
  }

  async addMember(projectId: string, targetUserId: string, role: MemberRole, userId: string) {
    await this.checkMemberRole(projectId, userId, ['ADMIN']);

    const user = await prisma.user.findUnique({ where: { id: targetUserId } });
    if (!user) throw ApiError.notFound('User not found');

    const existing = await prisma.projectMember.findUnique({
      where: { projectId_userId: { projectId, userId: targetUserId } },
    });
    if (existing) throw ApiError.conflict('User is already a member');

    return prisma.projectMember.create({
      data: { projectId, userId: targetUserId, role: role || 'MEMBER' },
      include: { user: { select: { id: true, username: true, fullName: true, avatar: true } } },
    });
  }

  async removeMember(projectId: string, targetUserId: string, userId: string) {
    const project = await prisma.project.findUnique({ where: { id: projectId } });
    if (!project) throw ApiError.notFound('Project not found');
    if (project.ownerId === targetUserId) throw ApiError.badRequest('Cannot remove the project owner');

    await this.checkMemberRole(projectId, userId, ['ADMIN']);

    await prisma.projectMember.delete({
      where: { projectId_userId: { projectId, userId: targetUserId } },
    });
  }

  async getMembers(projectId: string) {
    return prisma.projectMember.findMany({
      where: { projectId },
      include: { user: { select: { id: true, username: true, fullName: true, avatar: true, email: true } } },
    });
  }

  private async checkMemberRole(projectId: string, userId: string, allowedRoles: MemberRole[]) {
    const project = await prisma.project.findUnique({ where: { id: projectId } });
    if (!project) throw ApiError.notFound('Project not found');

    // Owner always has access
    if (project.ownerId === userId) return;

    const member = await prisma.projectMember.findUnique({
      where: { projectId_userId: { projectId, userId } },
    });

    if (!member || !allowedRoles.includes(member.role)) {
      throw ApiError.forbidden('Insufficient permissions');
    }
  }
}

export const projectService = new ProjectService();
