import { IsIn, IsString } from 'class-validator';

export class CreateSubscriptionDto {
  @IsIn(['WEEKLY', 'MONTHLY'])
  cadence!: 'WEEKLY' | 'MONTHLY';

  @IsString()
  preferredWindow!: string;

  @IsString()
  startDate!: string;
}
