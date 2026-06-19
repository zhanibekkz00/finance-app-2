import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import * as dotenv from 'dotenv';

dotenv.config();

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const adapter = new PrismaPg(pool as any);
const prisma = new PrismaClient({ adapter } as any);

async function main() {
  console.log('Seeding default categories...');

  const defaultCategories = [
    {
      id: '00000000-0000-0000-0000-000000000001',
      name: 'Еда',
      colorValue: BigInt(0xFFF44336),
      iconCode: 0xe25a,
      isDefault: true,
    },
    {
      id: '00000000-0000-0000-0000-000000000002',
      name: 'Развлечения',
      colorValue: BigInt(0xFF9C27B0),
      iconCode: 0xe338,
      isDefault: true,
    },
    {
      id: '00000000-0000-0000-0000-000000000003',
      name: 'Поездки',
      colorValue: BigInt(0xFF2196F3),
      iconCode: 0xe539,
      isDefault: true,
    },
    {
      id: '00000000-0000-0000-0000-000000000004',
      name: 'Зарплата',
      colorValue: BigInt(0xFF4CAF50),
      iconCode: 0xe263,
      isDefault: true,
    },
  ];

  for (const cat of defaultCategories) {
    await prisma.category.upsert({
      where: { id: cat.id },
      update: {},
      create: cat,
    });
  }

  console.log('Seeding finished.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
