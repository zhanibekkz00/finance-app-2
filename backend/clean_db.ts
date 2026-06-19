import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import * as dotenv from 'dotenv';
import * as crypto from 'crypto';

dotenv.config();

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const adapter = new PrismaPg(pool as any);
const prisma = new PrismaClient({ adapter } as any);

async function main() {
  console.log('Cleaning up categories database...');

  // 1. Delete bad global default categories
  const badDefaults = await prisma.category.deleteMany({
    where: {
      isDefault: true,
      name: { in: ['Food', 'Transport', 'Salary'] }
    }
  });
  console.log(`Deleted ${badDefaults.count} bad global default categories.`);

  // 2. Fetch all users to fix their categories
  const users = await prisma.user.findMany({});
  for (const user of users) {
    console.log(`Processing user: ${user.email}`);
    const categories = await prisma.category.findMany({
      where: { userId: user.id }
    });

    const cleanCats: Record<string, any> = {};
    const defaultTemplates = [
      { id: '00000000-0000-0000-0000-000000000001', name: 'Еда', colorValue: BigInt(0xFFF44336), iconCode: 0xe25a, type: 'expense' },
      { id: '00000000-0000-0000-0000-000000000002', name: 'Развлечения', colorValue: BigInt(0xFF9C27B0), iconCode: 0xe338, type: 'expense' },
      { id: '00000000-0000-0000-0000-000000000003', name: 'Поездки', colorValue: BigInt(0xFF2196F3), iconCode: 0xe539, type: 'expense' },
      { id: '00000000-0000-0000-0000-000000000004', name: 'Зарплата', colorValue: BigInt(0xFF4CAF50), iconCode: 0xe263, type: 'income' },
    ];

    for (const defCat of defaultTemplates) {
      const hash = crypto.createHash('sha256').update(`${user.id}-${defCat.id}`).digest('hex');
      const deterministicId = `${hash.substring(0, 8)}-${hash.substring(8, 12)}-${hash.substring(12, 16)}-${hash.substring(16, 20)}-${hash.substring(20, 32)}`;
      
      cleanCats[defCat.name] = await prisma.category.upsert({
        where: { id: deterministicId },
        update: {},
        create: {
          id: deterministicId,
          name: defCat.name,
          colorValue: defCat.colorValue,
          iconCode: defCat.iconCode,
          type: defCat.type,
          userId: user.id,
          isDefault: false,
        }
      });
    }

    const mappings: Record<string, string> = {};

    for (const cat of categories) {
      if (cat.name === 'Еда' && cat.id !== cleanCats['Еда'].id) mappings[cat.id] = cleanCats['Еда'].id;
      if (cat.name === 'Развлечения' && cat.id !== cleanCats['Развлечения'].id) mappings[cat.id] = cleanCats['Развлечения'].id;
      if (cat.name === 'Поездки' && cat.id !== cleanCats['Поездки'].id) mappings[cat.id] = cleanCats['Поездки'].id;
      if (cat.name === 'Зарплата' && cat.id !== cleanCats['Зарплата'].id) mappings[cat.id] = cleanCats['Зарплата'].id;
      
      if (cat.name === 'Food') mappings[cat.id] = cleanCats['Еда'].id;
      if (cat.name === 'Transport') mappings[cat.id] = cleanCats['Поездки'].id;
      if (cat.name === 'Salary') mappings[cat.id] = cleanCats['Зарплата'].id;
    }

    // Update transactions/budgets to point to the clean ones
    for (const [oldId, newId] of Object.entries(mappings)) {
      await prisma.transaction.updateMany({
        where: { categoryId: oldId },
        data: { categoryId: newId }
      });
      await prisma.budget.updateMany({
        where: { categoryId: oldId },
        data: { categoryId: newId }
      });
      // Delete duplicate category
      await prisma.category.delete({
        where: { id: oldId }
      }).catch(() => {});
    }
  }

  console.log('Cleanup finished successfully.');
}

main().finally(() => prisma.$disconnect());
