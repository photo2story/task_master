import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../models/task_template.dart';
import 'database_service.dart';
import 'package:uuid/uuid.dart';
import 'csv_service.dart';
import 'package:csv/csv.dart';

class ProjectService extends ChangeNotifier {
  final CsvService _csvService;
  List<Project> _projects = [];
  List<Project> _cachedProjects = [];
  bool _isSyncing = false;

  ProjectService(this._csvService);

  List<Project> get projects {
    if (_isSyncing) {
      return _cachedProjects;
    }
    // 캐시가 비어있으면 현재 프로젝트 목록으로 초기화
    if (_cachedProjects.isEmpty) {
      _cachedProjects = [..._projects];
    }
    return _projects;
  }

  bool get isSyncing => _isSyncing;

  Future<void> loadProjects() async {
    try {
      final projects = await _csvService.fetchProjects();
      
      // 날짜순으로 정렬 (startDate 기준)
      projects.sort((a, b) => a.startDate.compareTo(b.startDate));
      
      _projects = projects;
      _cachedProjects = [...projects];  // 캐시 초기화 추가
      notifyListeners();
    } catch (e) {
      print('프로젝트 로드 에러: $e');
      rethrow;
    }
  }

  Future<void> createProject(Project project) async {
    try {
      // 1. 캐시에 즉시 추가하고 UI 업데이트
      _cachedProjects = [..._projects, project];  // 기존 프로젝트 + 새 프로젝트
      _isSyncing = true;
      notifyListeners();

      // 2. GitHub에 비동기로 저장
      await _syncToGitHub(() async {
        _projects = [..._projects, project];
        final success = await _csvService.updateProjectsCsv(_projects);
        if (!success) throw Exception('프로젝트 저장 실패');
      });

    } catch (e) {
      // 3. 실패 시 캐시 롤백
      _cachedProjects = [..._projects];
      _isSyncing = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      // 1. 캐시에 즉시 업데이트하고 UI 업데이트
      final cacheIndex = _cachedProjects.indexWhere((p) => p.id == project.id);
      if (cacheIndex != -1) {
        _cachedProjects[cacheIndex] = project;
        _isSyncing = true;
        notifyListeners();

        // 2. GitHub에 비동기로 저장
        await _syncToGitHub(() async {
          final index = _projects.indexWhere((p) => p.id == project.id);
          if (index != -1) {
            _projects[index] = project;
            final success = await _csvService.updateProjectsCsv(_projects);
            if (!success) throw Exception('프로젝트 업데이트 실패');
          }
        });
      }
    } catch (e) {
      // 3. 실패 시 캐시 롤백
      _cachedProjects = [..._projects];
      _isSyncing = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      // 1. 캐시에서 즉시 삭제하고 UI 업데이트
      _cachedProjects.removeWhere((p) => p.id == projectId);
      _isSyncing = true;
      notifyListeners();

      // 2. GitHub에 비동기로 저장
      await _syncToGitHub(() async {
        _projects.removeWhere((p) => p.id == projectId);
        final success = await _csvService.updateProjectsCsv(_projects);
        if (!success) throw Exception('프로젝트 삭제 실패');
      });

    } catch (e) {
      // 3. 실패 시 캐시 롤백
      _cachedProjects = [..._projects];
      _isSyncing = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<Project> getProject(String projectId) async {
    return _projects.firstWhere((p) => p.id == projectId);
  }

  Future<List<Project>> _parseProjects(String csvData) async {
    try {
      List<Project> projects = [];
      List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter(
        fieldDelimiter: ',',
        eol: '\n',
        textDelimiter: '"',
        textEndDelimiter: '"',
        shouldParseNumbers: false,
        allowInvalid: false,
      ).convert(csvData);
      
      print('CSV 변환 결과 행 수: ${rowsAsListOfValues.length}');
      
      if (rowsAsListOfValues.length > 1) {
        for (var i = 1; i < rowsAsListOfValues.length; i++) {
          try {
            final row = rowsAsListOfValues[i];
            if (row.length >= 13) {
              final cleanRow = row.map((field) {
                if (field == null) return '';
                return field.toString()
                    .trim()
                    .replaceAll(RegExp(r'^"|"$'), '')
                    .replaceAll('""', '"');
              }).toList();

              final project = Project(
                id: cleanRow[0],
                name: cleanRow[1],
                category: cleanRow[2],
                subCategory: cleanRow[3],
                description: cleanRow[4],
                detail: cleanRow[5],
                procedure: cleanRow[6],
                startDate: DateTime.parse(cleanRow[7]),
                status: cleanRow[8],
                manager: cleanRow[9],
                supervisor: cleanRow[10],
                createdAt: DateTime.parse(cleanRow[11]),
                updatedAt: DateTime.parse(cleanRow[12]),
                updateNotes: cleanRow.length > 13 ? cleanRow[13] : '',
              );
              projects.add(project);
              print('프로젝트 파싱 성공: ${project.name}');
            }
          } catch (e) {
            print('행 처리 중 오류: ${rowsAsListOfValues[i]}');
            print('오류 내용: $e');
            continue;
          }
        }
      }
      
      return projects;
    } catch (e) {
      print('CSV 파싱 에러: $e');
      return [];
    }
  }

  // GitHub와 동기화하는 헬퍼 메서드
  Future<void> _syncToGitHub(Future<void> Function() action) async {
    try {
      await action();
      // 성공 시 캐시를 현재 프로젝트 목록으로 업데이트
      _cachedProjects = [..._projects];
      _isSyncing = false;
      notifyListeners();
    } catch (e) {
      print('GitHub 동기화 에러: $e');
      rethrow;
    }
  }
} 