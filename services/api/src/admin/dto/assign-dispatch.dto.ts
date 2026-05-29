import { IsString } from 'class-validator';

export class AssignDispatchDto {
  @IsString()
  orderId!: string;

  @IsString()
  deliveryPartnerId!: string;

  @IsString()
  cityId!: string;
}
