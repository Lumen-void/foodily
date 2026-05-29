import { Inject, Injectable } from '@nestjs/common';

import {
  WALLET_REPO,
  WalletRepo,
} from '../database/repositories/repository.contracts';
import { ApplyReferralDto } from './dto/apply-referral.dto';

@Injectable()
export class ReferralsService {
  constructor(@Inject(WALLET_REPO) private readonly walletRepo: WalletRepo) {}

  async apply(userId: string, payload: ApplyReferralDto) {
    const normalized = payload.code.trim().toUpperCase();
    const credit = 100;

    await this.walletRepo.addLedgerEntry({
      userId,
      type: 'REFERRAL_CREDIT',
      amount: credit,
      description: `Referral ${normalized} applied`,
    });

    return {
      applied: true,
      credit,
      code: normalized,
      wallet: await this.walletRepo.getWallet(userId),
    };
  }
}
