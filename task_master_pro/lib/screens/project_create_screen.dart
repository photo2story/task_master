import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../models/task_template.dart';
import '../services/project_service.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

class ProjectCreateScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialSubCategory;
  final String? initialDetail;
  final String? initialDescription;
  final String? initialManager;
  final String? initialSupervisor;
  final String? initialProcedure;

  const ProjectCreateScreen({
    super.key,
    this.initialCategory,
    this.initialSubCategory,
    this.initialDetail,
    this.initialDescription,
    this.initialManager,
    this.initialSupervisor,
    this.initialProcedure,
  });

  @override
  _ProjectCreateScreenState createState() => _ProjectCreateScreenState();
}

class _ProjectCreateScreenState extends State<ProjectCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  int _durationInDays = 7;  // 기본 7일
  DateTime? get _endDate => _startDate?.add(Duration(days: _durationInDays));
  late TextEditingController _categoryController;
  late TextEditingController _subCategoryController;
  late TextEditingController _detailController;
  late TextEditingController _descriptionController;
  late TextEditingController _managerController;
  late TextEditingController _supervisorController;
  late TextEditingController _procedureController;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();  // 기본값: 오늘
    
    // 디버그 로그 추가
    print('ProjectCreateScreen initState:');
    print('initialProcedure: ${widget.initialProcedure}');
    
    // 컨트롤러 초기화
    _categoryController = TextEditingController(text: widget.initialCategory ?? '');
    _subCategoryController = TextEditingController(text: widget.initialSubCategory ?? '');
    _detailController = TextEditingController(text: widget.initialDetail ?? '');
    _descriptionController = TextEditingController(text: widget.initialDescription ?? '');
    _managerController = TextEditingController(text: widget.initialManager ?? '');
    _supervisorController = TextEditingController(text: widget.initialSupervisor ?? '');
    _procedureController = TextEditingController(text: widget.initialProcedure ?? '');
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _subCategoryController.dispose();
    _detailController.dispose();
    _descriptionController.dispose();
    _managerController.dispose();
    _supervisorController.dispose();
    _procedureController.dispose();
    super.dispose();
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
              // 기본 정보 (읽기 전용)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('구분: ${widget.initialCategory}'),
                      Text('분류: ${widget.initialSubCategory}'),
                      Text('상세: ${widget.initialDetail}'),
                      Text('업무내용: ${widget.initialDescription}'),
                      Text('담당자: ${widget.initialManager}'),
                      Text('관리자: ${widget.initialSupervisor}'),
                      Text('업무절차: ${widget.initialProcedure}'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // 일정 관리
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('일정 관리', style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: 16),
                      
                      // 시작일 선택
                      ListTile(
                        title: Text('시작일'),
                        subtitle: Text(_startDate == null ? '선택하세요' : 
                          '${_startDate!.year}년 ${_startDate!.month}월 ${_startDate!.day}일'),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () async {
                          final now = DateTime.now();
                          final lastDate = DateTime(now.year + 1, 12, 31); // 현재로부터 1년 후까지
                          
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? now,
                            firstDate: now,                // 오늘부터
                            lastDate: lastDate,            // 1년 후까지
                            locale: const Locale('ko', 'KR'),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Theme.of(context).primaryColor,
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          
                          if (date != null) {
                            setState(() => _startDate = date);
                          }
                        },
                      ),

                      // 공정 기간 설정
                      ListTile(
                        title: Text('공정 기간 (일)'),
                        subtitle: Slider(
                          value: _durationInDays.toDouble(),
                          min: 1,
                          max: 30,
                          divisions: 29,
                          label: '$_durationInDays일',
                          onChanged: (value) {
                            setState(() => _durationInDays = value.round());
                          },
                        ),
                      ),

                      // 종료일 표시 (자동 계산)
                      ListTile(
                        title: Text('종료일 (자동계산)'),
                        subtitle: Text(_endDate == null ? '-' :
                          '${_endDate!.year}-${_endDate!.month}-${_endDate!.day}'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              TextField(
                controller: _procedureController,
                decoration: InputDecoration(labelText: '업무절차'),
                maxLines: null,  // 여러 줄 입력 가능
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 프로젝트 생성 메서드
  void _createProject(BuildContext context) async {
    if (_formKey.currentState?.validate() == true && _startDate != null) {
      print('\n프로젝트 생성 시도:');
      
      // 현재 값들 출력
      print('widget.initialProcedure: ${widget.initialProcedure}');
      print('_procedureController.text: ${_procedureController.text}');
      
      // TaskTemplate 생성
      final template = TaskTemplate(
        category: widget.initialCategory ?? '',
        subCategory: widget.initialSubCategory ?? '',
        detail: widget.initialDetail ?? '',
        description: widget.initialDescription ?? '',
        manager: widget.initialManager ?? '',
        supervisor: widget.initialSupervisor ?? '',
        procedure: widget.initialProcedure ?? '',  // TextField의 값 대신 초기값 사용
      );

      print('\n생성된 템플릿:');
      print(template.toString());  // toString 메서드 사용

      try {
        await context.read<ProjectService>().createProject(template, _startDate!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로젝트가 생성되었습니다')),
        );
        Navigator.pop(context);
      } catch (e) {
        print('프로젝트 생성 에러: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로젝트 생성 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }
} 