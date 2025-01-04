import 'package:flutter/material.dart';
import '../services/csv_service.dart';
import 'project_create_screen.dart';

class TaskTemplateScreen extends StatelessWidget {
  final _csvService = CsvService();

  // 템플릿을 트리 구조로 변환
  Map<String, Map<String, List<TaskTemplate>>> _organizeTemplates(List<TaskTemplate> templates) {
    Map<String, Map<String, List<TaskTemplate>>> tree = {};
    
    for (var template in templates) {
      // 대분류 (예: 인사, 급여/세금)
      tree.putIfAbsent(template.category, () => {});
      
      // 중분류 (예: 채용, 퇴사)
      tree[template.category]!.putIfAbsent(template.subCategory, () => []);
      
      // 상세 업무 추가
      tree[template.category]![template.subCategory]!.add(template);
    }
    
    return tree;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('업무 목록'),
      ),
      body: FutureBuilder<List<TaskTemplate>>(
        future: _csvService.loadTaskTemplates(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('업무 목록을 불러오는데 실패했습니다.'));
          }

          final templates = snapshot.data ?? [];
          final tree = _organizeTemplates(templates);
          
          return SingleChildScrollView(
            child: ExpansionPanelList.radio(
              children: tree.entries.map((category) {
                return ExpansionPanelRadio(
                  headerBuilder: (context, isExpanded) {
                    return ListTile(
                      title: Text(category.key, 
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                  body: Column(
                    children: category.value.entries.map((subCategory) {
                      return ExpansionTile(
                        title: Text(subCategory.key),
                        children: subCategory.value.map((template) {
                          return ListTile(
                            title: Text(template.detail),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('업무내용: ${template.description}'),
                                Text('담당: ${template.manager}'),
                                Text('관리: ${template.supervisor}'),
                                Text('절차: ${template.procedure}'),
                              ],
                            ),
                            isThreeLine: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProjectCreateScreen(
                                    initialCategory: template.category,
                                    initialSubCategory: template.subCategory,
                                    initialDetail: template.detail,
                                    initialDescription: template.description,
                                    initialManager: template.manager,
                                    initialSupervisor: template.supervisor,
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                  value: category.key,
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
} 