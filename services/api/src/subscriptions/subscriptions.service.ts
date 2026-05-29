import {
  Inject,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import {
  SUBSCRIPTION_REPO,
  SubscriptionRepo,
} from '../database/repositories/repository.contracts';
import { CreateSubscriptionDto } from './dto/create-subscription.dto';

@Injectable()
export class SubscriptionsService {
  constructor(
    @Inject(SUBSCRIPTION_REPO)
    private readonly subscriptionRepo: SubscriptionRepo,
  ) {}

  async create(userId: string, payload: CreateSubscriptionDto) {
    return await this.subscriptionRepo.create({
      userId,
      cadence: payload.cadence,
      preferredWindow: payload.preferredWindow,
      startDate: payload.startDate,
    });
  }

  async getById(id: string) {
    const subscription = await this.subscriptionRepo.findSubscriptionById(id);
    if (!subscription) {
      throw new NotFoundException(`Subscription ${id} not found`);
    }

    return subscription;
  }

  async pause(id: string) {
    const subscription = await this.subscriptionRepo.pause(id);
    if (!subscription) {
      throw new NotFoundException(`Subscription ${id} not found`);
    }

    return subscription;
  }

  async resume(id: string) {
    const subscription = await this.subscriptionRepo.resume(id);
    if (!subscription) {
      throw new NotFoundException(`Subscription ${id} not found`);
    }

    return subscription;
  }
}
