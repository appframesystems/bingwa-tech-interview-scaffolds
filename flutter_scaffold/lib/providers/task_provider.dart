import 'package:flutter/material.dart';
import 'package:task_manager/data/services/api_service.dart';
import 'package:task_manager/models/task.dart';

class TaskProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all tasks
  Future<void> loadTasks() async {
    _setLoading(true);
    _error = null;
    
    try {
      _tasks = await _apiService.getAllTasks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Add a new task
  Future<bool> addTask(String title) async {
    if (title.trim().isEmpty) {
      _error = 'Title cannot be empty';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _error = null;

    try {
      final newTask = await _apiService.createTask(title);
      _tasks.add(newTask);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Mark task as complete
  Future<bool> toggleTaskComplete(String id) async {
    _setLoading(true);
    _error = null;

    try {
      final updatedTask = await _apiService.markTaskComplete(id);
      
      // Update the task in the list
      final index = _tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a task (if you add delete endpoint)
  Future<bool> deleteTask(String id) async {
    // Implement if your backend supports DELETE
    // For now, just remove from local list
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
    return true;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}