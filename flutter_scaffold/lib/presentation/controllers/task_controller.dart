
import 'package:get/get.dart';
import 'package:task_manager/domain/entities/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class TaskController extends GetxController {
  final TaskRepository taskRepository = Get.find();

  final tasks = <Task>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;
  final newTaskTitle = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  void setNewTaskTitle(String value) {
    newTaskTitle.value = value;
  }

  Future<void> loadTasks() async {
    isLoading.value = true;
    error.value = '';

    try {
      tasks.value = await taskRepository.getTasks();
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar('Error', error.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTask() async {
    final title = newTaskTitle.value.trim();
    if (title.isEmpty) {
      Get.snackbar('Error', 'Please enter a task');
      return;
    }

    isLoading.value = true;

    try {
      final task = await taskRepository.createTask(title);
      tasks.insert(0, task);
      newTaskTitle.value = '';
      Get.snackbar('Success', 'Task added');
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar('Error', error.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleTask(String id) async {
    try {
      final task = tasks.firstWhere((t) => t.id == id);
      final updated = await taskRepository.updateTask(
        id,
        completed: !task.completed,
      );
      final index = tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        tasks[index] = updated;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update task');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await taskRepository.deleteTask(id);
      tasks.removeWhere((t) => t.id == id);
      Get.snackbar('Success', 'Task deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete task');
    }
  }
}