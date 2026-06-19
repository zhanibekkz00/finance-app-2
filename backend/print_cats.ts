import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import * as dotenv from 'dotenv';

dotenv.config();

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const adapter = new PrismaPg(pool as any);
const prisma = new PrismaClient({ adapter } as any);

async function main() {
  const cats = await prisma.category.findMany({});
  console.log('--- ALL CATEGORIES IN DB ---');
  for (const c of cats) {
    console.log(`ID: ${c.id}, Name: ${c.name}, isDefault: ${c.isDefault}, imageUrl: ${c.imageUrl}`);
  }
}

main().finally(() => prisma.$disconnect());
