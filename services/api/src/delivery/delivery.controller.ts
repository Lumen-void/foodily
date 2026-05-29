import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
} from '@nestjs/common';

import { CurrentUser } from '../common/decorators/current-user.decorator';
import { RequestUser } from '../common/interfaces/request-user.interface';
import { UpdateJobStatusDto } from './dto/update-job-status.dto';
import { DeliveryService } from './delivery.service';

@Controller('delivery')
export class DeliveryController {
  constructor(private readonly service: DeliveryService) {}

  @Get('jobs')
  listJobs(
    @CurrentUser() user: RequestUser,
    @Query('status') status?:
      | 'CREATED'
      | 'CONFIRMED'
      | 'PREPARING'
      | 'OUT_FOR_DELIVERY'
      | 'DELIVERED'
      | 'CANCELLED',
  ) {
    return this.service.listJobs(user.id, status);
  }

  @Post('jobs/:id/status')
  updateStatus(@Param('id') id: string, @Body() payload: UpdateJobStatusDto) {
    return this.service.updateStatus(id, payload);
  }

  @Post('location-ping')
  locationPing(
    @CurrentUser() user: RequestUser,
    @Body() payload: { orderId: string; lat: number; lng: number },
  ) {
    return this.service.locationPing({
      orderId: payload.orderId,
      partnerId: user.id,
      lat: payload.lat,
      lng: payload.lng,
    });
  }
}
