import { Inject, Injectable } from '@nestjs/common';

import {
  WALLET_REPO,
  WalletRepo,
} from '../database/repositories/repository.contracts';

@Injectable()
export class WalletService {
  constructor(@Inject(WALLET_REPO) private readonly walletRepo: WalletRepo) {}

  async getWallet(userId: string) {
    return await this.walletRepo.getWallet(userId);
  }
}
