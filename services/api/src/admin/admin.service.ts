import { Inject, Injectable } from '@nestjs/common';

import {
  DISPATCH_REPO,
  DispatchRepo,
  METRICS_REPO,
  MetricsRepo,
  ORDER_REPO,
  OrderRepo,
  PAYMENT_REPO,
  PaymentRepo,
  SUBSCRIPTION_REPO,
  SubscriptionRepo,
} from '../database/repositories/repository.contracts';
import { AssignDispatchDto } from './dto/assign-dispatch.dto';
import { AdminListQueryDto } from './dto/admin-list-query.dto';

@Injectable()
export class AdminService {
  constructor(
    @Inject(ORDER_REPO) private readonly orderRepo: OrderRepo,
    @Inject(SUBSCRIPTION_REPO)
    private readonly subscriptionRepo: SubscriptionRepo,
    @Inject(DISPATCH_REPO) private readonly dispatchRepo: DispatchRepo,
    @Inject(METRICS_REPO) private readonly metricsRepo: MetricsRepo,
    @Inject(PAYMENT_REPO) private readonly paymentRepo: PaymentRepo,
  ) {}

  async getOrders(query: AdminListQueryDto) {
    return await this.orderRepo.listOrders({
      page: query.page,
      limit: query.limit,
      status: query.status as
        | 'CREATED'
        | 'CONFIRMED'
        | 'PREPARING'
        | 'OUT_FOR_DELIVERY'
        | 'DELIVERED'
        | 'CANCELLED'
        | undefined,
      cityId: query.cityId,
      q: query.q,
      date: query.date,
    });
  }

  async getSubscriptions(query: AdminListQueryDto) {
    return await this.subscriptionRepo.list({
      page: query.page,
      limit: query.limit,
      status: query.status as 'ACTIVE' | 'PAUSED' | 'CANCELLED' | 'EXPIRED' | undefined,
      cadence: query.cadence,
      q: query.q,
      date: query.date,
    });
  }

  async getDispatchJobs(query: AdminListQueryDto) {
    return await this.dispatchRepo.listDispatchJobs({
      page: query.page,
      limit: query.limit,
      status: query.status as
        | 'CREATED'
        | 'CONFIRMED'
        | 'PREPARING'
        | 'OUT_FOR_DELIVERY'
        | 'DELIVERED'
        | 'CANCELLED'
        | undefined,
      cityId: query.cityId,
      partnerId: query.partnerId,
      q: query.q,
      date: query.date,
    });
  }

  async getOverviewMetrics(query: AdminListQueryDto) {
    return await this.metricsRepo.getOverview({
      cityId: query.cityId,
      q: query.q,
      date: query.date,
    });
  }

  async getPayments(query: AdminListQueryDto) {
    return await this.paymentRepo.listPayments({
      page: query.page,
      limit: query.limit,
      status: query.status as
        | 'INITIATED'
        | 'AUTHORIZED'
        | 'CAPTURED'
        | 'FAILED'
        | 'REFUNDED'
        | undefined,
      cityId: query.cityId,
      q: query.q,
      date: query.date,
    });
  }

  async assignDispatch(payload: AssignDispatchDto) {
    return await this.dispatchRepo.assignDispatch({
      orderId: payload.orderId,
      deliveryPartnerId: payload.deliveryPartnerId,
      cityId: payload.cityId,
    });
  }
}
