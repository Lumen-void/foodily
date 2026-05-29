import { Module } from '@nestjs/common';

import { DatabaseModule } from '../database/database.module';
import { ExperienceModule } from '../experience/experience.module';
import { OrdersController } from './orders.controller';
import { OrdersService } from './orders.service';

@Module({
  imports: [DatabaseModule, ExperienceModule],
  controllers: [OrdersController],
  providers: [OrdersService],
  exports: [OrdersService],
})
export class OrdersModule {}
