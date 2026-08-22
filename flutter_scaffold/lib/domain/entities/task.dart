enum TaskStatus {
  TODO,
  IN_PROGRESS,
  COMPLETED,
}

enum TaskPriority {
  LOW,
  MEDIUM,
  HIGH,
}

class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final String userId;
  final DateTime? completedAt;
  final DateTime? deletedAt;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.status = TaskStatus.TODO,
    this.priority = TaskPriority.MEDIUM,
    this.dueDate,
    required this.userId,
    this.completedAt,
    this.deletedAt,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters
  bool get isComplete => status == TaskStatus.COMPLETED;
  bool get isOverdue =>
      dueDate != null && dueDate!.isBefore(DateTime.now()) && !isComplete;
  bool get isDeleted => deletedAt != null;

  // Copy with
  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    String? userId,
    DateTime? completedAt,
    DateTime? deletedAt,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      userId: userId ?? this.userId,
      completedAt: completedAt ?? this.completedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}