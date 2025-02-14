import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  console.log('Starting NestJS application...');
  
  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn', 'log', 'debug', 'verbose'], // Включим все уровни логирования
  });
  
  app.enableCors();
  
  await app.listen(3000);
  
  // Получим все маршруты
  const server = app.getHttpServer();
  const router = server._events.request._router;
  
  console.log('\nRegistered routes:');
  router.stack.forEach(layer => {
    if (layer.route) {
      const path = layer.route?.path;
      const method = layer.route?.stack[0].method;
      console.log(`${method.toUpperCase()} ${path}`);
    }
  });
}

bootstrap().catch(error => {
  console.error('Failed to start server:', error);
  process.exit(1);
}); 