import { Controller, Get, Query } from '@nestjs/common';

import { MenusService } from './menus.service';

@Controller('menus')
export class MenusController {
  constructor(private readonly service: MenusService) {}

  @Get('same-day')
  sameDay(
    @Query('cityId') cityId: string,
    @Query('slot') slot?: string,
  ) {
    return this.service.sameDayMenu(cityId, slot);
  }

  @Get('subscription')
  subscription(@Query('cityId') cityId: string) {
    return this.service.subscriptionMenu(cityId);
  }
}
