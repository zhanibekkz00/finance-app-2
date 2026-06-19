import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Body,
  UseGuards,
  Request,
} from '@nestjs/common';
import { SavingsGoalsService } from './savings-goals.service';
import { CreateSavingsGoalDto } from './dto/create-savings-goal.dto';
import { AddMoneyDto } from './dto/add-money.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('savings-goals')
@UseGuards(JwtAuthGuard)
export class SavingsGoalsController {
  constructor(private readonly service: SavingsGoalsService) {}

  @Get()
  async findAll(@Request() req) {
    return this.service.findAll(req.user.id);
  }

  @Post()
  async create(@Request() req, @Body() dto: CreateSavingsGoalDto) {
    return this.service.create(req.user.id, dto);
  }

  @Patch(':id/add-money')
  async addMoney(@Request() req, @Param('id') id: string, @Body() dto: AddMoneyDto) {
    return this.service.addMoney(req.user.id, id, dto.amount);
  }

  @Patch(':id')
  async update(@Request() req, @Param('id') id: string, @Body() dto: any) {
    return this.service.update(req.user.id, id, dto);
  }

  @Delete(':id')
  async delete(@Request() req, @Param('id') id: string) {
    return this.service.delete(req.user.id, id);
  }
}
