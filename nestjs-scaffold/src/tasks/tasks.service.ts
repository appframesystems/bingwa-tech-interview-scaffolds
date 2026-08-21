import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Task, TaskDocument } from './schemas/task.schema';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { QueryTaskDto } from './dto/query-task.dto';
import { TaskStatus } from '../common/constants/enums';

@Injectable()
export class TasksService {
  constructor(
    @InjectModel(Task.name) private taskModel: Model<TaskDocument>,
  ) {}

  // Create a new task
  async create(userId: string, createTaskDto: CreateTaskDto): Promise<Task> {
    const task = new this.taskModel({
      ...createTaskDto,
      userId: new Types.ObjectId(userId),
      // If status is COMPLETED, set completedAt
      completedAt: createTaskDto.status === TaskStatus.COMPLETED ? new Date() : null,
    });

    await task.save();
    return task;
  }

  // Get all tasks for a user with filters and pagination
  async findAll(userId: string, queryDto: QueryTaskDto): Promise<{
    tasks: Task[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  }> {
    const { status, priority, isArchived, page = 1, limit = 10, search } = queryDto;

    // Build filter
    const filter: any = {
      userId: new Types.ObjectId(userId),
      deletedAt: null, // Exclude soft-deleted tasks
    };

    if (status) filter.status = status;
    if (priority) filter.priority = priority;
    if (isArchived !== undefined) filter.isArchived = isArchived;

    // Add search filter
    if (search) {
      filter.$or = [
        { title: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
      ];
    }

    // Calculate skip for pagination
    const skip = (page - 1) * limit;

    // Get total count for pagination
    const total = await this.taskModel.countDocuments(filter);

    // Get tasks with pagination
    const tasks = await this.taskModel
      .find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .exec();

    return {
      tasks,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  // Get a single task by ID
  async findOne(userId: string, taskId: string): Promise<Task> {
    const task = await this.taskModel.findOne({
      _id: new Types.ObjectId(taskId),
      userId: new Types.ObjectId(userId),
      deletedAt: null,
    });

    if (!task) {
      throw new NotFoundException(`Task with ID ${taskId} not found`);
    }

    return task;
  }

  // Update a task
  async update(
    userId: string,
    taskId: string,
    updateTaskDto: UpdateTaskDto,
  ): Promise<Task> {
    const task = await this.findOne(userId, taskId);

    // If status is being changed to COMPLETED, set completedAt
    if (updateTaskDto.status === TaskStatus.COMPLETED) {
      updateTaskDto['completedAt'] = new Date();
    }

    // If status is being changed from COMPLETED, remove completedAt
    if (task.status === TaskStatus.COMPLETED && updateTaskDto.status !== TaskStatus.COMPLETED) {
      updateTaskDto['completedAt'] = null;
    }

    const updatedTask = await this.taskModel
      .findOneAndUpdate(
        {
          _id: new Types.ObjectId(taskId),
          userId: new Types.ObjectId(userId),
          deletedAt: null,
        },
        { ...updateTaskDto },
        {
          new: true, // Return the updated document
          runValidators: true, // Run schema validators
        },
      )
      .exec();

    if (!updatedTask) {
      throw new NotFoundException(`Task with ID ${taskId} not found`);
    }

    return updatedTask;
  }

  // Mark task as complete (convenience method)
  async markComplete(userId: string, taskId: string): Promise<Task> {
    return this.update(userId, taskId, {
      status: TaskStatus.COMPLETED,
    });
  }

  // Soft delete a task
  async softDelete(userId: string, taskId: string): Promise<Task> {
    const task = await this.findOne(userId, taskId);

    const updatedTask = await this.taskModel
      .findOneAndUpdate(
        {
          _id: new Types.ObjectId(taskId),
          userId: new Types.ObjectId(userId),
        },
        {
          deletedAt: new Date(),
        },
        { new: true },
      )
      .exec();

    if (!updatedTask) {
      throw new NotFoundException(`Task with ID ${taskId} not found`);
    }

    return updatedTask;
  }

  // Hard delete a task (permanent)
  async hardDelete(userId: string, taskId: string): Promise<void> {
    const result = await this.taskModel
      .findOneAndDelete({
        _id: new Types.ObjectId(taskId),
        userId: new Types.ObjectId(userId),
      })
      .exec();

    if (!result) {
      throw new NotFoundException(`Task with ID ${taskId} not found`);
    }
  }

  // Restore a soft-deleted task
  async restore(userId: string, taskId: string): Promise<Task> {
    const task = await this.taskModel
      .findOneAndUpdate(
        {
          _id: new Types.ObjectId(taskId),
          userId: new Types.ObjectId(userId),
          deletedAt: { $ne: null },
        },
        {
          deletedAt: null,
        },
        { new: true },
      )
      .exec();

    if (!task) {
      throw new NotFoundException(
        `Deleted task with ID ${taskId} not found or already restored`,
      );
    }

    return task;
  }

  // Get task statistics for a user
  async getStats(userId: string): Promise<any> {
    const filter: any = {
      userId: new Types.ObjectId(userId),
      deletedAt: null,
    };

    const total = await this.taskModel.countDocuments(filter);
    const todo = await this.taskModel.countDocuments({
      ...filter,
      status: TaskStatus.TODO,
    });
    const inProgress = await this.taskModel.countDocuments({
      ...filter,
      status: TaskStatus.IN_PROGRESS,
    });
    const completed = await this.taskModel.countDocuments({
      ...filter,
      status: TaskStatus.COMPLETED,
    });

    const highPriority = await this.taskModel.countDocuments({
      ...filter,
      priority: 'HIGH',
    });

    const overdue = await this.taskModel.countDocuments({
      ...filter,
      dueDate: { $lt: new Date() },
      status: { $ne: TaskStatus.COMPLETED },
    });

    return {
      total,
      todo,
      inProgress,
      completed,
      highPriority,
      overdue,
      completionRate: total > 0 ? Math.round((completed / total) * 100) : 0,
    };
  }

  // Get tasks by status
  async findByStatus(userId: string, status: TaskStatus): Promise<Task[]> {
    return this.taskModel
      .find({
        userId: new Types.ObjectId(userId),
        status,
        deletedAt: null,
      })
      .sort({ createdAt: -1 })
      .exec();
  }

  // Batch update tasks (e.g., mark multiple as complete)
  async batchUpdate(
    userId: string,
    taskIds: string[],
    updateData: Partial<UpdateTaskDto>,
  ): Promise<any> {
    const objectIds = taskIds.map(id => new Types.ObjectId(id));

    // If status is COMPLETED, set completedAt for each
    if (updateData.status === TaskStatus.COMPLETED) {
      updateData['completedAt'] = new Date();
    }

    const result = await this.taskModel.updateMany(
      {
        _id: { $in: objectIds },
        userId: new Types.ObjectId(userId),
        deletedAt: null,
      },
      { ...updateData },
    );

    return {
      matchedCount: result.matchedCount,
      modifiedCount: result.modifiedCount,
    };
  }
}
