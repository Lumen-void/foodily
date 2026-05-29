import { Inject, Injectable } from '@nestjs/common';

import {
  CATALOG_REPO,
  CatalogRepo,
} from '../database/repositories/repository.contracts';

@Injectable()
export class MenusService {
  constructor(
    @Inject(CATALOG_REPO) private readonly catalogRepo: CatalogRepo,
  ) {}

  async sameDayMenu(cityId: string, slot?: string) {
    return await this.catalogRepo.listMenus(cityId, slot);
  }

  async subscriptionMenu(cityId: string) {
    return await this.catalogRepo.listMenus(cityId);
  }
}
