import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_template.dart';
import '../models/project.dart';

class CsvService {
  // GitHub 원격 저장소의 CSV 파일 URL들
  final String taskListUrl = 'https://raw.githubusercontent.com/photo2story/task_master/main/assets/task_list.csv';
  final String projectListUrl = 'https://raw.githubusercontent.com/photo2story/task_master/main/assets/project_list.csv';

  // 기존 업무 템플릿 로드 메서드는 그대로 유지
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

  // 프로젝트 목록 로드
  Future<List<Project>> fetchProjects() async {
    try {
      print('\n프로젝트 CSV 파일 로드 시도:');
      print('URL: $projectListUrl');
      
      final response = await http.get(Uri.parse(projectListUrl));
      
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
        }

        // 첫 번째 행(헤더) 제외하고 데이터 변환
        return csvTable.skip(1).map((row) {
          try {
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
          } catch (e) {
            print('프로젝트 변환 에러: $row');
            print('에러 내용: $e');
            rethrow;
          }
        }).toList() as List<Project>;
      } else {
        throw Exception('프로젝트 CSV 파일 로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('프로젝트 CSV 파일 로드 에러: $e');
      return [];
    }
  }
} 