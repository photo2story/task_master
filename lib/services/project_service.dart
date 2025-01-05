import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../models/task_template.dart';
import 'database_service.dart';
import 'package:uuid/uuid.dart';

class ProjectService extends ChangeNotifier {
  final DatabaseService _databaseService;

  ProjectService(this._databaseService);

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

  Future<void> createProject(Project project) async {
    try {
      await _databaseService.insertProject(project);
      
      // 로컬 프로젝트 목록에도 추가
      _projects = [..._projects, project];
      
      // UI 갱신을 위해 알림
      notifyListeners();
    } catch (e) {
      print('프로젝트 생성 에러: $e');
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

  Future<Project> getProject(String projectId) async {
    try {
      return await _databaseService.getProject(projectId);
    } catch (e) {
      print('프로젝트 조회 에러: $e');
      rethrow;
    }
  }
} 