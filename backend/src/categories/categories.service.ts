import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateCategoryDto } from './dto/create-category.dto';
import * as crypto from 'crypto';

@Injectable()
export class CategoriesService {
  constructor(private prisma: PrismaService) {}

  async findAll(userId: string, includeDefault: boolean = true) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { groupId: true },
    });

    let userIds = [userId];
    if (user?.groupId) {
      const groupUsers = await this.prisma.user.findMany({
        where: { groupId: user.groupId },
        select: { id: true },
      });
      userIds = groupUsers.map((u) => u.id);
    }

    // 1. Fetch default categories
    const defaultCategories = await this.prisma.category.findMany({
      where: { isDefault: true },
    });

    // 2. Clone any missing default categories for this user/group context
    for (const defCat of defaultCategories) {
      // Generate deterministic UUID to prevent race conditions on concurrent requests
      const hash = crypto.createHash('sha256').update(`${userId}-${defCat.id}`).digest('hex');
      const deterministicId = `${hash.substring(0, 8)}-${hash.substring(8, 12)}-${hash.substring(12, 16)}-${hash.substring(16, 20)}-${hash.substring(20, 32)}`;

      await this.prisma.category.upsert({
        where: { id: deterministicId },
        update: {},
        create: {
          id: deterministicId,
          name: defCat.name,
          colorValue: defCat.colorValue,
          iconCode: defCat.iconCode,
          imageUrl: defCat.imageUrl,
          type: defCat.type,
          userId,
          isDefault: false,
        },
      });
    }

    // 3. Fetch all categories for user/group
    const userCategories = await this.prisma.category.findMany({
      where: { userId: { in: userIds } },
      orderBy: { name: 'asc' },
    });

    const uniqueCategories: any[] = [];
    const seen = new Set<string>();
    for (const cat of userCategories) {
      const key = `${cat.name.trim().toLowerCase()}_${cat.type}`;
      if (!seen.has(key)) {
        seen.add(key);
        uniqueCategories.push(cat);
      }
    }
    return uniqueCategories;
  }

  async create(userId: string, dto: CreateCategoryDto) {
    return this.prisma.category.create({
      data: {
        name: dto.name,
        colorValue: BigInt(dto.colorValue),
        iconCode: dto.iconCode,
        imageUrl: dto.imageUrl,
        type: dto.type || 'expense',
        userId,
        isDefault: false,
      },
    });
  }

  async update(userId: string, id: string, dto: any) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { groupId: true },
    });

    let userIds = [userId];
    if (user?.groupId) {
      const groupUsers = await this.prisma.user.findMany({
        where: { groupId: user.groupId },
        select: { id: true },
      });
      userIds = groupUsers.map((u) => u.id);
    }

    const category = await this.prisma.category.findFirst({
      where: { id, userId: { in: userIds } },
    });

    if (!category) {
      throw new Error('Category not found or not owned by user/group');
    }

    const updateData: any = {};
    if (dto.name !== undefined) updateData.name = dto.name;
    if (dto.colorValue !== undefined) updateData.colorValue = BigInt(dto.colorValue);
    if (dto.iconCode !== undefined) updateData.iconCode = dto.iconCode;
    if (dto.imageUrl !== undefined) updateData.imageUrl = dto.imageUrl;
    if (dto.type !== undefined) updateData.type = dto.type;

    return this.prisma.category.update({
      where: { id },
      data: updateData,
    });
  }

  async delete(userId: string, id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { groupId: true },
    });

    let userIds = [userId];
    if (user?.groupId) {
      const groupUsers = await this.prisma.user.findMany({
        where: { groupId: user.groupId },
        select: { id: true },
      });
      userIds = groupUsers.map((u) => u.id);
    }

    const category = await this.prisma.category.findFirst({
      where: { id, userId: { in: userIds } },
    });

    if (!category) {
      throw new Error('Category not found or not owned by user/group');
    }

    return this.prisma.category.delete({
      where: { id },
    });
  }
}
