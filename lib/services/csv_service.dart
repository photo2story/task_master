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
        );
        
        final List<List<dynamic>> csvTable = csvConverter.convert(rawData);
        
        print('CSV 행 수: ${csvTable.length}');
        if (csvTable.isNotEmpty) {
          print('헤더: ${csvTable[0]}');
          print('첫 번째 데이터 행: ${csvTable.length > 1 ? csvTable[1] : "없음"}');
        }

        return csvTable.skip(1).map((row) {
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
      print('URL: $projectListUrl');
      
      final response = await http.get(Uri.parse(projectListUrl));
      print('응답 상태 코드: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final csvData = response.body;
        print('CSV 데이터 수신 (일부):');
        print(csvData.split('\n').take(2).join('\n'));
        
        final projects = _parseCsvToProjects(csvData);
        print('파싱된 프로젝트 수: ${projects.length}');
        return projects;
      }
      
      print('프로젝트 목록 가져오기 실패: ${response.statusCode}');
      return [];
    } catch (e) {
      print('프로젝트 목록 가져오기 에러: $e');
      return [];
    }
  }

  // GitHub에 프로젝트 목록 업데이트
  Future<bool> updateProjectsCsv(List<Project> projects) async {
    try {
      print('\nGitHub CSV 업데이트 시도:');
      print('Token: ${githubToken.substring(0, 10)}...'); // 토큰의 일부만 출력
      
      // 1. 현재 파일의 SHA 가져오기
      final shaUrl = 'https://api.github.com/repos/$owner/$repo/contents/assets/project_list.csv';
      print('SHA 요청 URL: $shaUrl');
      
      final shaResponse = await http.get(
        Uri.parse(shaUrl),
        headers: {
          'Authorization': 'Bearer $githubToken',
          'Accept': 'application/vnd.github.v3+json',
        },
      );
      
      print('SHA 응답 상태 코드: ${shaResponse.statusCode}');
      print('SHA 응답 내용: ${shaResponse.body}');
      
      if (shaResponse.statusCode != 200) {
        throw Exception('SHA 가져오기 실패: ${shaResponse.statusCode}');
      }
      
      final sha = jsonDecode(shaResponse.body)['sha'];
      print('가져온 SHA: $sha');
      
      // 2. CSV 데이터 생성
      final csvData = _projectsToCsv(projects);
      print('생성된 CSV 데이터 (일부):');
      print(csvData.split('\n').take(2).join('\n')); // 헤더와 첫 번째 행만 출력
      
      // 3. GitHub API를 통해 파일 업데이트
      final updateUrl = 'https://api.github.com/repos/$owner/$repo/contents/assets/project_list.csv';
      print('업데이트 요청 URL: $updateUrl');
      
      final content = base64Encode(utf8.encode(csvData));
      print('인코딩된 콘텐츠 길이: ${content.length}');
      
      final response = await http.put(
        Uri.parse(updateUrl),
        headers: {
          'Authorization': 'Bearer $githubToken',
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': 'Update projects list',
          'content': content,
          'sha': sha,
          'branch': 'main',
        }),
      );
      
      print('업데이트 응답 상태 코드: ${response.statusCode}');
      print('업데이트 응답 내용: ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('CSV 업데이트 에러: $e');
      return false;
    }
  }

  // CSV 문자열을 Project 객체 리스트로 변환
  List<Project> _parseCsvToProjects(String csvData) {
    final csvTable = const CsvToListConverter().convert(csvData);
    return csvTable.skip(1).map((row) {
      return Project(
        id: row[0].toString(),
        name: row[1].toString(),
        category: row[2].toString(),
        subCategory: row[3].toString(),
        description: row[4].toString(),
        detail: row[5].toString(),
        procedure: row[6].toString(),
        startDate: DateTime.parse(row[7].toString()),
        status: row[8].toString(),
        manager: row[9].toString(),
        supervisor: row[10].toString(),
        createdAt: DateTime.parse(row[11].toString()),
        updatedAt: DateTime.parse(row[12].toString()),
        updateNotes: row[13].toString(),
      );
    }).toList();
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
} 