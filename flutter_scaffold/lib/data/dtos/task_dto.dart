

import 'package:task_manager/domain/entities/task.dart';

class TaskDto {
  final String id;
  final String title;
  final bool completed;

  TaskDto({
    required this.id,
    required this.title,
    required this.completed,
  });

  factory TaskDto.fromJson(Map<String, dynamic> json) {
    return TaskDto(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
    };
  }

  Task toDomain() {
    return Task(
      id: id,
      title: title,
      completed: completed,
    );
  }

  factory TaskDto.fromDomain(Task task) {
    return TaskDto(
      id: task.id,
      title: task.title,
      completed: task.completed,
    );
  }
}

class CreateTaskDto {
  final String title;

  CreateTaskDto({required this.title});

  Map<String, dynamic> toJson() {
    return {'title': title};
  }
}

class UpdateTaskDto {
  final String? title;
  final bool? completed;

  UpdateTaskDto({this.title, this.completed});

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (completed != null) 'completed': completed,
    };
  }
}