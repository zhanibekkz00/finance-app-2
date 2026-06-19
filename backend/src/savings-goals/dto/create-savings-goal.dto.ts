import { IsNumber, IsOptional, IsPositive, IsString } from 'class-validator';

export class CreateSavingsGoalDto {
  @IsString()
  name: string;

  @IsNumber()
  @IsPositive()
  targetAmount: number;

  @IsNumber()
  @IsOptional()
  currentAmount?: number;

  @IsString()
  @IsOptional()
  currency?: string;

  @IsString()
  @IsOptional()
  targetDate?: string;

  @IsNumber()
  @IsOptional()
  colorValue?: number;
}
