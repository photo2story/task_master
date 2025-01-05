import 'package:flutter/material.dart';
import '../services/csv_service.dart';
import '../models/task_template.dart';
import 'project_create_screen.dart';

class TaskTemplateScreen extends StatefulWidget {
  @override
  _TaskTemplateScreenState createState() => _TaskTemplateScreenState();
}

class _TaskTemplateScreenState extends State<TaskTemplateScreen> {
  final CsvService _csvService = CsvService();
  String? selectedCategory;
  List<String> categories = [];
  Map<String, List<TaskTemplate>> templatesByCategory = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // 1단계: 카테고리만 먼저 로드
  Future<void> _loadCategories() async {
    try {
      setState(() => isLoading = true);
      final templates = await _csvService.loadTaskTemplates();
      
      // 카테고리 목록 추출
      final uniqueCategories = templates
          .map((t) => t.category)
          .toSet()
          .toList()
        ..sort();
      
      // 첫 번째 카테고리의 템플릿만 미리 로드
      final firstCategoryTemplates = templates
          .where((t) => t.category == uniqueCategories.first)
          .toList();

      setState(() {
        categories = uniqueCategories;
        selectedCategory = uniqueCategories.first;
        templatesByCategory = {
          uniqueCategories.first: firstCategoryTemplates
        };
        isLoading = false;
      });
    } catch (e) {
      print('카테고리 로드 에러: $e');
      setState(() => isLoading = false);
    }
  }

  // 2단계: 선택된 카테고리의 템플릿 로드
  Future<void> _loadTemplatesForCategory(String category) async {
    if (templatesByCategory.containsKey(category)) return;

    try {
      setState(() => isLoading = true);
      final templates = await _csvService.loadTaskTemplates();
      final categoryTemplates = templates
          .where((t) => t.category == category)
          .toList();

      setState(() {
        templatesByCategory[category] = categoryTemplates;
        isLoading = false;
      });
    } catch (e) {
      print('템플릿 로드 에러: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('업무 목록')),
      body: Row(
        children: [
          // 왼쪽 패널: 카테고리 목록
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '업무 구분',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return ListTile(
                              title: Text(
                                category,
                                style: TextStyle(fontSize: 14),
                              ),
                              selected: selectedCategory == category,
                              selectedTileColor: Colors.blue[50],
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              minLeadingWidth: 0,
                              horizontalTitleGap: 0,
                              onTap: () {
                                setState(() => selectedCategory = category);
                                _loadTemplatesForCategory(category);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          // 오른쪽 패널: 선택된 카테고리의 템플릿 목록
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text(
                      selectedCategory ?? '카테고리를 선택하세요',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Expanded(
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : selectedCategory == null
                            ? Center(child: Text('왼쪽에서 카테고리를 선택하세요'))
                            : ListView.builder(
                                itemCount: templatesByCategory[selectedCategory]?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final template = templatesByCategory[selectedCategory]![index];
                                  return Card(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 1,
                                    ),
                                    child: ExpansionTile(
                                      title: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              template.subCategory,
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              template.detail,
                                              style: TextStyle(fontSize: 12),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      tilePadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                      childrenPadding: EdgeInsets.all(8),
                                      dense: true,
                                      visualDensity: VisualDensity.compact,
                                      collapsedShape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('업무 내용:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                            Text(template.description, style: TextStyle(fontSize: 13)),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Text('담당: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                      Text(template.manager, style: TextStyle(fontSize: 13)),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Text('관리: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                      Text(template.supervisor, style: TextStyle(fontSize: 13)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text('업무 절차: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                Expanded(
                                                  child: Text(template.procedure, style: TextStyle(fontSize: 13)),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Center(
                                              child: ElevatedButton.icon(
                                                onPressed: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ProjectCreateScreen(template: template),
                                                  ),
                                                ),
                                                icon: Icon(Icons.add, size: 18),
                                                label: Text('프로젝트 생성'),
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  minimumSize: Size(0, 32),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 