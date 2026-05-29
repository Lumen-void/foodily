import { Inject, Injectable, UnauthorizedException } from '@nestjs/common';
import { createHmac } from 'crypto';

import {
  IDEMPOTENCY_REPO,
  IdempotencyRepo,
  PAYMENT_REPO,
  PaymentRepo,
} from '../database/repositories/repository.contracts';
import { CreatePaymentOrderDto } from './dto/create-payment-order.dto';
import { RazorpayWebhookDto } from './dto/razorpay-webhook.dto';

@Injectable()
export class PaymentsService {
  constructor(
    @Inject(PAYMENT_REPO) private readonly paymentRepo: PaymentRepo,
    @Inject(IDEMPOTENCY_REPO)
    private readonly idempotencyRepo: IdempotencyRepo,
  ) {}

  async createOrder(
    userId: string,
    payload: CreatePaymentOrderDto,
    idempotencyKey?: string,
  ) {
    if (idempotencyKey) {
      const cached = await this.idempotencyRepo.get<unknown>(
        `payments:${userId}`,
        idempotencyKey,
      );
      if (cached) return cached;
    }

    const payment = await this.paymentRepo.createPaymentOrder({
      userId,
      amount: payload.amount,
      currency: payload.currency,
    });

    const response = {
      id: payment.id,
      amount: payload.amount,
      currency: payload.currency,
      provider: 'razorpay',
      keyId: process.env.RAZORPAY_KEY_ID ?? 'rzp_test_xxx',
      providerOrderId: `order_${payment.id}`,
    };

    if (idempotencyKey) {
      await this.idempotencyRepo.set(`payments:${userId}`, idempotencyKey, response);
    }

    return response;
  }

  async processWebhook(
    payload: RazorpayWebhookDto,
    signature?: string,
    rawBody?: string,
  ) {
    const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET;
    if (webhookSecret) {
      if (!signature) {
        throw new UnauthorizedException('Missing Razorpay webhook signature');
      }

      const expected = createHmac('sha256', webhookSecret)
        .update(rawBody ?? JSON.stringify(payload))
        .digest('hex');

      if (signature !== expected) {
        throw new UnauthorizedException('Invalid Razorpay webhook signature');
      }
    }

    const status = payload.event.includes('captured')
      ? 'CAPTURED'
      : payload.event.includes('authorized')
      ? 'AUTHORIZED'
      : 'FAILED';

    const payment = await this.paymentRepo.updatePaymentStatus({
      paymentId: payload.paymentId,
      orderId: payload.orderId,
      status,
      providerPaymentId: payload.paymentId,
    });

    if (!payment) {
      return { accepted: true, ignored: true };
    }

    await this.paymentRepo.addPaymentEvent({
      paymentId: payload.paymentId,
      orderId: payload.orderId,
      eventName: payload.event,
      payload: {
        event: payload.event,
        paymentId: payload.paymentId,
        orderId: payload.orderId,
      },
    });

    return {
      accepted: true,
      payment,
    };
  }
}
