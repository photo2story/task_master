import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../services/project_service.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

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
  late String _projectName;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _descriptionController = TextEditingController(text: _project.description);
    _procedureController = TextEditingController(text: _project.procedure);
    _updateNotesController = TextEditingController(text: _project.updateNotes ?? '');
    _status = _project.status;
    _startDate = _project.startDate;
    _projectName = _project.name;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_project.name),
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
                              ? DropdownButton<String>(
                                  value: _status,
                                  items: ['진행중', '완료', '보류'].map((String value) {
                                    return DropdownMenuItem<String>(value: value, child: Text(value));
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null && newValue != _status) {
                                      final oldStatus = _status;
                                      setState(() => _status = newValue);
                                      _addUpdateNote('상태 $oldStatus → $newValue 변경');
                                      _updateImmediately(_project.copyWith(
                                        status: newValue,
                                        updateNotes: _updateNotesController.text,
                                        updatedAt: DateTime.now(),
                                      ));
                                    }
                                  },
                                )
                              : Text(_status),
                        ),
                      ],
                    ),
                    // 시작일
                    Row(
                      children: [
                        SizedBox(width: 80, child: Text('시작일', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                          child: _isEditing
                              ? TextButton(
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _startDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                    );
                                    if (picked != null && picked != _startDate) {
                                      final oldDate = _formatDate(_startDate);
                                      setState(() => _startDate = picked);
                                      _addUpdateNote('시작일 $oldDate → ${_formatDate(picked)} 변경');
                                      _updateImmediately(_project.copyWith(
                                        startDate: picked,
                                        updateNotes: _updateNotesController.text,
                                        updatedAt: DateTime.now(),
                                      ));
                                    }
                                  },
                                  child: Text(_formatDate(_startDate), style: TextStyle(color: Colors.blue)),
                                )
                              : Text(_formatDate(_project.startDate)),
                        ),
                      ],
                    ),
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
                        Text('업데 절차', style: Theme.of(context).textTheme.titleLarge),
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