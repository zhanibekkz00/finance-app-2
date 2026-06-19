import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import * as dotenv from 'dotenv';

dotenv.config();

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const adapter = new PrismaPg(pool as any);
const prisma = new PrismaClient({ adapter } as any);

async function main() {
  const budgets = await prisma.budget.findMany({
    include: {
      category: true,
      user: true,
    }
  });

  console.log('--- ALL BUDGETS ---');
  budgets.forEach(b => {
    console.log(`ID: ${b.id}, User: ${b.user.email}, Category: ${b.category.name}, Amount: ${b.amount}, Month: ${b.month}, Year: ${b.year}`);
  });
}

main().finally(() => prisma.$disconnect());
