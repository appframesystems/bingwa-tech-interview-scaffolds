import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  HttpCode,
  HttpStatus,
  UseGuards,
  BadRequestException,
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
  async create(
    @GetUser('id') userId: string,
    @Body() createTaskDto: CreateTaskDto,
  ) {
    const task = await this.tasksService.create(userId, createTaskDto);
    return {
      message: 'Task created successfully',
      data: task,
    };
  }

  // Get all tasks with filtering and pagination
  @Get()
  async findAll(
    @GetUser('id') userId: string,
    @Query() queryDto: QueryTaskDto,
  ) {
    const result = await this.tasksService.findAll(userId, queryDto);
    return {
      message: 'Tasks retrieved successfully',
      data: result.tasks,
      meta: {
        total: result.total,
        page: result.page,
        limit: result.limit,
        totalPages: result.totalPages,
      },
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

  // Get tasks by status
  @Get('status/:status')
  async findByStatus(
    @GetUser('id') userId: string,
    @Param('status') status: TaskStatus,
  ) {
    if (!Object.values(TaskStatus).includes(status)) {
      throw new BadRequestException('Invalid status value');
    }
    const tasks = await this.tasksService.findByStatus(userId, status);
    return {
      message: `Tasks with status ${status} retrieved`,
      data: tasks,
    };
  }

  // Get a single task by ID
  @Get(':id')
  async findOne(
    @GetUser('id') userId: string,
    @Param('id') taskId: string,
  ) {
    const task = await this.tasksService.findOne(userId, taskId);
    return {
      message: 'Task retrieved successfully',
      data: task,
    };
  }

  // Update a task
  @Patch(':id')
  async update(
    @GetUser('id') userId: string,
    @Param('id') taskId: string,
    @Body() updateTaskDto: UpdateTaskDto,
  ) {
    const task = await this.tasksService.update(userId, taskId, updateTaskDto);
    return {
      message: 'Task updated successfully',
      data: task,
    };
  }

  // Mark task as complete
  @Patch(':id/complete')
  async markComplete(
    @GetUser('id') userId: string,
    @Param('id') taskId: string,
  ) {
    const task = await this.tasksService.markComplete(userId, taskId);
    return {
      message: 'Task marked as complete',
      data: task,
    };
  }

  // Batch update tasks
  @Post('batch')
  @HttpCode(HttpStatus.OK)
  async batchUpdate(
    @GetUser('id') userId: string,
    @Body() body: { taskIds: string[]; updateData: UpdateTaskDto },
  ) {
    if (!body.taskIds || body.taskIds.length === 0) {
      throw new BadRequestException('taskIds array is required');
    }
    const result = await this.tasksService.batchUpdate(
      userId,
      body.taskIds,
      body.updateData,
    );
    return {
      message: 'Tasks updated successfully',
      data: result,
    };
  }

  // Restore a soft-deleted task
  @Patch(':id/restore')
  async restore(
    @GetUser('id') userId: string,
    @Param('id') taskId: string,
  ) {
    const task = await this.tasksService.restore(userId, taskId);
    return {
      message: 'Task restored successfully',
      data: task,
    };
  }

  // Soft delete a task
  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  async softDelete(
    @GetUser('id') userId: string,
    @Param('id') taskId: string,
  ) {
    const task = await this.tasksService.softDelete(userId, taskId);
    return {
      message: 'Task deleted successfully (soft delete)',
      data: task,
    };
  }

  // Hard delete a task (permanent)
  @Delete(':id/hard')
  @HttpCode(HttpStatus.NO_CONTENT)
  async hardDelete(
    @GetUser('id') userId: string,
    @Param('id') taskId: string,
  ) {
    await this.tasksService.hardDelete(userId, taskId);
  }
}
