import { Module } from '@nestjs/common';

import { DatabaseModule } from '../database/database.module';
import { MenusController } from './menus.controller';
import { MenusService } from './menus.service';

@Module({
  imports: [DatabaseModule],
  controllers: [MenusController],
  providers: [MenusService],
})
export class MenusModule {}
