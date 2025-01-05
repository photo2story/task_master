import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'dart:math' show min;
import '../models/task_template.dart';

class CsvService {
  final String csvUrl = 'https://raw.githubusercontent.com/photo2story/task_master/main/assets/task_list.csv';

  Future<List<TaskTemplate>> loadTaskTemplates() async {
    try {
      print('\nCSV 파일 로드 시도:');
      print('URL: $csvUrl');
      
      final response = await http.get(Uri.parse(csvUrl));
      
      print('서버 응답: ${response.statusCode}');
      if (response.statusCode == 200) {
        final rawData = response.body;
        
        // CSV 파싱 옵션 설정
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
        
        // 첫 번째 행(헤더) 제외하고 데이터 변환
        final templates = csvTable.skip(1).map((row) {
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

        print('변환된 템플릿 수: ${templates.length}');
        return templates;
      } else {
        throw Exception('CSV 파일 로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('CSV 파일 로드 에러: $e');
      rethrow;
    }
  }
} 