import { Test, TestingModule } from '@nestjs/testing';

import { DatabaseModule } from '../database/database.module';
import { ExperienceModule } from '../experience/experience.module';
import { OrdersService } from './orders.service';

describe('OrdersService', () => {
  let service: OrdersService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [DatabaseModule, ExperienceModule],
      providers: [OrdersService],
    }).compile();

    service = module.get<OrdersService>(OrdersService);
  });

  it('should validate quote output shape', async () => {
    const quote = await service.quote('u1', {
      cityId: 'gurgaon',
      zoneId: 'z1',
      deliveryWindow: '1:00 PM - 1:30 PM',
      useWallet: true,
    });

    expect(quote).toHaveProperty('payable');
    expect(quote).toHaveProperty('capacityValidated', true);
  });
});
