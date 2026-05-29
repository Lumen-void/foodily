import { IsString, Length } from 'class-validator';

export class VerifyOtpDto {
  @IsString()
  @Length(10, 15)
  phone!: string;

  @IsString()
  @Length(4, 6)
  otp!: string;
}
