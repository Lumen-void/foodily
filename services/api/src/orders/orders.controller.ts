import {
  Body,
  Controller,
  Get,
  Headers,
  Query,
  Param,
  Post,
} from '@nestjs/common';

import { CurrentUser } from '../common/decorators/current-user.decorator';
import { RequestUser } from '../common/interfaces/request-user.interface';
import { CreateOrderDto } from './dto/create-order.dto';
import { QuoteOrderDto } from './dto/quote-order.dto';
import { OrdersService } from './orders.service';

@Controller('orders')
export class OrdersController {
  constructor(private readonly service: OrdersService) {}

  @Get()
  list(
    @Query('page') page = '1',
    @Query('limit') limit = '20',
    @Query('status')
    status?:
      | 'CREATED'
      | 'CONFIRMED'
      | 'PREPARING'
      | 'OUT_FOR_DELIVERY'
      | 'DELIVERED'
      | 'CANCELLED',
    @Query('cityId') cityId?: string,
  ) {
    return this.service.listOrders({
      page: Number(page) || 1,
      limit: Number(limit) || 20,
      status,
      cityId,
    });
  }

  @Post('quote')
  quote(@CurrentUser() user: RequestUser, @Body() payload: QuoteOrderDto) {
    return this.service.quote(user.id, payload);
  }

  @Post()
  create(
    @CurrentUser() user: RequestUser,
    @Body() payload: CreateOrderDto,
    @Headers('idempotency-key') idempotencyKey?: string,
  ) {
    return this.service.createOrder(user.id, payload, idempotencyKey);
  }

  @Get('reorder-suggestions')
  reorderSuggestions(
    @CurrentUser() user: RequestUser,
    @Query('cityId') cityId?: string,
    @Query('window') window?: string,
  ) {
    return this.service.getReorderSuggestions({
      userId: user.id,
      cityId,
      window,
    });
  }

  @Post(':id/reorder')
  reorder(@CurrentUser() user: RequestUser, @Param('id') id: string) {
    return this.service.reorderOrder(id, user.id);
  }

  @Get(':id/live-tracking')
  liveTracking(@Param('id') id: string) {
    return this.service.getLiveTracking(id);
  }

  @Get(':id/eta')
  eta(@Param('id') id: string) {
    return this.service.getEta(id);
  }

  @Post(':id/delay-report')
  delayReport(@Param('id') id: string, @Body() payload: { reason: string }) {
    return this.service.reportDelay(id, payload.reason);
  }

  @Get(':id')
  getOrder(@Param('id') id: string) {
    return this.service.getOrder(id);
  }

  @Get(':id/timeline')
  getTimeline(@Param('id') id: string) {
    return this.service.getOrderTimeline(id);
  }
}
