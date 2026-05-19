import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MailerModule } from '@nestjs-modules/mailer';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { SettingsModule } from './settings/settings.module';
import { CategoriesModule } from './categories/categories.module';
import { TransactionsModule } from './transactions/transactions.module';
import { GroupsModule } from './groups/groups.module';
import { DebtsModule } from './debts/debts.module';
import { AdminModule } from './admin/admin.module';
import { NotificationsModule } from './notifications/notifications.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    MailerModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        transport: {
          host: config.get('MAIL_HOST') || 'smtp.ethereal.email',
          port: config.get<number>('MAIL_PORT') || 587,
          auth: {
            user: config.get('MAIL_USER') || 'user',
            pass: config.get('MAIL_PASS') || 'pass',
          },
        },
        defaults: {
          from: config.get('MAIL_FROM') || '"Finance App" <noreply@financeapp.com>',
        },
      }),
    }),
    PrismaModule,
    AuthModule,
    SettingsModule,
    CategoriesModule,
    TransactionsModule,
    GroupsModule,
    DebtsModule,
    AdminModule,
    NotificationsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
