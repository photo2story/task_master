import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/csv_service.dart';
import '../models/task_template.dart';
import '../models/project.dart';
import 'project_create_screen.dart';
import 'project_detail_screen.dart';

class TaskTemplateScreen extends StatefulWidget {
  @override
  _TaskTemplateScreenState createState() => _TaskTemplateScreenState();
}

class _TaskTemplateScreenState extends State<TaskTemplateScreen> {
  late final CsvService _csvService;
  String? selectedCategory;
  List<String> categories = [];
  Map<String, List<TaskTemplate>> templatesByCategory = {};
  bool isLoading = true;
  
  // 검색을 위한 변수 추가
  final TextEditingController _searchController = TextEditingController();
  List<TaskTemplate> searchResults = [];
  bool isSearching = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _csvService = Provider.of<CsvService>(context);
    _loadAllTemplates();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 검색 메서드 추가
  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        searchResults.clear();
      });
      return;
    }

    setState(() {
      isSearching = true;
      searchResults = templatesByCategory.values
          .expand((templates) => templates)
          .where((template) {
            final searchQuery = query.toLowerCase();
            return template.subCategory.toLowerCase().contains(searchQuery) ||   // 분류
                   template.detail.toLowerCase().contains(searchQuery) ||        // 상세
                   template.description.toLowerCase().contains(searchQuery) ||   // 업무내용
                   template.manager.toLowerCase().contains(searchQuery) ||       // 담당
                   template.supervisor.toLowerCase().contains(searchQuery) ||    // 관리
                   template.procedure.toLowerCase().contains(searchQuery);       // 업무절차
          })
          .toList();
    });
  }

  // 모든 템플릿을 한 번에 로드하는 메서드
  Future<void> _loadAllTemplates() async {
    try {
      setState(() => isLoading = true);
      final templates = await _csvService.loadTaskTemplates();
      
      // 카테고리별로 템플릿 분류
      final Map<String, List<TaskTemplate>> tempTemplatesByCategory = {};
      final Set<String> uniqueCategories = {};

      for (var template in templates) {
        if (!tempTemplatesByCategory.containsKey(template.category)) {
          tempTemplatesByCategory[template.category] = [];
          uniqueCategories.add(template.category);
        }
        tempTemplatesByCategory[template.category]!.add(template);
      }

      setState(() {
        categories = uniqueCategories.toList()..sort();
        selectedCategory = categories.first;
        templatesByCategory = tempTemplatesByCategory;
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
      backgroundColor: Color(0xFF1A2421),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('업무 목록'),
      ),
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
                                style: TextStyle(
                                  fontSize: 14,
                                  color: selectedCategory == category
                                      ? Colors.white
                                      : Colors.grey[300],
                                ),
                              ),
                              selected: selectedCategory == category,
                              selectedTileColor: Color(0xFF2A2A2A),
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              minLeadingWidth: 0,
                              horizontalTitleGap: 0,
                              onTap: () {
                                setState(() => selectedCategory = category);
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
              color: Colors.black,
              child: Column(
                children: [
                  // 검색 위젯 추가
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _performSearch,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '분류, 담당, 관리, 업무내용, 업무절차로 검색...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        filled: true,
                        fillColor: Color(0xFF2A2A2A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  Expanded(
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : isSearching
                            ? _buildSearchResults()
                            : selectedCategory == null
                                ? Center(child: Text(
                                    '왼쪽에서 카테고리를 선택하세요',
                                    style: TextStyle(color: Colors.grey[300]),
                                  ))
                                : _buildCategoryTemplates(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 검색 결과 표시 위젯
  Widget _buildSearchResults() {
    if (searchResults.isEmpty) {
      return Center(
        child: Text(
          '검색 결과가 없습니다',
          style: TextStyle(color: Colors.grey[300]),
        ),
      );
    }

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final template = searchResults[index];
        return _buildTemplateCard(template, index == 0);
      },
    );
  }

  // 카테고리별 템플릿 표시 위젯
  Widget _buildCategoryTemplates() {
    return ListView.builder(
      itemCount: templatesByCategory[selectedCategory]?.length ?? 0,
      itemBuilder: (context, index) {
        final template = templatesByCategory[selectedCategory]![index];
        return _buildTemplateCard(template, index == 0);
      },
    );
  }

  // 템플릿 카드 위젯 (재사용)
  Widget _buildTemplateCard(TaskTemplate template, bool isFirst) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      color: Color(0xFF1A2421),
      child: ExpansionTile(
        initiallyExpanded: isFirst,
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
  }
} 