import 'package:task_manager/data/services/api_client.dart';
import 'package:task_manager/models/task.dart';

class ApiService {
  final ApiClient _client = ApiClient();

  Future<List<Task>> getAllTasks() async {
    try {
      final response = await _client.get('/tasks');
      final data = response.data;
      final List<dynamic> tasksJson = data['data'] ?? [];
      return tasksJson.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<Task> createTask(String title) async {
    try {
      final response = await _client.post(
        '/tasks',
        data: {'title': title},
      );
      final data = response.data;
      return Task.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  Future<Task> updateTask(String id, {String? title, bool? completed}) async {
    try {
      final Map<String, dynamic> body = {};
      if (title != null) body['title'] = title;
      if (completed != null) body['completed'] = completed;

      final response = await _client.put(
        '/tasks/$id',
        data: body,
      );
      final data = response.data;
      return Task.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<Task> markTaskComplete(String id) async {
    return await updateTask(id, completed: true);
  }

  Future<void> deleteTask(String id) async {
    try {
      await _client.delete('/tasks/$id');
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}