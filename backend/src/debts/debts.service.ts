import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { TransactionsService } from '../transactions/transactions.service';
import { CreateDebtDto } from './dto/create-debt.dto';
import { PayDebtDto } from './dto/pay-debt.dto';

@Injectable()
export class DebtsService {
  constructor(
    private prisma: PrismaService,
    private transactionsService: TransactionsService,
  ) {}

  async findAll(userId: string) {
    const debts = await this.prisma.debt.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
    return debts.map((d) => ({
      ...d,
      lender: d.creditorName,
      provider: d.creditorName,
    }));
  }

  async create(userId: string, dto: CreateDebtDto) {
    const currency = dto.currency || 'USD';
    const debt = await this.prisma.debt.create({
      data: {
        userId,
        type: dto.type,
        creditorName: dto.creditorName,
        totalAmount: dto.amount,
        remainingAmount: dto.amount,
        currency,
      },
    });

    const user = await this.prisma.user.findUnique({ where: { id: userId } });

    await this.prisma.transaction.create({
      data: {
        userId,
        groupId: user?.groupId,
        type: 'income',
        amount: dto.amount,
        date: new Date(),
        currency,
        isRecurring: false,
        recurrenceInterval: 'none',
        isPinned: false,
        note: `Долг / кредит от: ${dto.creditorName} (${dto.type})`,
      }
    });

    return {
      ...debt,
      lender: debt.creditorName,
      provider: debt.creditorName,
    };
  }

  async pay(userId: string, id: string, dto: PayDebtDto) {
    const debt = await this.prisma.debt.findFirst({
      where: { id, userId },
    });

    if (!debt) {
      throw new NotFoundException('Debt not found');
    }

    if (Number(debt.remainingAmount) < dto.amount) {
      throw new BadRequestException('Payment amount exceeds remaining debt');
    }

    const updatedRemaining = Number(debt.remainingAmount) - dto.amount;

    const updatedDebt = await this.prisma.debt.update({
      where: { id },
      data: {
        remainingAmount: updatedRemaining,
      },
    });

    const user = await this.prisma.user.findUnique({ where: { id: userId } });

    await this.prisma.transaction.create({
      data: {
        userId,
        groupId: user?.groupId,
        type: 'expense',
        amount: dto.amount,
        date: new Date(),
        currency: debt.currency,
        isRecurring: false,
        recurrenceInterval: 'none',
        isPinned: false,
        note: `Погашение долга: ${debt.creditorName}`,
      }
    });

    return {
      ...updatedDebt,
      lender: updatedDebt.creditorName,
      provider: updatedDebt.creditorName,
    };
  }

  async delete(userId: string, id: string) {
    const debt = await this.prisma.debt.findFirst({
      where: { id, userId },
    });

    if (!debt) {
      throw new NotFoundException('Debt not found');
    }

    return this.prisma.debt.delete({
      where: { id },
    });
  }
}
