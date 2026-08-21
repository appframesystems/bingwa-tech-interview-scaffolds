import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { CreateTaskDto } from './dto/create-task.dto';

export interface Task {
  id: string;
  title: string;
  completed: boolean;
  createdAt: Date;
}

@Injectable()
export class TasksService {
  private tasks: Task[] = [];
  private idCounter = 1;

  create(createTaskDto: CreateTaskDto): Task {
    if (!createTaskDto.title || createTaskDto.title.trim().length === 0) {
      throw new BadRequestException('Title is required and cannot be empty');
    }

    const task: Task = {
      id: String(this.idCounter++),
      title: createTaskDto.title.trim(),
      completed: false,
      createdAt: new Date(),
    };
    this.tasks.push(task);
    return task;
  }

  update(id: string, updates: Partial<Omit<Task, 'id' | 'createdAt'>>): Task {
    const taskIndex = this.tasks.findIndex(t => t.id === id);
    
    if (taskIndex === -1) {
      throw new NotFoundException(`Task with ID ${id} not found`);
    }

    const task = this.tasks[taskIndex];
    
    if (updates.completed !== undefined) {
      task.completed = updates.completed;
    }
    
    if (updates.title !== undefined) {
      task.title = updates.title.trim();
    }

    this.tasks[taskIndex] = task;
    return task;
  }

  // Optional: For testing and debugging
  findAll(): Task[] {
    return this.tasks;
  }

  findOne(id: string): Task {
    const task = this.tasks.find(t => t.id === id);
    if (!task) {
      throw new NotFoundException(`Task with ID ${id} not found`);
    }
    return task;
  }
}
