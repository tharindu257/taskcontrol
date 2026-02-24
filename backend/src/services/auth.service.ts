import prisma from '../config/database';
import { hashPassword, comparePassword } from '../utils/password';
import { signAccessToken, signRefreshToken, verifyRefreshToken } from '../utils/jwt';
import { ApiError } from '../utils/apiError';

export class AuthService {
  async register(data: { email: string; username: string; password: string; fullName?: string }) {
    const existingUser = await prisma.user.findFirst({
      where: { OR: [{ email: data.email }, { username: data.username }] },
    });

    if (existingUser) {
      if (existingUser.email === data.email) throw ApiError.conflict('Email already registered');
      throw ApiError.conflict('Username already taken');
    }

    const passwordHash = await hashPassword(data.password);

    const user = await prisma.user.create({
      data: {
        email: data.email,
        username: data.username,
        passwordHash,
        fullName: data.fullName,
      },
      select: { id: true, email: true, username: true, fullName: true, role: true, createdAt: true },
    });

    const tokens = await this.generateTokens(user.id, user.email);

    return { user, ...tokens };
  }

  async login(email: string, password: string) {
    const user = await prisma.user.findUnique({ where: { email } });

    if (!user || !user.isActive) {
      throw ApiError.unauthorized('Invalid email or password');
    }

    const isValid = await comparePassword(password, user.passwordHash);
    if (!isValid) {
      throw ApiError.unauthorized('Invalid email or password');
    }

    const tokens = await this.generateTokens(user.id, user.email);

    return {
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        fullName: user.fullName,
        avatar: user.avatar,
        role: user.role,
      },
      ...tokens,
    };
  }

  async refresh(refreshToken: string) {
    const stored = await prisma.refreshToken.findUnique({ where: { token: refreshToken } });

    if (!stored || stored.expiresAt < new Date()) {
      if (stored) await prisma.refreshToken.delete({ where: { id: stored.id } });
      throw ApiError.unauthorized('Invalid or expired refresh token');
    }

    let payload;
    try {
      payload = verifyRefreshToken(refreshToken);
    } catch {
      await prisma.refreshToken.delete({ where: { id: stored.id } });
      throw ApiError.unauthorized('Invalid refresh token');
    }

    // Delete old token and create new pair
    await prisma.refreshToken.delete({ where: { id: stored.id } });

    const tokens = await this.generateTokens(payload.userId, payload.email);
    return tokens;
  }

  async logout(refreshToken: string) {
    await prisma.refreshToken.deleteMany({ where: { token: refreshToken } });
  }

  async getMe(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        username: true,
        fullName: true,
        avatar: true,
        role: true,
        createdAt: true,
      },
    });

    if (!user) throw ApiError.notFound('User not found');
    return user;
  }

  private async generateTokens(userId: string, email: string) {
    const accessToken = signAccessToken({ userId, email });
    const refreshToken = signRefreshToken({ userId, email });

    // Store refresh token (expires in 7 days)
    await prisma.refreshToken.create({
      data: {
        token: refreshToken,
        userId,
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      },
    });

    return { accessToken, refreshToken };
  }
}

export const authService = new AuthService();
