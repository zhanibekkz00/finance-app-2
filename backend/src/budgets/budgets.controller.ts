import { Controller, Get, Post, Body, Delete, Param, Query, UseGuards, Request } from '@nestjs/common';
import { BudgetsService } from './budgets.service';
import { UpsertBudgetDto } from './dto/budget.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('budgets')
export class BudgetsController {
  constructor(private readonly budgetsService: BudgetsService) {}

  @Get()
  async getBudgets(@Request() req, @Query('month') monthStr: string, @Query('year') yearStr: string) {
    const month = parseInt(monthStr, 10);
    const year = parseInt(yearStr, 10);
    if (isNaN(month) || isNaN(year)) {
      return [];
    }
    return this.budgetsService.getBudgets(req.user.id, month, year);
  }

  @Post()
  async upsertBudget(@Request() req, @Body() dto: UpsertBudgetDto) {
    return this.budgetsService.upsertBudget(req.user.id, dto);
  }

  @Delete(':id')
  async deleteBudget(@Request() req, @Param('id') id: string) {
    return this.budgetsService.deleteBudget(req.user.id, id);
  }
}
