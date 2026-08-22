import '../../domain/entities/task.dart';

class TaskDto {
  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? dueDate;
  final String userId;
  final String? completedAt;
  final String? deletedAt;
  final bool isArchived;
  final String createdAt;
  final String updatedAt;

  TaskDto({
    required this.id,
    required this.title,
    this.description = '',
    required this.status,
    required this.priority,
    this.dueDate,
    required this.userId,
    this.completedAt,
    this.deletedAt,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskDto.fromJson(Map<String, dynamic> json) {
    return TaskDto(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'TODO',
      priority: json['priority'] ?? 'MEDIUM',
      dueDate: json['dueDate'],
      userId: json['userId'] ?? '',
      completedAt: json['completedAt'],
      deletedAt: json['deletedAt'],
      isArchived: json['isArchived'] ?? false,
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      if (dueDate != null) 'dueDate': dueDate,
    };
  }

  Task toDomain() {
    return Task(
      id: id,
      title: title,
      description: description,
      status: _parseStatus(status),
      priority: _parsePriority(priority),
      dueDate: dueDate != null ? DateTime.parse(dueDate!) : null,
      userId: userId,
      completedAt: completedAt != null ? DateTime.parse(completedAt!) : null,
      deletedAt: deletedAt != null ? DateTime.parse(deletedAt!) : null,
      isArchived: isArchived,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  static TaskStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'IN_PROGRESS':
        return TaskStatus.IN_PROGRESS;
      case 'COMPLETED':
        return TaskStatus.COMPLETED;
      default:
        return TaskStatus.TODO;
    }
  }

  static TaskPriority _parsePriority(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return TaskPriority.HIGH;
      case 'MEDIUM':
        return TaskPriority.MEDIUM;
      default:
        return TaskPriority.LOW;
    }
  }
}