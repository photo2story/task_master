// @dart=2.17
// ignore_for_file: constant_identifier_names

enum ProjectCategory {
  humanResource('인사'),
  payroll('급여'),
  recruitment('채용'),
  training('교육'),
  performance('성과관리'),
  other('기타');

  final String label;
  const ProjectCategory(this.label);
}

enum ProjectStatus {
  notStarted('시작 전'),
  inProgress('진행 중'),
  completed('완료'),
  onHold('보류'),
  cancelled('취소');

  final String label;
  const ProjectStatus(this.label);
}

enum ProjectPriority {
  low('낮음'),
  medium('중간'),
  high('높음'),
  urgent('긴급');

  final String label;
  const ProjectPriority(this.label);
} 