
class Task {
  final String id;
  final String title;
  final bool completed;

  Task({
    required this.id,
    required this.title,
    this.completed = false,
  });

  Task copyWith({
    String? id,
    String? title,
    bool? completed,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }
}