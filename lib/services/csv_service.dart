import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:csv/csv.dart';
import 'user_service.dart';
import '../models/task_template.dart';
import '../models/project.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform, File, Directory;

class CsvService {
  final String taskListUrl = dotenv.env['TASK_LIST_URL'] ?? 'assets/task_list.csv';
  final String baseProjectListUrl = dotenv.env['PROJECT_LIST_URL'] ?? 'assets/project_list.csv';
  final String githubToken = dotenv.env['GITHUB_TOKEN'] ?? '';
  final String owner = dotenv.env['GITHUB_REPO_OWNER'] ?? 'photo2story';
  final String repo = dotenv.env['GITHUB_REPO_NAME'] ?? 'task_master';
  String _localDir = '';
  final UserService _userService;

  CsvService(this._userService);

  Future<void> initialize() async {
    _localDir = kIsWeb ? '/temp' : (await getApplicationDocumentsDirectory()).path;
    print('로컬 저장소 경로: $_localDir');
  }

  String get _projectFileName {
    final userName = _userService.userName;
    return userName != null ? 'project_list_$userName.csv' : 'project_list.csv';
  }

  String get _localProjectFilePath {
    if (kIsWeb) {
      return _projectFileName;
    }
    return '$_localDir/$_projectFileName';
  }

  Future<List<TaskTemplate>> loadTaskTemplates() async {
    try {
      String csvData;
      
      if (kIsWeb) {
        csvData = await rootBundle.loadString('assets/task_list.csv');
      } else {
        final response = await http.get(Uri.parse(taskListUrl));
        if (response.statusCode != 200) {
          throw Exception('CSV 파일 로드 실패: ${response.statusCode}');
        }
        csvData = utf8.decode(response.bodyBytes);
      }

      final List<List<dynamic>> rowsAsListOfValues = 
          const CsvToListConverter().convert(csvData, eol: '\n');

      if (rowsAsListOfValues.isEmpty) {
        throw Exception('CSV 파일이 비어있습니다');
      }

      // 헤더 제거
      rowsAsListOfValues.removeAt(0);

      return rowsAsListOfValues.map((row) {
        if (row.length < 7) {
          throw Exception('잘못된 CSV 형식: ${row.toString()}');
        }
        
        return TaskTemplate(
          category: row[0].toString(),
          subCategory: row[1].toString(),
          detail: row[2].toString(),
          description: row[3].toString(),
          manager: row[4].toString(),
          supervisor: row[5].toString(),
          procedure: row[6].toString(),
        );
      }).toList();

    } catch (e) {
      print('템플릿 로드 에러: $e');
      rethrow;
    }
  }

  // 프로젝트 목록 가져오기 (로컬 우선, 없으면 기본 목록 사용)
  Future<List<Project>> fetchProjects() async {
    try {
      final file = File(_localProjectFilePath);
      
      // 로컬 파일이 있으면 그것을 사용
      if (await file.exists()) {
        final content = await file.readAsString();
        return _parseCsvToProjects(content);
      }
      
      // 없으면 기본 목록 가져와서 로컬에 저장
      final response = await http.get(Uri.parse(baseProjectListUrl));
      if (response.statusCode == 200) {
        await file.writeAsString(response.body);
        return _parseCsvToProjects(response.body);
      }
      
      return [];
    } catch (e) {
      print('프로젝트 CSV 로드 에러: $e');
      return [];
    }
  }

  // 프로젝트 목록 업데이트 (로컬 파일만 업데이트)
  Future<bool> updateProjectsCsv(List<Project> projects) async {
    try {
      final file = File(_localProjectFilePath);
      
      // CSV 형식으로 변환
      final csv = _projectsToCsv(projects);
      
      // 로컬 파일에 저장
      await file.writeAsString(csv);
      print('프로젝트 저장 완료: $_localProjectFilePath');
      
      return true;
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

  // 저장 경로 확인 메서드
  String getStorageLocation() {
    if (Platform.isWindows) {
      return 'Windows 저장 경로: $_localDir';
    } else if (Platform.isMacOS) {
      return 'macOS 저장 경로: $_localDir';
    } else if (Platform.isLinux) {
      return 'Linux 저장 경로: $_localDir';
    } else if (Platform.isAndroid) {
      return 'Android 저장 경로: $_localDir';
    } else if (Platform.isIOS) {
      return 'iOS 저장 경로: $_localDir';
    }
    return '알 수 없는 플랫폼: $_localDir';
  }

  // 파일 존재 여부 확인
  Future<bool> projectFileExists() async {
    final file = File(_localProjectFilePath);
    return await file.exists();
  }

  // 파일 내용 확인
  Future<String?> readProjectFile() async {
    try {
      final file = File(_localProjectFilePath);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      print('파일 읽기 에러: $e');
      return null;
    }
  }
} 