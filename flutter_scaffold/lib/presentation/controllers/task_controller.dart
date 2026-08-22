// lib/presentation/controllers/task_controller.dart

import 'package:get/get.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../data/repositoryimpl/task_repository_impl.dart';
import '../controllers/auth_controller.dart';

class TaskController extends GetxController {
  final TaskRepository _taskRepository = TaskRepositoryImpl();
  final AuthController _authController = Get.find<AuthController>();

  // State
  final RxList<Task> tasks = <Task>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxInt totalTasks = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;

  // Filters
  final Rx<TaskStatus?> filterStatus = Rx<TaskStatus?>(null);
  final Rx<TaskPriority?> filterPriority = Rx<TaskPriority?>(null);
  final RxString searchQuery = ''.obs;

  // Statistics
  final RxMap<String, dynamic> stats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _authController.isAuthenticated.listen((authenticated) {
      if (authenticated) {
        loadTasks();
        loadStats();
      } else {
        tasks.clear();
        stats.clear();
      }
    });

    if (_authController.isAuthenticated.value) {
      loadTasks();
      loadStats();
    }
  }

  // Load tasks with filters
  Future<void> loadTasks({int page = 1}) async {
    isLoading.value = true;
    error.value = '';

    try {
      final result = await _taskRepository.getTasks(
        status: filterStatus.value,
        priority: filterPriority.value,
        page: page,
        limit: 20,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      tasks.value = result.tasks;
      totalTasks.value = result.total;
      currentPage.value = result.page;
      totalPages.value = result.totalPages;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Add task
  Future<bool> addTask({
    required String title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
  }) async {
    isLoading.value = true;
    error.value = '';

    try {
      final task = await _taskRepository.createTask(
        title: title,
        description: description,
        priority: priority,
        status: status,
        dueDate: dueDate,
      );
      tasks.insert(0, task);
      totalTasks.value++;
      await loadStats();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update task
  Future<bool> updateTask({
    required String id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? isArchived,
  }) async {
    isLoading.value = true;
    error.value = '';

    try {
      final updatedTask = await _taskRepository.updateTask(
        id: id,
        title: title,
        description: description,
        status: status,
        priority: priority,
        dueDate: dueDate,
        isArchived: isArchived,
      );

      final index = tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        tasks[index] = updatedTask;
        tasks.refresh();
      }
      await loadStats();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle task complete
  Future<bool> toggleTaskComplete(String id) async {
    isLoading.value = true;
    error.value = '';

    try {
      final task = tasks.firstWhereOrNull((t) => t.id == id);
      final newStatus = task != null && task.status == TaskStatus.COMPLETED
          ? TaskStatus.TODO
          : TaskStatus.COMPLETED;
      final updatedTask = await _taskRepository.updateTask(
        id: id,
        status: newStatus,
      );
      final index = tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        tasks[index] = updatedTask;
        tasks.refresh();
      }
      await loadStats();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete task
  Future<bool> deleteTask(String id) async {
    isLoading.value = true;
    error.value = '';

    try {
      await _taskRepository.deleteTask(id);
      tasks.removeWhere((task) => task.id == id);
      totalTasks.value--;
      await loadStats();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Restore task
  Future<bool> restoreTask(String id) async {
    isLoading.value = true;
    error.value = '';

    try {
      final task = await _taskRepository.restoreTask(id);
      final index = tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        tasks[index] = task;
        tasks.refresh();
      }
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Load statistics
  Future<void> loadStats() async {
    try {
      final result = await _taskRepository.getTaskStats();
      stats.value = result;
    } catch (e) {
      error.value = e.toString();
    }
  }

  // Set filters
  void setFilterStatus(TaskStatus? status) {
    filterStatus.value = status;
    loadTasks();
  }

  void setFilterPriority(TaskPriority? priority) {
    filterPriority.value = priority;
    loadTasks();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    loadTasks();
  }

  void clearFilters() {
    filterStatus.value = null;
    filterPriority.value = null;
    searchQuery.value = '';
    loadTasks();
  }

  // Pagination
  Future<void> nextPage() async {
    if (currentPage.value < totalPages.value) {
      await loadTasks(page: currentPage.value + 1);
    }
  }

  Future<void> previousPage() async {
    if (currentPage.value > 1) {
      await loadTasks(page: currentPage.value - 1);
    }
  }

  void clearError() {
    error.value = '';
  }

  // Get filtered tasks count
  int get totalCount => totalTasks.value;
  double get completionRate {
    if (totalTasks.value == 0) return 0;
    final completed = stats['completed'] ?? 0;
    return (completed / totalTasks.value) * 100;
  }
}