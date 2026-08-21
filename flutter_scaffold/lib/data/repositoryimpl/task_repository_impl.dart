

import 'package:task_manager/data/dtos/task_dto.dart';
import 'package:task_manager/data/services/api_client.dart';
import 'package:task_manager/domain/entities/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final ApiClient apiClient;

  TaskRepositoryImpl(this.apiClient);

  @override
  Future<List<Task>> getTasks() async {
    try {
      final response = await apiClient.dio.get('/tasks');
      final List<dynamic> data = response.data['data'] ?? [];
      return data
          .map((json) => TaskDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Task> createTask(String title) async {
    try {
      final dto = CreateTaskDto(title: title);
      final response = await apiClient.dio.post(
        '/tasks',
        data: dto.toJson(),
      );
      return TaskDto.fromJson(response.data['data'] as Map<String, dynamic>).toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Task> updateTask(String id, {String? title, bool? completed}) async {
    try {
      final dto = UpdateTaskDto(title: title, completed: completed);
      final response = await apiClient.dio.put(
        '/tasks/$id',
        data: dto.toJson(),
      );
      return TaskDto.fromJson(response.data['data'] as Map<String, dynamic>).toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await apiClient.dio.delete('/tasks/$id');
    } catch (e) {
      rethrow;
    }
  }
}