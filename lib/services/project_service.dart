import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../models/task_template.dart';
import 'database_service.dart';
import 'package:uuid/uuid.dart';
import 'csv_service.dart';
import 'package:csv/csv.dart';

class ProjectService with ChangeNotifier {
  final CsvService _csvService;
  List<Project> _projects = [];
  bool _isLoading = false;

  ProjectService(this._csvService);

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;

  // 프로젝트 생성
  Future<void> createProject(Project project) async {
    try {
      // 메모리에 추가
      _projects = [..._projects, project];
      notifyListeners();

      // CSV 파일 업데이트
      await _csvService.updateProjectsCsv(_projects);
    } catch (e) {
      // 실패 시 롤백
      _projects.removeLast();
      notifyListeners();
      print('프로젝트 생성 에러: $e');
      rethrow;
    }
  }

  // 프로젝트 업데이트
  Future<void> updateProject(Project updatedProject) async {
    try {
      final index = _projects.indexWhere((p) => p.id == updatedProject.id);
      if (index != -1) {
        // 메모리 캐시 업데이트
        _projects[index] = updatedProject;
        notifyListeners();
        
        // CSV 파일 업데이트
        await _csvService.updateProjectsCsv(_projects);
      } else {
        throw Exception('업데이트할 프로젝트를 찾을 수 없습니다');
      }
    } catch (e) {
      print('프로젝트 업데이트 에러: $e');
      rethrow;
    }
  }

  // 프로젝트 삭제
  Future<void> deleteProject(String projectId) async {
    try {
      _projects.removeWhere((p) => p.id == projectId);
      notifyListeners();
      await _csvService.updateProjectsCsv(_projects);
    } catch (e) {
      print('프로젝트 삭제 에러: $e');
      rethrow;
    }
  }

  // 프로젝트 조회
  Future<Project> getProject(String id) async {
    try {
      // 메모리 캐시에서 프로젝트 찾기
      final project = _projects.firstWhere(
        (p) => p.id == id,
        orElse: () => throw Exception('프로젝트를 찾을 수 없습니다: $id'),
      );
      return project;
    } catch (e) {
      print('프로젝트 조회 에러: $e');
      // 프로젝트를 찾지 못한 경우 원본 프로젝트 반환
      return _projects.firstWhere((p) => p.id == id);
    }
  }

  // 프로젝트 목록 로드
  Future<void> loadProjects() async {
    if (_isLoading) return;
    
    try {
      _isLoading = true;
      notifyListeners();

      _projects = await _csvService.fetchProjects();
      
      // 날짜순 정렬
      _projects.sort((a, b) => a.startDate.compareTo(b.startDate));
      
      notifyListeners();
    } catch (e) {
      print('프로젝트 목록 로드 에러: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 