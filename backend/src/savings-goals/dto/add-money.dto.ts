import { IsNumber, IsPositive } from 'class-validator';

export class AddMoneyDto {
  @IsNumber()
  @IsPositive()
  amount: number;
}
