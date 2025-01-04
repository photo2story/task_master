import 'package:get/get.dart';
import 'package:task_master_pro/models/project/project.dart';
import 'package:csv/csv.dart';

class ProjectController extends GetxController {
  final RxList<Project> projects = <Project>[].obs;

  void importFromCsv(String csvData) {
    try {
      print('CSV 데이터 받음: ${csvData.substring(0, 100)}...'); // 첫 100자만 출력
      
      final List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);
      print('CSV 행 수: ${rows.length}');
      
      // 헤더 행 가져오기
      final headers = rows[0].map((e) => e.toString()).toList();
      print('헤더: $headers');
      
      // 데이터 행 처리
      projects.clear();
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        print('행 $i: $row');
        
        final data = Map<String, dynamic>.fromIterables(
          headers, 
          row.map((e) => e.toString())
        );
        print('데이터 맵: $data');
        
        final project = Project.fromCsv(data);
        print('생성된 프로젝트: ${project.toMap()}');
        
        projects.add(project);
      }

      print('총 ${projects.length}개의 프로젝트 로드됨');
      
      Get.snackbar(
        '성공',
        '${projects.length}개의 프로젝트를 불러왔습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stackTrace) {
      print('CSV 처리 중 오류 발생:');
      print('에러: $e');
      print('스택트레이스: $stackTrace');
      
      Get.snackbar(
        '오류',
        'CSV 파일 처리 중 오류가 발생했습니다: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
} 