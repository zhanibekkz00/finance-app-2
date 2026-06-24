import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpsertBudgetDto, CopyBudgetDto } from './dto/budget.dto';

@Injectable()
export class BudgetsService {
  constructor(private prisma: PrismaService) {}

  async getBudgets(userId: string, month: number, year: number) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    const userIds = user?.groupId
      ? (await this.prisma.user.findMany({ where: { groupId: user?.groupId }, select: { id: true } })).map((u) => u.id)
      : [userId];

    // 1. Get all budgets for the given month and year
    const budgets = await this.prisma.budget.findMany({
      where: {
        userId: { in: userIds },
        month,
        year,
      },
      include: { category: true },
    });

    // 2. Get the actual spendings for those categories in the same month and year
    // Note: JS Date month is 0-indexed, so month - 1
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 1); // 1st of next month

    const expenses = await this.prisma.transaction.groupBy({
      by: ['categoryId'],
      where: {
        userId: { in: userIds },
        type: 'expense',
        date: {
          gte: startDate,
          lt: endDate,
        },
      },
      _sum: {
        amount: true,
      },
    });

    const expensesMap = new Map<string, number>();
    for (const exp of expenses) {
      if (exp.categoryId) {
        expensesMap.set(exp.categoryId, Number(exp._sum.amount || 0));
      }
    }

    // 3. Map spent amounts to budgets
    return budgets.map((budget) => {
      const spent = expensesMap.get(budget.categoryId) || 0;
      return {
        ...budget,
        spentAmount: spent,
      };
    });
  }

  async upsertBudget(userId: string, dto: UpsertBudgetDto) {
    // Upsert budget (unique constraint is [userId, categoryId, month, year])
    const budget = await this.prisma.budget.upsert({
      where: {
        userId_categoryId_month_year: {
          userId,
          categoryId: dto.categoryId,
          month: dto.month,
          year: dto.year,
        },
      },
      update: {
        amount: dto.amount,
      },
      create: {
        userId,
        categoryId: dto.categoryId,
        amount: dto.amount,
        month: dto.month,
        year: dto.year,
      },
      include: { category: true },
    });

    return budget;
  }

  async deleteBudget(userId: string, id: string) {
    const budget = await this.prisma.budget.findUnique({ where: { id } });
    if (!budget || budget.userId !== userId) {
      throw new NotFoundException('Budget not found');
    }

    await this.prisma.budget.delete({ where: { id } });
    return { success: true };
  }

  async copyBudgets(userId: string, dto: CopyBudgetDto) {
    // Get budgets from previous month
    const previousBudgets = await this.prisma.budget.findMany({
      where: {
        userId,
        month: dto.fromMonth,
        year: dto.fromYear,
      },
    });

    if (previousBudgets.length === 0) {
      return [];
    }

    // Upsert them into the new month
    const results = [];
    for (const b of previousBudgets) {
      const budget = await this.prisma.budget.upsert({
        where: {
          userId_categoryId_month_year: {
            userId,
            categoryId: b.categoryId,
            month: dto.toMonth,
            year: dto.toYear,
          },
        },
        update: {
          // If a budget already exists for the new month, we don't necessarily want to overwrite it,
          // but if we call copy we can assume we want to overwrite. Let's overwrite:
          amount: b.amount,
        },
        create: {
          userId,
          categoryId: b.categoryId,
          amount: b.amount,
          month: dto.toMonth,
          year: dto.toYear,
        },
        include: { category: true },
      });
      results.push(budget);
    }
    return results;
  }
}
