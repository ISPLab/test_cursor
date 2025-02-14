import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors(); // Добавляем CORS для работы с фронтендом
  await app.listen(3000);
}
bootstrap(); 