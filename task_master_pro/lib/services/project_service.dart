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
      print('\n프로젝트 목록 로드 시도');
      // 서버에서 프로젝트 목록 가져오기
      _projects = await _databaseService.getProjects();
      print('로드된 프로젝트 수: ${_projects.length}');
      notifyListeners();
    } catch (e) {
      print('프로젝트 로드 에러: $e');
      rethrow;
    }
  }

  Future<void> createProject(TaskTemplate template, DateTime startDate) async {
    try {
      // 프로젝트명 자동 생성: YYYYMMDD_구분_분류_상세
      String projectName = '${startDate.year}${startDate.month.toString().padLeft(2, '0')}${startDate.day.toString().padLeft(2, '0')}_${template.category}_${template.subCategory}_${template.detail}';
      
      print('\n프로젝트 생성 정보:');
      print('프로젝트명: $projectName');
      print('업무절차: ${template.procedure}');

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

      print('\n생성된 프로젝트:');
      print('id: ${project.id}');
      print('name: ${project.name}');
      print('procedure: ${project.procedure}');

      // 프로젝트 목록에 추가
      _projects = [..._projects, project];
      
      // 데이터베이스에 저장
      await _databaseService.insertProject(project);
      
      // UI 갱신
      notifyListeners();
      
      print('\n프로젝트 저장 완료');
      
    } catch (e, stackTrace) {
      print('프로젝트 생성 에러: $e');
      print('스택 트레이스: $stackTrace');
      rethrow;
    }
  }

  // 프로젝트 수정
  Future<void> updateProject(Project project) async {
    try {
      await _databaseService.updateProject(project);
      
      // 로컬 목록 업데이트
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = project;
        notifyListeners();
      }
    } catch (e) {
      print('프로젝트 수정 에러: $e');
      rethrow;
    }
  }

  // 프로젝트 삭제
  Future<void> deleteProject(String projectId) async {
    try {
      await _databaseService.deleteProject(projectId);
      
      // 로컬 목록에서 제거
      _projects.removeWhere((p) => p.id == projectId);
      notifyListeners();
    } catch (e) {
      print('프로젝트 삭제 에러: $e');
      rethrow;
    }
  }
} 