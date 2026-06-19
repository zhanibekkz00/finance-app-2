import { IsNumber, IsOptional, IsPositive, IsString } from 'class-validator';

export class CreateDebtDto {
  @IsString()
  type: string;

  @IsString()
  creditorName: string;

  @IsNumber()
  @IsPositive()
  amount: number;

  @IsString()
  @IsOptional()
  currency?: string;

  @IsString()
  @IsOptional()
  bankProduct?: string;

  @IsNumber()
  @IsOptional()
  annualRate?: number;

  @IsNumber()
  @IsOptional()
  termMonths?: number;

  @IsString()
  @IsOptional()
  startDate?: string;
}
