import { Type } from 'class-transformer';
import { IsIn, IsInt, IsOptional, IsString, Max, Min } from 'class-validator';

export class AdminListQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit: number = 20;

  @IsOptional()
  @IsIn([
    'CREATED',
    'CONFIRMED',
    'PREPARING',
    'OUT_FOR_DELIVERY',
    'DELIVERED',
    'CANCELLED',
    'ACTIVE',
    'PAUSED',
    'EXPIRED',
    'INITIATED',
    'AUTHORIZED',
    'CAPTURED',
    'FAILED',
    'REFUNDED',
  ])
  status?:
    | 'CREATED'
    | 'CONFIRMED'
    | 'PREPARING'
    | 'OUT_FOR_DELIVERY'
    | 'DELIVERED'
    | 'CANCELLED'
    | 'ACTIVE'
    | 'PAUSED'
    | 'EXPIRED'
    | 'INITIATED'
    | 'AUTHORIZED'
    | 'CAPTURED'
    | 'FAILED'
    | 'REFUNDED';

  @IsOptional()
  @IsString()
  cityId?: string;

  @IsOptional()
  @IsString()
  q?: string;

  @IsOptional()
  @IsString()
  date?: string;

  @IsOptional()
  @IsIn(['WEEKLY', 'MONTHLY'])
  cadence?: 'WEEKLY' | 'MONTHLY';

  @IsOptional()
  @IsString()
  partnerId?: string;
}
