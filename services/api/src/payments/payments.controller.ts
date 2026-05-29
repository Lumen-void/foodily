import {
  Body,
  Controller,
  Headers,
  Post,
  Req,
} from '@nestjs/common';
import { Request } from 'express';

import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Public } from '../common/decorators/public.decorator';
import { RequestUser } from '../common/interfaces/request-user.interface';
import { CreatePaymentOrderDto } from './dto/create-payment-order.dto';
import { RazorpayWebhookDto } from './dto/razorpay-webhook.dto';
import { PaymentsService } from './payments.service';

@Controller('payments')
export class PaymentsController {
  constructor(private readonly service: PaymentsService) {}

  @Post('create-order')
  createOrder(
    @CurrentUser() user: RequestUser,
    @Body() payload: CreatePaymentOrderDto,
    @Headers('idempotency-key') idempotencyKey?: string,
  ) {
    return this.service.createOrder(user.id, payload, idempotencyKey);
  }

  @Public()
  @Post('webhook/razorpay')
  webhook(
    @Body() payload: RazorpayWebhookDto,
    @Headers('x-razorpay-signature') signature?: string,
    @Req() request?: Request & { rawBody?: Buffer },
  ) {
    const rawBody = request?.rawBody?.toString('utf8');
    return this.service.processWebhook(payload, signature, rawBody);
  }
}
