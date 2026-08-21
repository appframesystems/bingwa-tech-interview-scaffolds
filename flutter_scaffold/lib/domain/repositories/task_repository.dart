
import 'package:task_manager/domain/entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks();
  Future<Task> createTask(String title);
  Future<Task> updateTask(String id, {String? title, bool? completed});
  Future<void> deleteTask(String id);
}