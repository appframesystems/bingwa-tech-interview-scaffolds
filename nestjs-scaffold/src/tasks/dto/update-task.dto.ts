import { IsOptional, IsBoolean, IsString, MinLength, MaxLength } from 'class-validator';

export class UpdateTaskDto {
  @IsOptional()
  @IsBoolean()
  completed?: boolean;

  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(100)
  title?: string;
}
