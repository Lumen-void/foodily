import { IsString, Length } from 'class-validator';

export class ApplyReferralDto {
  @IsString()
  @Length(4, 16)
  code!: string;
}
