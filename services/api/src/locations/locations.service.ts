import { Inject, Injectable } from '@nestjs/common';

import {
  CATALOG_REPO,
  CatalogRepo,
} from '../database/repositories/repository.contracts';

@Injectable()
export class LocationsService {
  constructor(
    @Inject(CATALOG_REPO) private readonly catalogRepo: CatalogRepo,
  ) {}

  async getCities() {
    return await this.catalogRepo.listCities();
  }

  async getZones(cityId: string) {
    return await this.catalogRepo.listZones(cityId);
  }
}
