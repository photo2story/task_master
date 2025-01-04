import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../models/task_template.dart';
import 'database_service.dart';
import 'package:uuid/uuid.dart';

class ProjectService with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Project> _projects = [];

  List<Project> get projects => _projects;

  Future<void> loadProjects() async {
    try {
      // 임시 테스트 데이터
      _projects = [
        Project(
          id: '1',
          name: '인사_채용_신입공채',
          category: '인사',
          subCategory: '채용',
          detail: '신입공채',
          description: '신규가점 및 추가채용 등 진행',
          manager: '김민수',
          supervisor: '오석풍',
          procedure: '면접공고 → 서류전형 → 면접 → 추가선발 → 입사진행',
          startDate: DateTime.now(),
          status: '진행중',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      notifyListeners();
    } catch (e) {
      print('프로젝트 로드 에러: $e');
    }
  }

  Future<void> createProject(TaskTemplate template, DateTime startDate) async {
    try {
      // 프로젝트명 자동 생성: YYYYMMDD_구분_분류_상세
      String projectName = '${startDate.year}${startDate.month.toString().padLeft(2, '0')}${startDate.day.toString().padLeft(2, '0')}_${template.category}_${template.subCategory}_${template.detail}';
      
      final project = Project(
        id: const Uuid().v4(),
        name: projectName,
        category: template.category,
        subCategory: template.subCategory,
        detail: template.detail,
        description: template.description,
        manager: template.manager,
        supervisor: template.supervisor,
        procedure: template.procedure,
        startDate: startDate,
        status: '진행중',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('생성된 프로젝트 정보:');
      print('업무내용: ${project.description}');
      print('업무절차: ${project.procedure}');

      // 프로젝트 목록에 추가
      _projects = [..._projects, project];
      
      // 데이터베이스에 저장
      await DatabaseService().insertProject(project);
      
      // UI 갱신
      notifyListeners();
      
    } catch (e) {
      print('프로젝트 생성 에러: $e');
      rethrow;
    }
  }
} 