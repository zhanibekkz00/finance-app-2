import { IsString, IsInt, IsNumber, IsOptional } from 'class-validator';

export class CreateCategoryDto {
  @IsString()
  name: string;

  @IsNumber()
  colorValue: number;

  @IsInt()
  iconCode: number;

  @IsString()
  @IsOptional()
  imageUrl?: string;

  @IsString()
  @IsOptional()
  type?: string;
}
