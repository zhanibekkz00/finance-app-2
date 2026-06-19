import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class NotificationsService {
  constructor(private prisma: PrismaService) {}

  async getNotifications(user: { id: string, role: string }) {
    const dbUser = await this.prisma.user.findUnique({
      where: { id: user.id },
      select: { createdAt: true },
    });

    if (!dbUser) {
      throw new Error('User not found');
    }

    const targets = ['all', user.id];
    if (user.role === 'admin') {
      targets.push('admin');
    }

    const notifications = await this.prisma.notification.findMany({
      where: {
        target: { in: targets },
        createdAt: { gte: dbUser.createdAt },
      },
      include: {
        reads: {
          where: { userId: user.id },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    return notifications.map((n) => ({
      id: n.id,
      title: n.title,
      body: n.body,
      createdAt: n.createdAt,
      isRead: n.reads.length > 0,
    }));
  }

  async markAsRead(userId: string, notificationId: string) {
    return this.prisma.notificationRead.upsert({
      where: {
        userId_notificationId: {
          userId,
          notificationId,
        },
      },
      update: {},
      create: {
        userId,
        notificationId,
      },
    });
  }

  async markAllAsRead(userId: string) {
    const dbUser = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { createdAt: true, role: true },
    });

    if (!dbUser) {
      throw new Error('User not found');
    }

    const targets = ['all'];
    if (dbUser.role === 'admin') {
      targets.push('admin');
    }

    const unreadNotifications = await this.prisma.notification.findMany({
      where: {
        target: { in: targets },
        createdAt: { gte: dbUser.createdAt },
        reads: {
          none: { userId },
        },
      },
      select: { id: true },
    });

    if (unreadNotifications.length === 0) {
      return { count: 0 };
    }

    const data = unreadNotifications.map((n) => ({
      userId,
      notificationId: n.id,
    }));

    return this.prisma.notificationRead.createMany({
      data,
      skipDuplicates: true,
    });
  }
}

