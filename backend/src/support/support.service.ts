import { Injectable, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class SupportService {
  constructor(private prisma: PrismaService) {}

  async createSupportMessage(userId: string, email: string, message: string) {
    const supportMessage = await this.prisma.supportMessage.create({
      data: {
        userId,
        message,
      },
    });

    // Create notification for admins
    await this.prisma.notification.create({
      data: {
        title: 'Новое сообщение поддержки',
        body: `От ${email}: ${message.length > 60 ? message.substring(0, 60) + '...' : message}`,
        target: 'admin',
      },
    });

    return supportMessage;
  }

  async getSupportMessages(userRole: string) {
    if (userRole !== 'admin') {
      throw new ForbiddenException('Only admin can access support messages');
    }

    return this.prisma.supportMessage.findMany({
      include: {
        user: {
          select: {
            email: true,
            displayName: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async markAsRead(userRole: string, id: string) {
    if (userRole !== 'admin') {
      throw new ForbiddenException('Only admin can modify support messages');
    }

    return this.prisma.supportMessage.update({
      where: { id },
      data: { isRead: true },
    });
  }
}
