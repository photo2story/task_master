import 'task.dart';

class Project {
  final String id;
  final String name;
  final String category;
  final String subCategory;
  final String detail;
  final String description;
  final String manager;
  final String supervisor;
  final String procedure;
  final DateTime startDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.detail,
    required this.description,
    required this.manager,
    required this.supervisor,
    required this.procedure,
    required this.startDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
} 