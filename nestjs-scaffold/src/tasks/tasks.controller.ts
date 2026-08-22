import {
  Controller,
  Get,
  Post,
  Patch,
  Param,
  Delete,
  Body,
  Query,
  HttpCode,
  HttpStatus,
  UseGuards,
  ValidationPipe,
  UsePipes,
} from '@nestjs/common';
import { TasksService } from './tasks.service';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { QueryTaskDto } from './dto/query-task.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../common/decorators/get-user.decorator';
import { TaskStatus } from '../common/constants/enums';

@Controller('tasks')
@UseGuards(JwtAuthGuard)
export class TasksController {
  constructor(private readonly tasksService: TasksService) {}

  // Create a new task
  @Post()
  @HttpCode(HttpStatus.CREATED)
  @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
  async create(@GetUser('id') userId: string, @Body() createTaskDto: CreateTaskDto) {
    const task = await this.tasksService.create(userId, createTaskDto);
    return {
      message: 'Task created successfully',
      data: task,
    };
  }

  // Get all tasks for authenticated user
  @Get()
  async findAll(@GetUser('id') userId: string, @Query() queryDto: QueryTaskDto) {
    const result = await this.tasksService.findAll(userId, queryDto);
    return {
      message: 'Tasks retrieved successfully',
      data: result.tasks,
      total: result.total,
      page: result.page,
      limit: result.limit,
      totalPages: result.totalPages,
    };
  }

  // Get task statistics
  @Get('stats/dashboard')
  async getStats(@GetUser('id') userId: string) {
    const stats = await this.tasksService.getStats(userId);
    return {
      message: 'Task statistics retrieved',
      data: stats,
    };
  }

  // Get task by ID
  @Get(':id')
  async findOne(@GetUser('id') userId: string, @Param('id') id: string) {
    const task = await this.tasksService.findOne(userId, id);
    return {
      message: 'Task retrieved successfully',
      data: task,
    };
  }

  // Update task
  @Patch(':id')
  async update(
    @GetUser('id') userId: string,
    @Param('id') id: string,
    @Body() updateTaskDto: UpdateTaskDto,
  ) {
    const task = await this.tasksService.update(userId, id, updateTaskDto);
    return {
      message: 'Task updated successfully',
      data: task,
    };
  }

  // Mark task as complete
  @Patch(':id/complete')
  async complete(@GetUser('id') userId: string, @Param('id') id: string) {
    const task = await this.tasksService.update(userId, id, { status: TaskStatus.COMPLETED });
    return {
      message: 'Task marked as complete',
      data: task,
    };
  }

  // Soft delete task
  @Delete(':id')
  async remove(@GetUser('id') userId: string, @Param('id') id: string) {
    const task = await this.tasksService.softDelete(userId, id);
    return {
      message: 'Task deleted successfully',
      data: task,
    };
  }

  // Restore soft-deleted task
  @Patch(':id/restore')
  async restore(@GetUser('id') userId: string, @Param('id') id: string) {
    const task = await this.tasksService.restore(userId, id);
    return {
      message: 'Task restored successfully',
      data: task,
    };
  }

  // Hard delete task (permanent)
  @Delete(':id/hard')
  @HttpCode(HttpStatus.NO_CONTENT)
  async hardDelete(@GetUser('id') userId: string, @Param('id') id: string) {
    await this.tasksService.hardDelete(userId, id);
  }

  // Batch update tasks
  @Post('batch')
  @HttpCode(HttpStatus.OK)
  async batchUpdate(
    @GetUser('id') userId: string,
    @Body() body: { taskIds: string[]; updates: Partial<UpdateTaskDto> },
  ) {
    const result = await this.tasksService.batchUpdate(userId, body.taskIds, body.updates);
    return {
      message: 'Batch update completed',
      data: result,
    };
  }

  // Get tasks by status
  @Get('status/:status')
  async findByStatus(@GetUser('id') userId: string, @Param('status') status: TaskStatus) {
    const tasks = await this.tasksService.findByStatus(userId, status);
    return {
      message: 'Tasks retrieved by status',
      data: tasks,
    };
  }
}
