class TaskTemplate {
  final String category;
  final String subCategory;
  final String detail;
  final String description;
  final String manager;
  final String supervisor;
  final String procedure;

  TaskTemplate({
    required this.category,
    required this.subCategory,
    required this.detail,
    required this.description,
    required this.manager,
    required this.supervisor,
    required this.procedure,
  });

  @override
  String toString() {
    return 'TaskTemplate('
        'category: $category, '
        'subCategory: $subCategory, '
        'detail: $detail, '
        'description: $description, '
        'manager: $manager, '
        'supervisor: $supervisor, '
        'procedure: $procedure)';
  }

  TaskTemplate copyWith({
    String? category,
    String? subCategory,
    String? detail,
    String? description,
    String? manager,
    String? supervisor,
    String? procedure,
  }) {
    return TaskTemplate(
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      detail: detail ?? this.detail,
      description: description ?? this.description,
      manager: manager ?? this.manager,
      supervisor: supervisor ?? this.supervisor,
      procedure: procedure ?? this.procedure,
    );
  }
} 