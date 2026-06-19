import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import * as express from 'express';
import { join } from 'path';
import * as fs from 'fs';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Set a global prefix for all routes (e.g., /api/...)
  app.setGlobalPrefix('api');

  // Ensure public/uploads directory exists
  const uploadsDir = join(process.cwd(), 'public', 'uploads');
  if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
  }

  // Serve uploads folder statically with CORS headers
  app.use(
    '/uploads',
    express.static(uploadsDir, {
      setHeaders: (res) => {
        res.set('Access-Control-Allow-Origin', '*');
        res.set('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS');
      },
    }),
  );

  // BigInt and Decimal serialization fix
  (BigInt.prototype as any).toJSON = function () {
    return Number(this);
  };
  
  // Handle Decimal serialization for Prisma
  try {
    const { Decimal } = require('@prisma/client/runtime/library');
    if (Decimal) {
      (Decimal.prototype as any).toJSON = function () {
        return this.toNumber();
      };
    }
  } catch (e) {
    // Fallback or ignore
  }

  // Enable CORS for Flutter app
  app.enableCors({
    origin: true,
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    credentials: true,
  });
  
  const port = process.env.PORT || 3000;
  await app.listen(port, '0.0.0.0');
  console.log(`🚀 Backend running on http://localhost:${port}`);
}
bootstrap();
