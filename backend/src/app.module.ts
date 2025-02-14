import { Module } from '@nestjs/common';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { HealthController } from './health/health.controller';

@Module({
  imports: [AuthModule, UsersModule],
  controllers: [HealthController], // Регистрируем контроллер напрямую
})
export class AppModule {} 