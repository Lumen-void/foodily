import { IsIn, IsString, MinLength } from 'class-validator';

export class UpdateJobStatusDto {
  @IsIn(['CONFIRMED', 'OUT_FOR_DELIVERY', 'DELIVERED'])
  status!: 'CONFIRMED' | 'OUT_FOR_DELIVERY' | 'DELIVERED';

  @IsString()
  @MinLength(4)
  handoffCode!: string;
}
