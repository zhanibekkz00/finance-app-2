import { Controller, Get, Post, Patch, Body, Param, UseGuards, Request } from '@nestjs/common';
import { SupportService } from './support.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('support')
export class SupportController {
  constructor(private supportService: SupportService) {}

  @Post()
  async create(@Request() req, @Body() body: { message: string }) {
    return this.supportService.createSupportMessage(
      req.user.id,
      req.user.email,
      body.message,
    );
  }

  @Get()
  async findAll(@Request() req) {
    return this.supportService.getSupportMessages(req.user.role);
  }

  @Patch(':id/read')
  async markAsRead(@Request() req, @Param('id') id: string) {
    return this.supportService.markAsRead(req.user.role, id);
  }
}
