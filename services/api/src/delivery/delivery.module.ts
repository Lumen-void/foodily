import { Module } from '@nestjs/common';

import { DatabaseModule } from '../database/database.module';
import { ExperienceModule } from '../experience/experience.module';
import { DeliveryController } from './delivery.controller';
import { DeliveryService } from './delivery.service';

@Module({
  imports: [DatabaseModule, ExperienceModule],
  controllers: [DeliveryController],
  providers: [DeliveryService],
})
export class DeliveryModule {}
