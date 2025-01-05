import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../models/task_template.dart';
import '../services/project_service.dart';
import '../services/database_service.dart';
import '../services/csv_service.dart';

class ProjectCreateScreen extends StatefulWidget {
  final TaskTemplate? template;  // 선택된 템플릿

  const ProjectCreateScreen({Key? key, this.template}) : super(key: key);

  @override
  _ProjectCreateScreenState createState() => _ProjectCreateScreenState();
}

class _ProjectCreateScreenState extends State<ProjectCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _csvService = CsvService();
  
  String _selectedCategory = '';
  String _selectedSubCategory = '';
  String _detail = '';
  String _description = '';
  String _manager = '';
  String _supervisor = '';
  String _procedure = '';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  int _durationInDays = 7;
  String _status = '진행중';

  TaskTemplate? _selectedTemplate;  // 선택된 템플릿 저장

  @override
  void initState() {
    super.initState();
    if (widget.template != null) {
      // 전달받은 템플릿이 있으면 사용
      _selectedTemplate = widget.template;
      _updateFromTemplate();
    } else {
      // 없으면 CSV에서 로드
      _loadTemplate();
    }
    _updateEndDate();
  }

  // CSV에서 템플릿 로드
  Future<void> _loadTemplate() async {
    try {
      final templates = await _csvService.loadTaskTemplates();
      if (templates.isNotEmpty) {
        setState(() {
          _selectedTemplate = templates.first;  // 기본값으로 첫 번째 템플릿 사용
          _updateFromTemplate();
        });
      }
    } catch (e) {
      print('템플릿 로드 에러: $e');
    }
  }

  // 템플릿에서 값 업데이트
  void _updateFromTemplate() {
    if (_selectedTemplate != null) {
      setState(() {
        _selectedCategory = _selectedTemplate!.category;
        _selectedSubCategory = _selectedTemplate!.subCategory;
        _detail = _selectedTemplate!.detail;
        _description = _selectedTemplate!.description;
        _manager = _selectedTemplate!.manager;
        _supervisor = _selectedTemplate!.supervisor;
        _procedure = _selectedTemplate!.procedure;
      });
    }
  }

  // 종료일 업데이트 메서드 추가
  void _updateEndDate() {
    setState(() {
      _endDate = _startDate.add(Duration(days: _durationInDays));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새 프로젝트'),
        actions: [
          ElevatedButton.icon(
            icon: Icon(Icons.save),
            label: Text('등록'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _createProject(context),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로젝트 정보 카드 (템플릿 기반 정보)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('프로젝트 정보', style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: 16),
                      Text('구분: $_selectedCategory'),
                      Text('분류: $_selectedSubCategory'),
                      SizedBox(height: 12),
                      Text('담당자: $_manager'),
                      Text('관리자: $_supervisor'),
                      SizedBox(height: 12),
                      Text('업무 내용:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_description),
                      SizedBox(height: 12),
                      Text('업무 절차:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_procedure),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // 일정 관리 카드 (수정 가능)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('일정 관리', style: Theme.of(context).textTheme.titleLarge),
                      ListTile(
                        title: Text('시작일'),
                        subtitle: Text('${_startDate.year}-${_startDate.month}-${_startDate.day}'),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() {
                              _startDate = picked;
                              _updateEndDate();
                            });
                          }
                        },
                      ),
                      Slider(
                        value: _durationInDays.toDouble(),
                        min: 1,
                        max: 365,
                        divisions: 364,
                        label: '$_durationInDays일',
                        onChanged: (double value) {
                          setState(() {
                            _durationInDays = value.round();
                            _updateEndDate();
                          });
                        },
                      ),
                      ListTile(
                        title: Text('종료일'),
                        subtitle: Text(_endDate == null ? '-' :
                          '${_endDate!.year}-${_endDate!.month}-${_endDate!.day}'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createProject(BuildContext context) async {
    if (_formKey.currentState?.validate() == true) {
      // 프로젝트명 생성: YYYYMMDD_구분_분류_상세
      final projectName = '${_startDate.year}'
          '${_startDate.month.toString().padLeft(2, '0')}'
          '${_startDate.day.toString().padLeft(2, '0')}'
          '_${_selectedCategory}'
          '_${_selectedSubCategory}'
          '_${_detail}';

      final project = Project(
        id: const Uuid().v4(),
        name: projectName,
        category: _selectedCategory,
        subCategory: _selectedSubCategory,
        detail: _detail,
        description: _description,
        manager: _manager,
        supervisor: _supervisor,
        procedure: _procedure,
        startDate: _startDate,
        status: _status,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        await context.read<ProjectService>().createProject(project);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로젝트 생성 실패: $e')),
        );
      }
    }
  }
} 