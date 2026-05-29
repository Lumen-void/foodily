import { Controller, Get } from '@nestjs/common';

import { CurrentUser } from '../common/decorators/current-user.decorator';
import { RequestUser } from '../common/interfaces/request-user.interface';
import { WalletService } from './wallet.service';

@Controller('wallet')
export class WalletController {
  constructor(private readonly service: WalletService) {}

  @Get()
  getWallet(@CurrentUser() user: RequestUser) {
    return this.service.getWallet(user.id);
  }
}
