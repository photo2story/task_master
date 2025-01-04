import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'dart:math' show min;

class TaskTemplate {
  final String category;      // 구분
  final String subCategory;   // 분류
  final String detail;        // 상세
  final String description;   // 업무내용
  final String manager;       // 담당
  final String supervisor;    // 관리
  final String procedure;     // 업무절차

  TaskTemplate({
    required this.category,
    required this.subCategory,
    required this.detail,
    required this.description,
    required this.manager,
    required this.supervisor,
    required this.procedure,
  });
}

class CsvService {
  Future<List<TaskTemplate>> loadTaskTemplates() async {
    try {
      print('CSV 파일 로드 시도...'); 
      final rawData = await rootBundle.loadString('assets/task_list.csv');
      
      // BOM 제거 및 줄바꿈 정규화
      final String cleanData = rawData
          .replaceAll('\uFEFF', '')  // BOM 제거
          .replaceAll('\r\n', '\n')  // Windows 줄바꿈을 Unix 스타일로 변환
          .replaceAll('\r', '\n');   // Mac 줄바꿈을 Unix 스타일로 변환

      final List<List<dynamic>> csvTable = const CsvToListConverter(
        shouldParseNumbers: false,
        fieldDelimiter: ',',
        eol: '\n',
        textDelimiter: '"',
        textEndDelimiter: '"',
      ).convert(cleanData);

      print('CSV 테이블 행 수: ${csvTable.length}');
      
      // 헤더 제거
      if (csvTable.isNotEmpty) {
        csvTable.removeAt(0);
      }

      final templates = csvTable.where((row) => row.length >= 7).map((row) {
        // 각 필드 디버그 출력
        print('CSV 행 데이터:');
        print('구분: ${row[0]}');
        print('분류: ${row[1]}');
        print('상세: ${row[2]}');
        print('업무내용: ${row[3]}');
        print('담당: ${row[4]}');
        print('관리: ${row[5]}');
        print('업무절차: ${row[6]}');

        final template = TaskTemplate(
          category: row[0].toString().trim(),
          subCategory: row[1].toString().trim(),
          detail: row[2].toString().trim(),
          description: row[3].toString().trim(),
          manager: row[4].toString().trim(),
          supervisor: row[5].toString().trim(),
          procedure: row[6].toString().trim(),
        );

        // 생성된 템플릿 디버그 출력
        print('생성된 템플릿:');
        print('category: ${template.category}');
        print('subCategory: ${template.subCategory}');
        print('detail: ${template.detail}');
        print('description: ${template.description}');
        print('manager: ${template.manager}');
        print('supervisor: ${template.supervisor}');
        print('procedure: ${template.procedure}');

        return template;
      }).toList();

      print('생성된 템플릿 수: ${templates.length}');
      return templates;

    } catch (e, stackTrace) {
      print('CSV 로드 에러: $e');
      print('스택 트레이스: $stackTrace');
      return [];
    }
  }
} 