import { IsString } from 'class-validator';

export class RazorpayWebhookDto {
  @IsString()
  event!: string;

  @IsString()
  paymentId!: string;

  @IsString()
  orderId!: string;
}
