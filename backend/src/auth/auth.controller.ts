import { Controller, Post, Body, UnauthorizedException, Get } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('login')
  async login(@Body() loginData: { username: string; password: string }) {
    const user = await this.authService.validateUser(
      loginData.username,
      loginData.password,
    );
    if (!user) {
      throw new UnauthorizedException();
    }
    return this.authService.login(user);
  }

  @Get('health')
  health() {
    return { status: 'ok' };
  }
} 