import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../models/task_template.dart';
import 'database_service.dart';
import 'package:uuid/uuid.dart';
import 'csv_service.dart';
import 'package:csv/csv.dart';

class ProjectService extends ChangeNotifier {
  final CsvService _csvService = CsvService();
  List<Project> _projects = [];

  List<Project> get projects => _projects;

  Future<void> loadProjects() async {
    try {
      print('프로젝트 목록 로드 시도...');
      _projects = await _csvService.fetchProjects();
      print('로드된 프로젝트 수: ${_projects.length}');
      notifyListeners();
    } catch (e) {
      print('프로젝트 로드 에러: $e');
    }
  }

  Future<void> createProject(Project project) async {
    try {
      print('프로젝트 생성 시도...');
      print('프로젝트 정보: ${project.toJson()}');
      
      // 1. 로컬 목록에 추가
      _projects = [..._projects, project];
      
      // 2. GitHub CSV 업데이트
      final success = await _csvService.updateProjectsCsv(_projects);
      if (!success) {
        print('GitHub CSV 업데이트 실패');
        // 실패 시 로컬 목록에서 제거
        _projects.removeLast();
        throw Exception('프로젝트 저장 실패');
      }
      
      print('프로젝트 생성 성공');
      notifyListeners();
    } catch (e) {
      print('프로젝트 생성 에러: $e');
      rethrow;
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      print('프로젝트 업데이트 시도...');
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = project;
        final success = await _csvService.updateProjectsCsv(_projects);
        if (!success) {
          print('GitHub CSV 업데이트 실패');
          throw Exception('프로젝트 업데이트 실패');
        }
        print('프로젝트 업데이트 성공');
        notifyListeners();
      }
    } catch (e) {
      print('프로젝트 업데이트 에러: $e');
      rethrow;
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      print('프로젝트 삭제 시도...');
      _projects.removeWhere((p) => p.id == projectId);
      final success = await _csvService.updateProjectsCsv(_projects);
      if (!success) {
        print('GitHub CSV 업데이트 실패');
        throw Exception('프로젝트 삭제 실패');
      }
      print('프로젝트 삭제 성공');
      notifyListeners();
    } catch (e) {
      print('프로젝트 삭제 에러: $e');
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
} 