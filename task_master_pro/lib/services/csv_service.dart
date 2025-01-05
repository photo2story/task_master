import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import '../models/task_template.dart';

class CsvService {
  Future<List<TaskTemplate>> loadTaskTemplates() async {
    try {
      // CSV 파일 읽기
      final rawData = await rootBundle.loadString('assets/task_list.csv');
      final List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData);
      
      // 첫 번째 줄은 헤더이므로 제외하고 변환
      return csvTable.skip(1).map((row) => TaskTemplate(
        category: row[0].toString(),
        subCategory: row[1].toString(),
        detail: row[2].toString(),
        description: row[3].toString(),
        manager: row[4].toString(),
        supervisor: row[5].toString(),
        procedure: row[6].toString(),
      )).toList();
    } catch (e) {
      print('CSV 파일 로드 에러: $e');
      rethrow;
    }
  }
} 