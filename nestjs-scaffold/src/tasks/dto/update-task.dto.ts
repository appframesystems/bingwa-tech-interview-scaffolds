import { IsOptional, IsBoolean, IsString, MinLength, MaxLength, IsEnum } from 'class-validator';
import { TaskStatus, TaskPriority } from '../../common/constants/enums';

export class UpdateTaskDto {
  @IsOptional()
  @IsBoolean()
  completed?: boolean;

  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(100)
  title?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;

  @IsOptional()
  @IsEnum(TaskStatus, { message: 'Invalid status' })
  status?: TaskStatus;

  @IsOptional()
  @IsEnum(TaskPriority, { message: 'Invalid priority' })
  priority?: TaskPriority;

  @IsOptional()
  dueDate?: Date;
}
