import { IsString, IsNumber, IsInt, Min, Max } from 'class-validator';

export class UpsertBudgetDto {
  @IsString()
  categoryId: string;

  @IsNumber()
  amount: number;

  @IsInt()
  @Min(1)
  @Max(12)
  month: number;

  @IsInt()
  year: number;
}

export class CopyBudgetDto {
  @IsInt()
  @Min(1)
  @Max(12)
  fromMonth: number;

  @IsInt()
  fromYear: number;

  @IsInt()
  @Min(1)
  @Max(12)
  toMonth: number;

  @IsInt()
  toYear: number;
}
