import { Body, Controller, Post } from '@nestjs/common';

import { Public } from '../common/decorators/public.decorator';
import { AuthService } from './auth.service';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { RequestOtpDto } from './dto/request-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @Post('request-otp')
  requestOtp(@Body() payload: RequestOtpDto) {
    return this.authService.requestOtp(payload);
  }

  @Public()
  @Post('verify-otp')
  verifyOtp(@Body() payload: VerifyOtpDto) {
    return this.authService.verifyOtp(payload);
  }

  @Public()
  @Post('refresh')
  refresh(@Body() payload: RefreshTokenDto) {
    return this.authService.refreshToken(payload);
  }
}
