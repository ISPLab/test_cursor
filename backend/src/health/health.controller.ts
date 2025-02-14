import { Controller, Get, Logger } from '@nestjs/common';

@Controller()
export class HealthController {
  private readonly logger = new Logger(HealthController.name);

  @Get('health')
  check() {
    this.logger.log('Health check requested');
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      service: 'backend'
    };
  }
} 