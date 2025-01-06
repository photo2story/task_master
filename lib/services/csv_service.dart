import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_template.dart';
import '../models/project.dart';
import '../services/user_service.dart';

class CsvService {
  final UserService _userService;
  late SharedPreferences _prefs;
  
  // GitHub Raw 콘텐츠 URL
  final String taskListUrl = 'https://raw.githubusercontent.com/photo2story/task_master/main/assets/task_list.csv';
  final String projectListUrl = 'https://raw.githubusercontent.com/photo2story/task_master/main/assets/project_list.csv';

  CsvService(this._userService);

  Future<String> get _localPath async {
    if (kIsWeb) return '';
    
    if (Platform.isWindows) {
      return '${Platform.environment['TEMP']}\\task_master';
    } else {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  Future<File> _getLocalFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      
      if (!kIsWeb) {
        final path = await _localPath;
        await Directory(path).create(recursive: true);
      }
      print('CsvService 초기화 완료');
    } catch (e) {
      print('CsvService 초기화 실패: $e');
    }
  }

  // 업무 템플릿 로드
  Future<List<TaskTemplate>> loadTaskTemplates() async {
    try {
      print('업무목록을 원격 저장소에서 로드 시도...');
      final response = await http.get(Uri.parse(taskListUrl));
      
      if (response.statusCode == 200) {
        final csvData = utf8.decode(response.bodyBytes);
        print('업무목록 원격 로드 성공: ${csvData.length} bytes');
        
        // 디버깅을 위해 CSV 데이터의 처음 부분만 출력
        final previewLength = min(200, csvData.length);
        print('CSV 데이터 미리보기: ${csvData.substring(0, previewLength)}...');
        
        final List<List<dynamic>> rows = const CsvToListConverter(
          shouldParseNumbers: false,
          allowInvalid: true,
          fieldDelimiter: ',',
          eol: '\n',
        ).convert(csvData);
        
        if (rows.isEmpty) {
          print('CSV 파일이 비어있습니다');
          return [];
        }
        
        print('총 ${rows.length}개의 행이 로드됨');
        if (rows.isNotEmpty) {
          print('헤더: ${rows[0].join(", ")}');
        }
        
        // 헤더 검증
        if (rows[0].length < 7) {
          print('잘못된 CSV 형식: 헤더 열이 부족합니다 (${rows[0].length} columns)');
          return [];
        }
        
        rows.removeAt(0); // 헤더 제거
        
        return rows.where((row) => row.length >= 7).map((row) {
          try {
            return TaskTemplate(
              category: row[0].toString().trim(),
              subCategory: row[1].toString().trim(),
              detail: row[2].toString().trim(),
              description: row[3].toString().trim(),
              manager: row[4].toString().trim(),
              supervisor: row[5].toString().trim(),
              procedure: row[6].toString().trim(),
            );
          } catch (e) {
            print('행 변환 에러: ${row.join(", ")}');
            print('에러 내용: $e');
            return null;
          }
        }).whereType<TaskTemplate>().toList();
      } else {
        print('업무목록 로드 실패 (상태 코드: ${response.statusCode})');
        print('응답 내용: ${response.body}');
        return [];
      }
    } catch (e) {
      print('템플릿 로드 에러: $e');
      return [];
    }
  }

  // 프로젝트 목록 가져오기
  Future<List<Project>> fetchProjects() async {
    try {
      String csvData;
      
      if (kIsWeb) {
        csvData = _prefs.getString('projects_cache') ?? '';
        if (csvData.isEmpty) {
          final response = await http.get(Uri.parse(projectListUrl));
          csvData = utf8.decode(response.bodyBytes);
          await _prefs.setString('projects_cache', csvData);
        }
      } else {
        final file = await _getLocalFile('project_list.csv');
        if (await file.exists()) {
          csvData = await file.readAsString();
        } else {
          final response = await http.get(Uri.parse(projectListUrl));
          csvData = utf8.decode(response.bodyBytes);
          await file.writeAsString(csvData);
        }
      }

      final rows = const CsvToListConverter().convert(csvData);
      if (rows.isEmpty) return [];
      
      rows.removeAt(0); // 헤더 제거
      return rows.map((row) => Project.fromCsv(row)).toList();
    } catch (e) {
      print('프로젝트 로드 에러: $e');
      return [];
    }
  }

  // 프로젝트 목록 업데이트
  Future<bool> updateProjectsCsv(List<Project> projects) async {
    try {
      final csvData = const ListToCsvConverter().convert([
        ['id', 'name', 'category', 'subCategory', 'description', 'detail', 
         'procedure', 'start_date', 'end_date', 'status', 'manager', 'supervisor', 
         'created_at', 'updated_at', 'update_notes'],
        ...projects.map((p) => p.toCsv()),
      ]);
      
      if (kIsWeb) {
        await _prefs.setString('projects_cache', csvData);
      } else {
        final file = await _getLocalFile('project_list.csv');
        await file.writeAsString(csvData);
      }
      return true;
    } catch (e) {
      print('프로젝트 저장 에러: $e');
      return false;
    }
  }
} 