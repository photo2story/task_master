import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_template.dart';
import '../models/project.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CsvService {
  final String taskListUrl = 'https://raw.githubusercontent.com/photo2story/task_master/main/assets/task_list.csv';
  final String projectListUrl = 'https://raw.githubusercontent.com/photo2story/task_master/main/assets/project_list.csv';
  final String githubToken = const String.fromEnvironment('GITHUB_TOKEN', defaultValue: '');
  final String owner = 'photo2story';
  final String repo = 'task_master';
  
  // 기존 loadTaskTemplates() 메서드는 유지...

  // 업무 템플릿 로드 메서드 복원
  Future<List<TaskTemplate>> loadTaskTemplates() async {
    try {
      print('\nCSV 파일 로드 시도:');
      print('URL: $taskListUrl');
      
      final response = await http.get(Uri.parse(taskListUrl));
      
      print('서버 응답: ${response.statusCode}');
      if (response.statusCode == 200) {
        final rawData = response.body;
        
        final csvConverter = CsvToListConverter(
          shouldParseNumbers: false,
          fieldDelimiter: ',',
          eol: '\n',
          textDelimiter: '"',
          textEndDelimiter: '"',
          allowInvalid: false,
        );
        
        final List<List<dynamic>> csvTable = csvConverter.convert(rawData);
        
        print('CSV 행 수: ${csvTable.length}');
        if (csvTable.isNotEmpty) {
          print('헤더: ${csvTable[0]}');
          print('첫 번째 데이터 행: ${csvTable.length > 1 ? csvTable[1] : "없음"}');
        }

        return csvTable.skip(1).map((row) {
          try {
            final cleanRow = row.map((field) {
              if (field == null) return '';
              return field.toString()
                  .trim()
                  .replaceAll(RegExp(r'^"|"$'), '')
                  .replaceAll('""', '"');
            }).toList();

            return TaskTemplate(
              category: cleanRow[0],
              subCategory: cleanRow[1],
              detail: cleanRow[2],
              description: cleanRow[3],
              manager: cleanRow[4],
              supervisor: cleanRow[5],
              procedure: cleanRow[6],
            );
          } catch (e) {
            print('행 변환 에러: $row');
            print('에러 내용: $e');
            rethrow;
          }
        }).toList();
      } else {
        throw Exception('CSV 파일 로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('CSV 파일 로드 에러: $e');
      rethrow;
    }
  }

  // GitHub에서 프로젝트 목록 가져오기
  Future<List<Project>> fetchProjects() async {
    try {
      print('\n프로젝트 목록 가져오기 시도:');
      final response = await http.get(Uri.parse(projectListUrl));
      if (response.statusCode == 200) {
        return _parseCsvToProjects(response.body);
      }
      return [];
    } catch (e) {
      print('프로젝트 CSV 로드 에러: $e');
      return [];
    }
  }

  // GitHub에 프로젝트 목록 업데이트
  Future<bool> updateProjectsCsv(List<Project> projects) async {
    try {
      print('\nGitHub CSV 업데이트 시도:');
      
      // 1. 먼저 기존 프로젝트 목록을 가져옴
      final existingProjects = await fetchProjects();
      
      // 2. 새 프로젝트와 기존 프로젝트 합치기
      final allProjects = [...existingProjects];
      for (var project in projects) {
        // 이미 존재하는 프로젝트는 업데이트, 없는 것은 추가
        final index = allProjects.indexWhere((p) => p.id == project.id);
        if (index >= 0) {
          allProjects[index] = project;
        } else {
          allProjects.add(project);
        }
      }

      // 3. CSV 헤더
      final header = [
        'id', 'name', 'category', 'subCategory', 'description', 
        'detail', 'procedure', 'start_date', 'status', 'manager',
        'supervisor', 'created_at', 'updated_at', 'update_notes'
      ];

      // 4. 모든 프로젝트를 CSV 행으로 변환
      final rows = allProjects.map((project) => [
        project.id,
        project.name,
        project.category,
        project.subCategory,
        project.description,
        project.detail,
        project.procedure,
        project.startDate.toIso8601String(),
        project.status,
        project.manager,
        project.supervisor,
        project.createdAt.toIso8601String(),
        project.updatedAt.toIso8601String(),
        project.updateNotes ?? ''
      ]).toList();

      // 5. 헤더와 데이터 행을 합침
      final allRows = [header, ...rows];

      // 6. CSV 문자열로 변환
      final csv = const ListToCsvConverter(
        fieldDelimiter: ',',
        textDelimiter: '"',
        textEndDelimiter: '"',
      ).convert(allRows);

      // 7. GitHub API를 통해 파일 업데이트
      final response = await _updateGitHubFile(
        path: 'assets/project_list.csv',
        content: csv,
        message: 'Update project list'
      );

      return response.statusCode == 200;
    } catch (e) {
      print('CSV 업데이트 에러: $e');
      return false;
    }
  }

  // CSV 문자열을 Project 객체 리스트로 변환
  List<Project> _parseCsvToProjects(String csvData) {
    try {
      print('\nCSV 파싱 시도:');
      
      // 줄바꿈 문자 정규화
      csvData = csvData.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
      
      final csvConverter = CsvToListConverter(
        shouldParseNumbers: false,
        fieldDelimiter: ',',
        eol: '\n',
        textDelimiter: '"',
        textEndDelimiter: '"',
        allowInvalid: true,  // 잘못된 형식 허용
      );
      
      final List<List<dynamic>> csvTable = csvConverter.convert(csvData);
      print('CSV 테이블 행 수: ${csvTable.length}');
      
      if (csvTable.isEmpty) {
        print('CSV 테이블이 비어있습니다');
        return [];
      }
      
      print('헤더: ${csvTable[0]}');
      
      return csvTable.skip(1).map((row) {
        try {
          // 각 필드의 데이터 정제
          final cleanRow = row.map((field) {
            if (field == null) return '';
            return field.toString()
                .trim()
                .replaceAll(RegExp(r'^"|"$'), '')  // 앞뒤 쌍따옴표 제거
                .replaceAll('""', '"');            // 이스케이프된 쌍따옴표 처리
          }).toList();

          // 필요한 필드 수만큼 빈 문자열로 채우기
          while (cleanRow.length < 14) {
            cleanRow.add('');
          }

          return Project(
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
            updateNotes: cleanRow[13],
          );
        } catch (e) {
          print('행 변환 에러: $row');
          print('에러 내용: $e');
          return null;
        }
      })
      .where((project) => project != null)  // null 항목 제거
      .cast<Project>()                      // Project 타입으로 캐스팅
      .toList();
      
    } catch (e) {
      print('CSV 파싱 에러: $e');
      return [];
    }
  }

  // Project 객체 리스트를 CSV 문자열로 변환
  String _projectsToCsv(List<Project> projects) {
    final header = 'id,name,category,subCategory,description,detail,procedure,start_date,status,manager,supervisor,created_at,updated_at,update_notes\n';
    final rows = projects.map((p) => [
      p.id,
      p.name,
      p.category,
      p.subCategory,
      p.description,
      p.detail,
      p.procedure,
      p.startDate.toIso8601String(),
      p.status,
      p.manager,
      p.supervisor,
      p.createdAt.toIso8601String(),
      p.updatedAt.toIso8601String(),
      p.updateNotes,
    ].join(',')).join('\n');
    
    return header + rows;
  }

  Future<http.Response> _updateGitHubFile({
    required String path,
    required String content,
    required String message,
  }) async {
    try {
      // 1. 현재 파일의 SHA 가져오기
      final shaUrl = 'https://api.github.com/repos/$owner/$repo/contents/$path';
      final shaResponse = await http.get(
        Uri.parse(shaUrl),
        headers: {
          'Authorization': 'Bearer $githubToken',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (shaResponse.statusCode != 200) {
        throw Exception('SHA 가져오기 실패: ${shaResponse.statusCode}');
      }

      final sha = jsonDecode(shaResponse.body)['sha'];

      // 2. 파일 업데이트
      final updateUrl = 'https://api.github.com/repos/$owner/$repo/contents/$path';
      final encodedContent = base64Encode(utf8.encode(content));

      final response = await http.put(
        Uri.parse(updateUrl),
        headers: {
          'Authorization': 'Bearer $githubToken',
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
          'content': encodedContent,
          'sha': sha,
          'branch': 'main',
        }),
      );

      return response;
    } catch (e) {
      print('GitHub 파일 업데이트 에러: $e');
      rethrow;
    }
  }
} 