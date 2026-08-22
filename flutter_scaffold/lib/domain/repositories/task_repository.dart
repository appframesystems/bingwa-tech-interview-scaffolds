import '../entities/task.dart';

abstract class TaskRepository {
  // Create task
  Future<Task> createTask({
    required String title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
  });

  // Get all tasks with filters
  Future<({List<Task> tasks, int total, int page, int totalPages})> getTasks({
    TaskStatus? status,
    TaskPriority? priority,
    int page = 1,
    int limit = 20,
    String? search,
  });

  // Get single task
  Future<Task> getTask(String id);

  // Update task
  Future<Task> updateTask({
    required String id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? isArchived,
  });

  // Mark task complete
  Future<Task> markTaskComplete(String id);

  // Delete task (soft delete)
  Future<void> deleteTask(String id);

  // Restore task
  Future<Task> restoreTask(String id);

  // Hard delete task
  Future<void> hardDeleteTask(String id);

  // Batch update tasks
  Future<Map<String, dynamic>> batchUpdateTasks({
    required List<String> taskIds,
    required Map<String, dynamic> updateData,
  });

  // Get task statistics
  Future<Map<String, dynamic>> getTaskStats();

  // Get tasks by status
  Future<List<Task>> getTasksByStatus(TaskStatus status);
}