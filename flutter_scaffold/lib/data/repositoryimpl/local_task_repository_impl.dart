
import 'package:task_manager/data/services/shared_preference.dart';
import 'package:task_manager/domain/entities/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class LocalTaskRepositoryImpl implements TaskRepository {
  final SharedPreference sharedPreference;
  static const String _tasksKey = 'tasks';

  LocalTaskRepositoryImpl(this.sharedPreference);

  @override
  Future<List<Task>> getTasks() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final json = sharedPreference.getJson(_tasksKey);
    if (json == null) return [];
    
    final List<dynamic> jsonList = json as List;
    return jsonList.map((item) => Task(
      id: item['id'] ?? '',
      title: item['title'] ?? '',
      completed: item['completed'] ?? false,
    )).toList();
  }

  @override
  Future<Task> createTask(String title) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final tasks = await getTasks();
    final maxId = tasks.fold(0, (max, t) {
      final id = int.tryParse(t.id) ?? 0;
      return id > max ? id : max;
    });
    
    final task = Task(
      id: '${maxId + 1}',
      title: title,
      completed: false,
    );
    
    tasks.insert(0, task);
    _saveTasks(tasks);
    return task;
  }

  @override
  Future<Task> updateTask(String id, {String? title, bool? completed}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == id);
    if (index == -1) throw Exception('Task not found');
    
    final task = tasks[index];
    final updated = task.copyWith(
      title: title ?? task.title,
      completed: completed ?? task.completed,
    );
    
    tasks[index] = updated;
    _saveTasks(tasks);
    return updated;
  }

  @override
  Future<void> deleteTask(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == id);
    _saveTasks(tasks);
  }

  void _saveTasks(List<Task> tasks) {
    final jsonList = tasks.map((t) => ({
      'id': t.id,
      'title': t.title,
      'completed': t.completed,
    })).toList();
    sharedPreference.saveJson(_tasksKey, jsonList);
  }
}