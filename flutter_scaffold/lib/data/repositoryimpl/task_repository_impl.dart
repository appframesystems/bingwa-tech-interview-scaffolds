import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../services/api_client.dart';
import '../dtos/task_dto.dart';

class TaskRepositoryImpl implements TaskRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<Task> createTask({
    required String title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
  }) async {
    final response = await _apiClient.post('/tasks', body: {
      'title': title,
      if (description != null && description.isNotEmpty) 'description': description,
      'priority': priority?.name ?? 'MEDIUM',
      'status': status?.name ?? 'TODO',
      if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
    });

    if (response != null && response['data'] != null) {
      return TaskDto.fromJson(response['data']).toDomain();
    }
    throw Exception('Failed to create task');
  }

  @override
  Future<({List<Task> tasks, int total, int page, int totalPages})> getTasks({
    TaskStatus? status,
    TaskPriority? priority,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) queryParams['status'] = status.name;
    if (priority != null) queryParams['priority'] = priority.name;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final response = await _apiClient.get('/tasks?$queryString');

    if (response != null && response['data'] != null) {
      final tasks = (response['data'] as List)
          .map((json) => TaskDto.fromJson(json).toDomain())
          .toList();

      final metaTotal = response['meta']?['total'];
      final metaPage = response['meta']?['page'];
      final metaTotalPages = response['meta']?['totalPages'];

      return (
        tasks: tasks,
        total: metaTotal is int ? metaTotal : tasks.length,
        page: metaPage is int ? metaPage : page,
        totalPages: metaTotalPages is int ? metaTotalPages : 1,
      );
    }
    throw Exception('Failed to get tasks');
  }

  @override
  Future<Task> getTask(String id) async {
    final response = await _apiClient.get('/tasks/$id');
    if (response != null && response['data'] != null) {
      return TaskDto.fromJson(response['data']).toDomain();
    }
    throw Exception('Failed to get task');
  }

  @override
  Future<Task> updateTask({
    required String id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? isArchived,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (status != null) body['status'] = status.name;
    if (priority != null) body['priority'] = priority.name;
    if (dueDate != null) body['dueDate'] = dueDate.toIso8601String();
    if (isArchived != null) body['isArchived'] = isArchived;

    final response = await _apiClient.patch('/tasks/$id', body: body);
    if (response != null && response['data'] != null) {
      return TaskDto.fromJson(response['data']).toDomain();
    }
    throw Exception('Failed to update task');
  }

  @override
  Future<Task> markTaskComplete(String id) async {
    final response = await _apiClient.patch('/tasks/$id/complete');
    if (response != null && response['data'] != null) {
      return TaskDto.fromJson(response['data']).toDomain();
    }
    throw Exception('Failed to mark task complete');
  }

  @override
  Future<void> deleteTask(String id) async {
    await _apiClient.delete('/tasks/$id');
  }

  @override
  Future<Task> restoreTask(String id) async {
    final response = await _apiClient.patch('/tasks/$id/restore');
    if (response != null && response['data'] != null) {
      return TaskDto.fromJson(response['data']).toDomain();
    }
    throw Exception('Failed to restore task');
  }

  @override
  Future<void> hardDeleteTask(String id) async {
    await _apiClient.delete('/tasks/$id/hard');
  }

  @override
  Future<Map<String, dynamic>> batchUpdateTasks({
    required List<String> taskIds,
    required Map<String, dynamic> updateData,
  }) async {
    final response = await _apiClient.post('/tasks/batch', body: {
      'taskIds': taskIds,
      'updateData': updateData,
    });

    if (response != null && response['data'] != null) {
      return response['data'];
    }
    throw Exception('Failed to update tasks');
  }

  @override
  Future<Map<String, dynamic>> getTaskStats() async {
    final response = await _apiClient.get('/tasks/stats/dashboard');
    if (response != null && response['data'] != null) {
      return response['data'];
    }
    throw Exception('Failed to get task stats');
  }

  @override
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    final response = await _apiClient.get('/tasks/status/${status.name}');
    if (response != null && response['data'] != null) {
      return (response['data'] as List)
          .map((json) => TaskDto.fromJson(json).toDomain())
          .toList();
    }
    throw Exception('Failed to get tasks by status');
  }
}