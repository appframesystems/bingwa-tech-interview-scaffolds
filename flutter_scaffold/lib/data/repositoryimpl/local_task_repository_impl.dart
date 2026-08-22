import 'package:task_manager/data/services/shared_preference.dart';
import 'package:task_manager/domain/entities/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class LocalTaskRepositoryImpl implements TaskRepository {
  final SharedPreferenceService sharedPreference;
  static const String _tasksKey = 'tasks';

  LocalTaskRepositoryImpl(this.sharedPreference);

  @override
  Future<({List<Task> tasks, int total, int page, int totalPages})> getTasks({
    TaskStatus? status,
    TaskPriority? priority,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final json = await sharedPreference.getJson(_tasksKey);
    if (json == null) return (tasks: <Task>[], total: 0, page: page, totalPages: 0);

    final List<dynamic> jsonList = json;
    var tasks = jsonList.map((item) => Task(
      id: item['id'] ?? '',
      title: item['title'] ?? '',
      description: item['description'] ?? '',
      status: TaskStatus.values.firstWhere(
        (s) => s.name == (item['status'] ?? 'TODO'),
        orElse: () => TaskStatus.TODO,
      ),
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == (item['priority'] ?? 'MEDIUM'),
        orElse: () => TaskPriority.MEDIUM,
      ),
      dueDate: item['dueDate'] != null ? DateTime.tryParse(item['dueDate']) : null,
      userId: item['userId'] ?? '',
      completedAt: item['completedAt'] != null ? DateTime.tryParse(item['completedAt']) : null,
      deletedAt: item['deletedAt'] != null ? DateTime.tryParse(item['deletedAt']) : null,
      isArchived: item['isArchived'] ?? false,
      createdAt: item['createdAt'] != null ? DateTime.parse(item['createdAt']) : DateTime.now(),
      updatedAt: item['updatedAt'] != null ? DateTime.parse(item['updatedAt']) : DateTime.now(),
    )).toList();

    if (status != null) {
      tasks = tasks.where((t) => t.status == status).toList();
    }
    if (priority != null) {
      tasks = tasks.where((t) => t.priority == priority).toList();
    }
    if (search != null && search.isNotEmpty) {
      tasks = tasks.where((t) => t.title.toLowerCase().contains(search.toLowerCase())).toList();
    }

    final total = tasks.length;
    final totalPages = total == 0 ? 0 : (total / limit).ceil();
    final start = (page - 1) * limit;
    final paginatedTasks = start >= total ? <Task>[] : tasks.sublist(start, start + limit > total ? total : start + limit);

    return (
      tasks: paginatedTasks,
      total: total,
      page: page,
      totalPages: totalPages,
    );
  }

  @override
  Future<Task> getTask(String id) async {
    final tasks = await getTasks();
    final task = tasks.tasks.firstWhere((t) => t.id == id, orElse: () => throw Exception('Task not found'));
    return task;
  }

  @override
  Future<Task> createTask({
    required String title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final tasks = await getTasks();
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description ?? '',
      status: status ?? TaskStatus.TODO,
      priority: priority ?? TaskPriority.MEDIUM,
      dueDate: dueDate,
      userId: 'local_user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final allTasks = [...tasks.tasks, newTask];
    _saveTasks(allTasks);
    return newTask;
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
    await Future.delayed(const Duration(milliseconds: 200));

    final tasks = await getTasks();
    final index = tasks.tasks.indexWhere((t) => t.id == id);
    if (index == -1) throw Exception('Task not found');

    final task = tasks.tasks[index];
    final updated = task.copyWith(
      title: title ?? task.title,
      description: description ?? task.description,
      status: status ?? task.status,
      priority: priority ?? task.priority,
      dueDate: dueDate ?? task.dueDate,
      isArchived: isArchived ?? task.isArchived,
      updatedAt: DateTime.now(),
    );

    final newTasks = List<Task>.from(tasks.tasks);
    newTasks[index] = updated;
    _saveTasks(newTasks);
    return updated;
  }

  @override
  Future<Task> markTaskComplete(String id) async {
    return updateTask(
      id: id,
      status: TaskStatus.COMPLETED,
      isArchived: false,
    );
  }

  @override
  Future<void> deleteTask(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final tasks = await getTasks();
    final updated = tasks.tasks.map((t) {
      if (t.id == id) {
        return t.copyWith(deletedAt: DateTime.now(), updatedAt: DateTime.now());
      }
      return t;
    }).toList();

    _saveTasks(updated);
  }

  @override
  Future<Task> restoreTask(String id) async {
    return updateTask(
      id: id,
      isArchived: false,
    );
  }

  @override
  Future<void> hardDeleteTask(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final tasks = await getTasks();
    final updated = tasks.tasks.where((t) => t.id != id).toList();
    _saveTasks(updated);
  }

  @override
  Future<Map<String, dynamic>> batchUpdateTasks({
    required List<String> taskIds,
    required Map<String, dynamic> updateData,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final tasks = await getTasks();
    final updated = tasks.tasks.map((t) {
      if (taskIds.contains(t.id)) {
        var task = t;
        if (updateData['status'] != null) {
          task = task.copyWith(status: TaskStatus.values.firstWhere(
            (s) => s.name == updateData['status'],
            orElse: () => task.status,
          ));
        }
        if (updateData['priority'] != null) {
          task = task.copyWith(priority: TaskPriority.values.firstWhere(
            (p) => p.name == updateData['priority'],
            orElse: () => task.priority,
          ));
        }
        if (updateData['isArchived'] != null) {
          task = task.copyWith(isArchived: updateData['isArchived']);
        }
        return task.copyWith(updatedAt: DateTime.now());
      }
      return t;
    }).toList();

    _saveTasks(updated);
    return {'updated': updated.length};
  }

  @override
  Future<Map<String, dynamic>> getTaskStats() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final tasks = await getTasks();
    final allTasks = tasks.tasks;

    final total = allTasks.length;
    final completed = allTasks.where((t) => t.status == TaskStatus.COMPLETED).length;
    final todo = allTasks.where((t) => t.status == TaskStatus.TODO).length;
    final inProgress = allTasks.where((t) => t.status == TaskStatus.IN_PROGRESS).length;
    final completionRate = total > 0 ? ((completed / total) * 100).round() : 0;

    final now = DateTime.now();
    final overdue = allTasks.where((t) =>
      t.dueDate != null &&
      t.dueDate!.isBefore(now) &&
      t.status != TaskStatus.COMPLETED
    ).length;

    return {
      'total': total,
      'completed': completed,
      'todo': todo,
      'inProgress': inProgress,
      'completionRate': completionRate,
      'overdue': overdue,
      'highPriority': allTasks.where((t) => t.priority == TaskPriority.HIGH).length,
    };
  }

  @override
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    final tasks = await getTasks();
    return tasks.tasks.where((t) => t.status == status).toList();
  }

  void _saveTasks(List<Task> tasks) {
    final jsonList = tasks.map((t) => ({
      'id': t.id,
      'title': t.title,
      'description': t.description,
      'status': t.status.name,
      'priority': t.priority.name,
      'dueDate': t.dueDate?.toIso8601String(),
      'userId': t.userId,
      'completedAt': t.completedAt?.toIso8601String(),
      'deletedAt': t.deletedAt?.toIso8601String(),
      'isArchived': t.isArchived,
      'createdAt': t.createdAt.toIso8601String(),
      'updatedAt': t.updatedAt.toIso8601String(),
    })).toList();
    sharedPreference.saveJson(_tasksKey, jsonList);
  }
}