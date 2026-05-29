import { Controller, Get, Query } from '@nestjs/common';

import { LocationsService } from './locations.service';

@Controller()
export class LocationsController {
  constructor(private readonly service: LocationsService) {}

  @Get('cities')
  getCities() {
    return this.service.getCities();
  }

  @Get('zones')
  getZones(@Query('cityId') cityId: string) {
    return this.service.getZones(cityId);
  }
}
