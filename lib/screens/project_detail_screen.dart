import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import '../widgets/calendar_widget.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;
  final bool isNewProject;

  const ProjectDetailScreen({
    super.key, 
    required this.project,
    this.isNewProject = false,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  bool _isEditing = false;
  late Project _project;
  late TextEditingController _descriptionController;
  late TextEditingController _procedureController;
  late TextEditingController _updateNotesController;
  late String _status;
  late DateTime _startDate;
  late DateTime? _endDate;
  late String _projectName;

  // 상태별 아이콘 정의를 위한 맵 추가
  final Map<String, IconData> statusIcons = {
    '진행중': Icons.play_circle_outline,
    '완료': Icons.check_circle_outline,
    '보류': Icons.pause_circle_outline,
  };

  // 상태별 색상 정의
  final Map<String, Color> statusColors = {
    '진행중': Color(0xFF40A9FF),
    '완료': Colors.green,
    '보류': Colors.orange,
  };

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _descriptionController = TextEditingController(text: _project.description);
    _procedureController = TextEditingController(text: _project.procedure);
    _updateNotesController = TextEditingController(text: _project.updateNotes ?? '');
    _status = _project.status;
    _startDate = _project.startDate;
    _endDate = _project.endDate;
    _projectName = _project.name;
    
    // 새로운 프로젝트인 경우 자동으로 수정 모드로 전환
    if (widget.isNewProject) {
      _isEditing = true;
    }
  }

  // 날짜 포맷 메서드 추가
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // 프로젝트명 생성 메서드
  String _generateProjectName(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}_${widget.project.category}_${widget.project.subCategory}_${widget.project.detail}';
  }

  // 업데이트 내역 자동 생성
  void _addUpdateNote(String change) {
    final now = DateTime.now();
    final timestamp = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final newNote = '$timestamp\n변경내용: $change\n\n${_updateNotesController.text}';
    _updateNotesController.text = newNote;
  }

  // 즉시 저장이 필요한 필드 업데이트 (상태, 시작일)
  Future<void> _updateImmediately(Project updatedProject) async {
    try {
      await context.read<ProjectService>().updateProject(updatedProject);
      final refreshedProject = await context.read<ProjectService>().getProject(updatedProject.id);
      setState(() {
        _project = refreshedProject;
        _updateNotesController.text = refreshedProject.updateNotes ?? '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업데이트 실패: $e')),
      );
    }
  }

  // 저장 버튼으로 업데이트 (업무 내용, 업무 절차)
  Future<void> _updateWithSaveButton(
    Project updatedProject, 
    String? originalValue,
    String newValue,
    String fieldName,
  ) async {
    if (newValue != (originalValue ?? '')) {
      try {
        await context.read<ProjectService>().updateProject(updatedProject);
        final refreshedProject = await context.read<ProjectService>().getProject(updatedProject.id);
        setState(() {
          _project = refreshedProject;
          if (fieldName != '업데이트 내역') {
            _updateNotesController.text = refreshedProject.updateNotes ?? '';
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$fieldName이(가) 저장되었습니다.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('변경사항이 없습니다.')),
      );
    }
  }

  // 삭제 확인 다이얼로그
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('프로젝트 삭제'),
        content: Text('정말로 이 프로젝트를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await context.read<ProjectService>().deleteProject(widget.project.id);
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.pop(context); // 상세 화면 닫기
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('프로젝트가 삭제되었습니다')),
                );
              } catch (e) {
                Navigator.pop(context); // 다이얼로그 닫기
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('프로젝트 삭제 실패: $e')),
                );
              }
            },
            child: Text('삭제'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // 종료일 선택 다이얼로그
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate,
      lastDate: DateTime(2030),
    );

    if (picked != null && mounted) {
      final oldEndDate = _endDate != null ? _formatDate(_endDate!) : '미정';
      _addUpdateNote('종료일 $oldEndDate → ${_formatDate(picked)} 변경');

      final updatedProject = _project.copyWith(
        endDate: picked,
        updateNotes: _updateNotesController.text,
        updatedAt: DateTime.now(),
      );

      await _saveChanges(updatedProject);
      setState(() => _endDate = picked);
    }
  }

  // 종료일 제거 메서드 추가
  Future<void> _removeEndDate(BuildContext context) async {
    final oldEndDate = _endDate != null ? _formatDate(_endDate!) : '미정';
    _addUpdateNote('종료일 $oldEndDate → 미정 변경');

    final updatedProject = _project.copyWith(
      endDate: null,
      updateNotes: _updateNotesController.text,
      updatedAt: DateTime.now(),
    );

    await _saveChanges(updatedProject);
    setState(() => _endDate = null);
  }

  Future<void> _saveChanges(Project updatedProject) async {
    try {
      await context.read<ProjectService>().updateProject(updatedProject);
      setState(() {
        _project = updatedProject;  // 업데이트된 프로젝트로 바로 상태 업데이트
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('변경사항이 저장되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    }
  }

  Future<void> _refreshProject() async {
    try {
      final refreshedProject = await context.read<ProjectService>().getProject(_project.id);
      if (mounted && refreshedProject != null) {
        setState(() {
          _project = refreshedProject;
          _descriptionController.text = refreshedProject.description;
          _procedureController.text = refreshedProject.procedure;
          _updateNotesController.text = refreshedProject.updateNotes ?? '';
          _status = refreshedProject.status;
          _startDate = refreshedProject.startDate;
          _endDate = refreshedProject.endDate;
        });
      }
    } catch (e) {
      print('프로젝트 새로고침 실패: $e');
      // 실패해도 기존 상태 유지
    }
  }

  // 달력 위젯 수정
  Widget _buildCalendarWidget(DateTime? date, String label, {bool isStartDate = false}) {
    return Expanded(
      child: CalendarWidget(
        selectedDate: date,
        firstDate: isStartDate ? DateTime(2020) : _startDate,
        lastDate: DateTime(2030),
        label: label,
        isStartDate: isStartDate,
        onDateChanged: (DateTime newDate) {
          if (isStartDate) {
            if (newDate != _startDate) {
              final oldDate = _formatDate(_startDate);
              setState(() => _startDate = newDate);
              _addUpdateNote('시작일 $oldDate → ${_formatDate(newDate)} 변경');
              _updateImmediately(_project.copyWith(
                startDate: newDate,
                updateNotes: _updateNotesController.text,
                updatedAt: DateTime.now(),
              ));
            }
          } else {
            if (newDate != _endDate) {
              final oldDate = _endDate != null ? _formatDate(_endDate!) : '미정';
              setState(() => _endDate = newDate);
              _addUpdateNote('종료일 $oldDate → ${_formatDate(newDate)} 변경');
              _updateImmediately(_project.copyWith(
                endDate: newDate,
                updateNotes: _updateNotesController.text,
                updatedAt: DateTime.now(),
              ));
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _project.name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton.icon(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            label: Text(_isEditing ? '저장' : '수정'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
          SizedBox(width: 16),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기본 정보 카드 (맨 위로 이동)
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('프로젝트 정보', style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 16),
                    InfoRow(label: '구분', value: _project.category),
                    InfoRow(label: '분류', value: _project.subCategory),
                    InfoRow(label: '상세', value: _project.detail),
                    InfoRow(label: '담당자', value: _project.manager),
                    InfoRow(label: '관리자', value: _project.supervisor),
                    // 상태 드롭다운
                    Row(
                      children: [
                        SizedBox(width: 80, child: Text('상태', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                          child: _isEditing
                              ? Row(
                                  children: [
                                    for (final status in ['진행중', '완료', '보류'])
                                      Padding(
                                        padding: EdgeInsets.only(right: 12),
                                        child: InkWell(
                                          onTap: () {
                                            if (status != _status) {
                                              final oldStatus = _status;
                                              setState(() => _status = status);
                                              _addUpdateNote('상태 $oldStatus → $status 변경');
                                              _updateImmediately(_project.copyWith(
                                                status: status,
                                                updateNotes: _updateNotesController.text,
                                                updatedAt: DateTime.now(),
                                              ));
                                            }
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                statusIcons[status],
                                                color: _status == status 
                                                    ? statusColors[status] 
                                                    : Colors.grey,
                                                size: 16,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                status,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: _status == status 
                                                      ? statusColors[status] 
                                                      : Colors.grey,
                                                  fontWeight: _status == status 
                                                      ? FontWeight.bold 
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      statusIcons[_status],
                                      color: statusColors[_status],
                                      size: 16,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      _status,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: statusColors[_status],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                    if (_isEditing) ...[
                      SizedBox(height: 16),
                      // 달력 패널
                      SizedBox(
                        height: 320,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: IntrinsicWidth(
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 240,
                                    child: CalendarWidget(
                                      selectedDate: _startDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                      label: '시작일',
                                      isStartDate: true,
                                      onDateChanged: (DateTime newDate) {
                                        if (newDate != _startDate) {
                                          final oldDate = _formatDate(_startDate);
                                          setState(() => _startDate = newDate);
                                          _addUpdateNote('시작일 $oldDate → ${_formatDate(newDate)} 변경');
                                          _updateImmediately(_project.copyWith(
                                            startDate: newDate,
                                            updateNotes: _updateNotesController.text,
                                            updatedAt: DateTime.now(),
                                          ));
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  SizedBox(
                                    width: 240,
                                    child: CalendarWidget(
                                      selectedDate: _endDate,
                                      firstDate: _startDate,
                                      lastDate: DateTime(2030),
                                      label: '종료일',
                                      onDateChanged: (DateTime newDate) {
                                        if (newDate != _endDate) {
                                          final oldDate = _endDate != null ? _formatDate(_endDate!) : '미정';
                                          setState(() => _endDate = newDate);
                                          _addUpdateNote('종료일 $oldDate → ${_formatDate(newDate)} 변경');
                                          _updateImmediately(_project.copyWith(
                                            endDate: newDate,
                                            updateNotes: _updateNotesController.text,
                                            updatedAt: DateTime.now(),
                                          ));
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // 읽기 전용 모드에서는 텍스트로 표시
                      InfoRow(label: '시작일', value: _formatDate(_startDate)),
                      InfoRow(label: '종료일', value: _endDate != null ? _formatDate(_endDate!) : '미정'),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // 업무 내용 카드
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('업무 내용', style: Theme.of(context).textTheme.titleLarge),
                        if (_isEditing)
                          IconButton(
                            icon: Icon(Icons.save),
                            onPressed: () {
                              if (_descriptionController.text != _project.description) {
                                // 변경된 내용 비교하여 구체적인 변경 사항 기록
                                final oldDescription = _project.description;
                                final newDescription = _descriptionController.text;
                                
                                // 변경 내용 분석
                                String changeDetail = '';
                                if (newDescription.length > oldDescription.length) {
                                  final addedContent = newDescription.replaceAll(oldDescription, '').trim();
                                  if (addedContent.isNotEmpty) {
                                    changeDetail = '추가: $addedContent';
                                  }
                                } else if (newDescription.length < oldDescription.length) {
                                  final removedContent = oldDescription.replaceAll(newDescription, '').trim();
                                  if (removedContent.isNotEmpty) {
                                    changeDetail = '삭제: $removedContent';
                                  }
                                } else {
                                  changeDetail = '내용 수정';
                                }

                                _addUpdateNote('업무 내용 변경 - $changeDetail');

                                _updateWithSaveButton(
                                  _project.copyWith(
                                    description: _descriptionController.text,
                                    updateNotes: _updateNotesController.text,
                                    updatedAt: DateTime.now(),
                                  ),
                                  _project.description,
                                  _descriptionController.text,
                                  '업무 내용',
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('변경사항이 없습니다.')),
                                );
                              }
                            },
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    _isEditing
                        ? TextField(
                            controller: _descriptionController,
                            maxLines: null,
                            decoration: InputDecoration(border: OutlineInputBorder()),
                          )
                        : Text(_project.description),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // 업데 절차 카드
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('업무 절차', style: Theme.of(context).textTheme.titleLarge),
                        if (_isEditing)
                          IconButton(
                            icon: Icon(Icons.save),
                            onPressed: () {
                              if (_procedureController.text != _project.procedure) {
                                // 변경된 내용 비교하여 구체적인 변경 사항 기록
                                final oldProcedure = _project.procedure;
                                final newProcedure = _procedureController.text;
                                
                                // 변경 내용 분석
                                String changeDetail = '';
                                if (newProcedure.length > oldProcedure.length) {
                                  // 추가된 내용 찾기
                                  final addedContent = newProcedure.replaceAll(oldProcedure, '').trim();
                                  if (addedContent.isNotEmpty) {
                                    changeDetail = '추가: $addedContent';
                                  }
                                } else if (newProcedure.length < oldProcedure.length) {
                                  // 삭제된 내용 찾기
                                  final removedContent = oldProcedure.replaceAll(newProcedure, '').trim();
                                  if (removedContent.isNotEmpty) {
                                    changeDetail = '삭제: $removedContent';
                                  }
                                } else {
                                  changeDetail = '내용 수정';
                                }

                                // 업데이트 내역에 변경 사항 추가
                                _addUpdateNote('업무 절차 변경 - $changeDetail');

                                _updateWithSaveButton(
                                  _project.copyWith(
                                    procedure: _procedureController.text,
                                    updateNotes: _updateNotesController.text,  // 방금 추가한 업데이트 내역 포함
                                    updatedAt: DateTime.now(),
                                  ),
                                  _project.procedure,
                                  _procedureController.text,
                                  '업무 절차',
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('변경사항이 없습니다.')),
                                );
                              }
                            },
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    _isEditing
                        ? TextField(
                            controller: _procedureController,
                            maxLines: null,
                            decoration: InputDecoration(border: OutlineInputBorder()),
                          )
                        : Text(_project.procedure),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // 업데이트 내역 카드
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('업데이트 내역', style: Theme.of(context).textTheme.titleLarge),
                        if (_isEditing)
                          IconButton(
                            icon: Icon(Icons.save),
                            onPressed: () {
                              _updateWithSaveButton(
                                _project.copyWith(
                                  updateNotes: _updateNotesController.text,
                                  updatedAt: DateTime.now(),
                                ),
                                _project.updateNotes,
                                _updateNotesController.text,
                                '업데이트 내역',
                              );
                            },
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    _isEditing
                        ? TextField(
                            controller: _updateNotesController,
                            maxLines: null,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '수정 내역을 입력하세요',
                            ),
                          )
                        : Text(_project.updateNotes?.isEmpty ?? true 
                            ? '업데이트 내역이 없습니다.' 
                            : _project.updateNotes!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, 
              style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
} 