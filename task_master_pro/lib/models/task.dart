enum TaskPriority { high, medium, low }

class Task {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final DateTime dueDate;
  final String assignee;
  final TaskPriority priority;
  bool isCompleted;

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.assignee,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
  });
} 