import { IsBoolean, IsOptional, IsString } from 'class-validator';

export class QuoteOrderDto {
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
