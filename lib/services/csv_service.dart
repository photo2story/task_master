import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'dart:math' show min;
import '../models/task_template.dart';

class CsvService {
  final String csvUrl = 'https://raw.githubusercontent.com/photo2story/task_master/main/task_master_pro/assets/task_list.csv';

  Future<List<TaskTemplate>> loadTaskTemplates() async {
    try {
      print('\nCSV 파일 로드 시도:');
      print('URL: $csvUrl');
      
      // 웹에서 CSV 파일 읽기
      final response = await http.get(Uri.parse(csvUrl));
      
      print('서버 응답: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('응답 내용: ${response.body.substring(0, min(200, response.body.length))}...');
        
        final rawData = response.body;
        final List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData);
        
        print('CSV 행 수: ${csvTable.length}');
        if (csvTable.isNotEmpty) {
          print('헤더: ${csvTable[0]}');
          print('첫 번째 데이터: ${csvTable.length > 1 ? csvTable[1] : "없음"}');
        }
        
        final templates = csvTable.skip(1).map((row) => TaskTemplate(
          category: row[0].toString(),
          subCategory: row[1].toString(),
          detail: row[2].toString(),
          description: row[3].toString(),
          manager: row[4].toString(),
          supervisor: row[5].toString(),
          procedure: row[6].toString(),
        )).toList();

        print('변환된 템플릿 수: ${templates.length}');
        return templates;
      } else {
        print('응답 내용: ${response.body}');
        throw Exception('CSV 파일 로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('CSV 파일 로드 에러: $e');
      rethrow;
    }
  }
} 