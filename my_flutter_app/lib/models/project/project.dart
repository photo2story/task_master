class Project {
  final String category;      // 구분
  final String classification;// 분류
  final String detail;       // 상세
  final String content;      // 업무내용
  final String manager;      // 담당
  final String supervisor;   // 관리
  final String procedure;    // 업무절차
  final String status;      // 상태 (추가)
  final String priority;    // 우선순위 (추가)

  Project({
    required this.category,
    required this.classification,
    required this.detail,
    required this.content,
    required this.manager,
    required this.supervisor,
    required this.procedure,
    this.status = '시작 전',
    this.priority = '중간',
  });

  factory Project.fromCsv(Map<String, dynamic> data) {
    return Project(
      category: data['구분'],
      classification: data['분류'],
      detail: data['상세'],
      content: data['업무내용'],
      manager: data['담당'],
      supervisor: data['관리'],
      procedure: data['업무절차'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'classification': classification,
      'detail': detail,
      'content': content,
      'manager': manager,
      'supervisor': supervisor,
      'procedure': procedure,
      'status': status,
      'priority': priority,
    };
  }

  // 프로젝트명 생성
  String get name => '$category-$classification-$detail';
} 