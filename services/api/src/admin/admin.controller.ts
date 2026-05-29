import {
  Body,
  Controller,
  Get,
  Post,
  Query,
} from '@nestjs/common';

import { Roles } from '../common/decorators/roles.decorator';
import { RolesEnum } from '../common/enums/roles.enum';
import { AssignDispatchDto } from './dto/assign-dispatch.dto';
import { AdminListQueryDto } from './dto/admin-list-query.dto';
import { AdminService } from './admin.service';

@Controller('admin')
@Roles(RolesEnum.ADMIN)
export class AdminController {
  constructor(private readonly service: AdminService) {}

  @Get('orders')
  getOrders(@Query() query: AdminListQueryDto) {
    return this.service.getOrders(query);
  }

  @Get('subscriptions')
  getSubscriptions(@Query() query: AdminListQueryDto) {
    return this.service.getSubscriptions(query);
  }

  @Get('dispatch/jobs')
  getDispatchJobs(@Query() query: AdminListQueryDto) {
    return this.service.getDispatchJobs(query);
  }

  @Get('metrics/overview')
  getOverviewMetrics(@Query() query: AdminListQueryDto) {
    return this.service.getOverviewMetrics(query);
  }

  @Get('payments')
  getPayments(@Query() query: AdminListQueryDto) {
    return this.service.getPayments(query);
  }

  @Post('dispatch/assign')
  assignDispatch(@Body() payload: AssignDispatchDto) {
    return this.service.assignDispatch(payload);
  }
}
