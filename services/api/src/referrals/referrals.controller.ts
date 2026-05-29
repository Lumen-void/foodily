import { Body, Controller, Post } from '@nestjs/common';

import { CurrentUser } from '../common/decorators/current-user.decorator';
import { RequestUser } from '../common/interfaces/request-user.interface';
import { ApplyReferralDto } from './dto/apply-referral.dto';
import { ReferralsService } from './referrals.service';

@Controller('referrals')
export class ReferralsController {
  constructor(private readonly service: ReferralsService) {}

  @Post('apply')
  apply(@CurrentUser() user: RequestUser, @Body() payload: ApplyReferralDto) {
    return this.service.apply(user.id, payload);
  }
}
