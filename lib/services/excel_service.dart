import 'package:excel/excel.dart';
import '../models/project.dart';

class ExcelService {
  Future<List<Project>> readProjects(List<int> bytes) async {
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables[excel.tables.keys.first];
    
    List<Project> projects = [];
    bool isHeader = true;
    
    for (var row in sheet.rows) {
      if (isHeader) {
        isHeader = false;
        continue;
      }
      
      try {
        final project = Project(
          id: row[0]?.value?.toString() ?? '',
          name: row[1]?.value?.toString() ?? '',
          category: row[2]?.value?.toString() ?? '',
          subCategory: row[3]?.value?.toString() ?? '',
          description: row[4]?.value?.toString() ?? '',
          detail: row[5]?.value?.toString() ?? '',
          procedure: row[6]?.value?.toString() ?? '',
          startDate: DateTime.parse(row[7]?.value?.toString() ?? ''),
          status: row[8]?.value?.toString() ?? '',
          manager: row[9]?.value?.toString() ?? '',
          supervisor: row[10]?.value?.toString() ?? '',
          createdAt: DateTime.parse(row[11]?.value?.toString() ?? ''),
          updatedAt: DateTime.parse(row[12]?.value?.toString() ?? ''),
          updateNotes: row[13]?.value?.toString(),
        );
        projects.add(project);
      } catch (e) {
        print('행 처리 중 오류: $e');
        continue;
      }
    }
    
    return projects;
  }

  List<int> writeProjects(List<Project> projects) {
    final excel = Excel.createExcel();
    final sheet = excel.sheets[excel.getDefaultSheet()];
    
    // 헤더 추가
    sheet.appendRow([
      'id', 'name', 'category', 'subCategory', 'description',
      'detail', 'procedure', 'start_date', 'status', 'manager',
      'supervisor', 'created_at', 'updated_at', 'update_notes'
    ]);
    
    // 데이터 추가
    for (var project in projects) {
      sheet.appendRow([
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
        project.updateNotes ?? '',
      ]);
    }
    
    return excel.encode()!;
  }
} 