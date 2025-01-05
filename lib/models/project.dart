import 'task.dart';

class Project {
  final String id;
  final String name;
  final String category;
  final String subCategory;
  final String description;
  final String detail;
  final String procedure;
  final DateTime startDate;
  final String status;
  final String manager;
  final String supervisor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String updateNotes;

  Project({
    required this.id,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.description,
    required this.detail,
    required this.procedure,
    required this.startDate,
    required this.status,
    required this.manager,
    required this.supervisor,
    required this.createdAt,
    required this.updatedAt,
    required this.updateNotes,
  });

  Project copyWith({
    String? id,
    String? name,
    String? category,
    String? subCategory,
    String? detail,
    String? description,
    String? manager,
    String? supervisor,
    String? procedure,
    DateTime? startDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updateNotes,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      detail: detail ?? this.detail,
      description: description ?? this.description,
      manager: manager ?? this.manager,
      supervisor: supervisor ?? this.supervisor,
      procedure: procedure ?? this.procedure,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updateNotes: updateNotes ?? this.updateNotes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'subCategory': subCategory,
    'description': description,
    'detail': detail,
    'procedure': procedure,
    'startDate': startDate.toIso8601String(),
    'status': status,
    'manager': manager,
    'supervisor': supervisor,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'updateNotes': updateNotes,
  };
} 