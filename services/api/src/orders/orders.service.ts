import {
  BadRequestException,
  Inject,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import {
  IDEMPOTENCY_REPO,
  IdempotencyRepo,
  ORDER_REPO,
  OrderRepo,
  WALLET_REPO,
  WalletRepo,
} from '../database/repositories/repository.contracts';
import { CreateOrderDto } from './dto/create-order.dto';
import { QuoteOrderDto } from './dto/quote-order.dto';
import { ExperienceService } from '../experience/experience.service';

@Injectable()
export class OrdersService {
  constructor(
    @Inject(ORDER_REPO) private readonly orderRepo: OrderRepo,
    @Inject(WALLET_REPO) private readonly walletRepo: WalletRepo,
    @Inject(IDEMPOTENCY_REPO)
    private readonly idempotencyRepo: IdempotencyRepo,
    private readonly experienceService: ExperienceService,
  ) {}

  async quote(userId: string, payload: QuoteOrderDto) {
    return await this.orderRepo.quote(userId, payload.useWallet ?? false);
  }

  async createOrder(userId: string, payload: CreateOrderDto, idempotencyKey?: string) {
    if (idempotencyKey) {
      const cached = await this.idempotencyRepo.get<unknown>(
        `orders:${userId}`,
        idempotencyKey,
      );
      if (cached) return cached;
    }

    const quote = await this.orderRepo.quote(userId, payload.useWallet ?? false);
    if (quote.amount <= 0) {
      throw new BadRequestException('Cart is empty. Add items before placing order');
    }

    const order = await this.orderRepo.createOrder({
      userId,
      type: payload.type,
      cityId: payload.cityId,
      zoneId: payload.zoneId,
      deliveryWindow: payload.deliveryWindow,
      payable: quote.payable,
    });

    if ((payload.useWallet ?? false) && quote.walletCredit > 0) {
      await this.walletRepo.addLedgerEntry({
        userId,
        type: 'ORDER_DEBIT',
        amount: -quote.walletCredit,
        description: `Wallet applied on ${order.id}`,
      });
    }

    const response = {
      ...order,
      paymentOrderId: payload.paymentOrderId,
      timeline: await this.orderRepo.getOrderTimeline(order.id),
    };

    if (idempotencyKey) {
      await this.idempotencyRepo.set(`orders:${userId}`, idempotencyKey, response);
    }

    return response;
  }

  async getOrder(id: string) {
    const order = await this.orderRepo.findOrderById(id);
    if (!order) {
      throw new NotFoundException(`Order ${id} not found`);
    }

    return {
      ...order,
      timeline: await this.orderRepo.getOrderTimeline(id),
    };
  }

  async getOrderTimeline(id: string) {
    const order = await this.orderRepo.findOrderById(id);
    if (!order) {
      throw new NotFoundException(`Order ${id} not found`);
    }

    return {
      orderId: id,
      timeline: await this.orderRepo.getOrderTimeline(id),
    };
  }

  async listOrders(input: {
    page: number;
    limit: number;
    status?:
      | 'CREATED'
      | 'CONFIRMED'
      | 'PREPARING'
      | 'OUT_FOR_DELIVERY'
      | 'DELIVERED'
      | 'CANCELLED';
    cityId?: string;
  }) {
    return await this.orderRepo.listOrders(input);
  }

  getReorderSuggestions(input: {
    userId: string;
    cityId?: string;
    window?: string;
  }) {
    return this.experienceService.getReorderSuggestions(input);
  }

  reorderOrder(orderId: string, userId: string) {
    return this.experienceService.reorderOrder(orderId, userId);
  }

  getLiveTracking(orderId: string) {
    return this.experienceService.getLiveTracking(orderId);
  }

  getEta(orderId: string) {
    return this.experienceService.getEta(orderId);
  }

  reportDelay(orderId: string, reason: string) {
    return this.experienceService.reportDelay(orderId, reason);
  }
}
