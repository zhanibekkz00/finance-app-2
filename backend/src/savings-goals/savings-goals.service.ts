import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateSavingsGoalDto } from './dto/create-savings-goal.dto';

@Injectable()
export class SavingsGoalsService {
  constructor(private prisma: PrismaService) {}

  async findAll(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { groupId: true },
    });

    if (user?.groupId) {
      return this.prisma.savingsGoal.findMany({
        where: {
          user: {
            groupId: user.groupId,
          },
        },
        orderBy: { createdAt: 'desc' },
      });
    }

    return this.prisma.savingsGoal.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async create(userId: string, dto: CreateSavingsGoalDto) {
    const currency = dto.currency || 'USD';
    return this.prisma.savingsGoal.create({
      data: {
        userId,
        name: dto.name,
        targetAmount: dto.targetAmount,
        currentAmount: dto.currentAmount || 0,
        currency,
        targetDate: dto.targetDate ? new Date(dto.targetDate) : null,
        colorValue: dto.colorValue ? BigInt(dto.colorValue) : null,
      },
    });
  }

  async addMoney(userId: string, id: string, amount: number) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });

    let goal;
    if (user?.groupId) {
      goal = await this.prisma.savingsGoal.findFirst({
        where: {
          id,
          user: {
            groupId: user.groupId,
          },
        },
      });
    } else {
      goal = await this.prisma.savingsGoal.findFirst({
        where: { id, userId },
      });
    }

    if (!goal) {
      throw new NotFoundException('Savings goal not found');
    }

    const updatedGoal = await this.prisma.savingsGoal.update({
      where: { id },
      data: {
        currentAmount: Number(goal.currentAmount) + amount,
      },
    });

    await this.prisma.transaction.create({
      data: {
        userId,
        groupId: user?.groupId,
        type: 'expense',
        amount: amount,
        date: new Date(),
        currency: goal.currency,
        isRecurring: false,
        recurrenceInterval: 'none',
        isPinned: false,
        note: `Накопление: ${goal.name}`,
      },
    });

    return updatedGoal;
  }

  async update(userId: string, id: string, dto: any) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });

    let goal;
    if (user?.groupId) {
      goal = await this.prisma.savingsGoal.findFirst({
        where: {
          id,
          user: {
            groupId: user.groupId,
          },
        },
      });
    } else {
      goal = await this.prisma.savingsGoal.findFirst({
        where: { id, userId },
      });
    }

    if (!goal) {
      throw new NotFoundException('Savings goal not found');
    }

    const updateData: any = {};
    if (dto.name !== undefined) updateData.name = dto.name;
    if (dto.targetAmount !== undefined) updateData.targetAmount = dto.targetAmount;
    if (dto.currentAmount !== undefined) updateData.currentAmount = dto.currentAmount;
    if (dto.currency !== undefined) updateData.currency = dto.currency;
    if (dto.targetDate !== undefined) updateData.targetDate = dto.targetDate ? new Date(dto.targetDate) : null;
    if (dto.colorValue !== undefined) updateData.colorValue = dto.colorValue ? BigInt(dto.colorValue) : null;

    return this.prisma.savingsGoal.update({
      where: { id },
      data: updateData,
    });
  }

  async delete(userId: string, id: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });

    let goal;
    if (user?.groupId) {
      goal = await this.prisma.savingsGoal.findFirst({
        where: {
          id,
          user: {
            groupId: user.groupId,
          },
        },
      });
    } else {
      goal = await this.prisma.savingsGoal.findFirst({
        where: { id, userId },
      });
    }

    if (!goal) {
      throw new NotFoundException('Savings goal not found');
    }

    return this.prisma.savingsGoal.delete({
      where: { id },
    });
  }
}
