import { IsInt, IsString, Min } from 'class-validator';

export class AddCartItemDto {
  @IsString()
  mealId!: string;

  @IsInt()
  @Min(1)
  qty!: number;
}
