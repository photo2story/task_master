class ProjectPhase {
  final String id;
  final String name;
  final int durationDays;
  final DateTime startDate;
  final String manager;      // 담당
  final String supervisor;   // 관리
  final List<String> tasks; // 세부 업무 목록

  DateTime get endDate => 
    startDate.add(Duration(days: durationDays));

  ProjectPhase({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.startDate,
    required this.manager,
    required this.supervisor,
    required this.tasks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'durationDays': durationDays,
      'startDate': startDate.toIso8601String(),
      'manager': manager,
      'supervisor': supervisor,
      'tasks': tasks,
    };
  }

  factory ProjectPhase.fromMap(Map<String, dynamic> map) {
    return ProjectPhase(
      id: map['id'],
      name: map['name'],
      durationDays: map['durationDays'],
      startDate: DateTime.parse(map['startDate']),
      manager: map['manager'],
      supervisor: map['supervisor'],
      tasks: List<String>.from(map['tasks']),
    );
  }
} 