import {
  Inject,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import {
  DISPATCH_REPO,
  DispatchRepo,
} from '../database/repositories/repository.contracts';
import { ExperienceService } from '../experience/experience.service';
import { UpdateJobStatusDto } from './dto/update-job-status.dto';

@Injectable()
export class DeliveryService {
  constructor(
    @Inject(DISPATCH_REPO) private readonly dispatchRepo: DispatchRepo,
    private readonly experienceService: ExperienceService,
  ) {}

  async listJobs(partnerId: string, status?:
      | 'CREATED'
      | 'CONFIRMED'
      | 'PREPARING'
      | 'OUT_FOR_DELIVERY'
      | 'DELIVERED'
      | 'CANCELLED') {
    return await this.dispatchRepo.listPartnerJobs(partnerId, status);
  }

  async updateStatus(jobId: string, payload: UpdateJobStatusDto) {
    const job = await this.dispatchRepo.updateJobStatus({
      jobId,
      status: payload.status,
      handoffCode: payload.handoffCode,
    });

    if (!job) {
      throw new NotFoundException(`Delivery job ${jobId} not found`);
    }

    return { updated: true, job };
  }

  locationPing(input: {
    orderId: string;
    partnerId: string;
    lat: number;
    lng: number;
  }) {
    return this.experienceService.locationPing(input);
  }
}
