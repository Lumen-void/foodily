import { Module } from '@nestjs/common';

import { ExperienceAdminController, ExperienceController } from './experience.controller';
import { ExperienceService } from './experience.service';

@Module({
  controllers: [ExperienceController, ExperienceAdminController],
  providers: [ExperienceService],
  exports: [ExperienceService],
})
export class ExperienceModule {}
