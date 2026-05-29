import { IsBoolean, IsIn, IsOptional, IsString } from 'class-validator';

export class CreateOrderDto {
  @IsIn(['ONE_TIME', 'SUBSCRIPTION'])
  type!: 'ONE_TIME' | 'SUBSCRIPTION';

  @IsString()
  paymentOrderId!: string;

  @IsString()
  cityId!: string;

  @IsString()
  zoneId!: string;

  @IsString()
  deliveryWindow!: string;

  @IsOptional()
  @IsBoolean()
  useWallet?: boolean;
}
