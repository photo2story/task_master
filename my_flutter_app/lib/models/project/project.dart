class Project {
  final String category;      // 구분
  final String classification;// 분류
  final String detail;       // 상세
  final String content;      // 업무내용
  final String manager;      // 담당
  final String supervisor;   // 관리
  final String procedure;    // 업무절차

  Project({
    required this.category,
    required this.classification,
    required this.detail,
    required this.content,
    required this.manager,
    required this.supervisor,
    required this.procedure,
  });

  // 프로젝트명 생성
  String get name => '$category-$classification-$detail';
} 