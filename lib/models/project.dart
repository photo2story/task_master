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
  final DateTime? endDate;
  final String status;
  final String manager;
  final String supervisor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? updateNotes;

  Project({
    required this.id,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.description,
    required this.detail,
    required this.procedure,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.manager,
    required this.supervisor,
    required this.createdAt,
    required this.updatedAt,
    this.updateNotes,
  });

  Project copyWith({
    String? id,
    String? name,
    String? category,
    String? subCategory,
    String? description,
    String? detail,
    String? procedure,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? manager,
    String? supervisor,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updateNotes,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      description: description ?? this.description,
      detail: detail ?? this.detail,
      procedure: procedure ?? this.procedure,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      manager: manager ?? this.manager,
      supervisor: supervisor ?? this.supervisor,
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

  factory Project.fromCsv(List<dynamic> row) {
    String sanitize(dynamic value) {
      return (value?.toString() ?? '').trim();
    }

    DateTime? parseDate(String value) {
      if (value.isEmpty) return null;
      try {
        return DateTime.parse(value.trim());
      } catch (e) {
        print('날짜 파싱 오류: $value');
        return null;
      }
    }

    return Project(
      id: sanitize(row[0]),
      name: sanitize(row[1]),
      category: sanitize(row[2]),
      subCategory: sanitize(row[3]),
      description: sanitize(row[4]),
      detail: sanitize(row[5]),
      procedure: sanitize(row[6]),
      startDate: parseDate(sanitize(row[7])) ?? DateTime.now(),
      endDate: parseDate(sanitize(row[8])),
      status: sanitize(row[9]),
      manager: sanitize(row[10]),
      supervisor: sanitize(row[11]),
      createdAt: parseDate(sanitize(row[12])) ?? DateTime.now(),
      updatedAt: parseDate(sanitize(row[13])) ?? DateTime.now(),
      updateNotes: row.length > 14 ? sanitize(row[14]) : null,
    );
  }

  List<String> toCsv() {
    return [
      id,
      name,
      category,
      subCategory,
      description,
      detail,
      procedure,
      startDate.toIso8601String(),
      endDate?.toIso8601String() ?? '',
      status,
      manager,
      supervisor,
      createdAt.toIso8601String(),
      updatedAt.toIso8601String(),
      updateNotes ?? '',
    ];
  }

  static int compareProjects(Project a, Project b) {
    int startDateCompare = b.startDate.compareTo(a.startDate);
    if (startDateCompare != 0) return startDateCompare;
    
    if (a.endDate == null && b.endDate != null) return -1;
    if (a.endDate != null && b.endDate == null) return 1;
    if (a.endDate != null && b.endDate != null) {
      int endDateCompare = b.endDate!.compareTo(a.endDate!);
      if (endDateCompare != 0) return endDateCompare;
    }
    
    Map<String, int> statusPriority = {
      '진행중': 0,
      '보류': 1,
      '완료': 2,
    };
    int statusA = statusPriority[a.status] ?? 3;
    int statusB = statusPriority[b.status] ?? 3;
    return statusA.compareTo(statusB);
  }
} 