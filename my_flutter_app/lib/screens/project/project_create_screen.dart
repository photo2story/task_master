import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_master_pro/constants/project_types.dart';
import 'package:csv/csv.dart';
import 'dart:html' as html;
import 'dart:convert';

class ProjectCreateScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _selectedCategory = ProjectCategory.humanResource.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새 프로젝트'),
        actions: [
          IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: () => _importFromCsv(context),
            tooltip: 'CSV 불러오기',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '프로젝트명',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '프로젝트명을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: '설명',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startDateController,
                      decoration: InputDecoration(
                        labelText: '시작일',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (date != null) {
                          _startDateController.text = 
                              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '시작일을 선택해주세요';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _endDateController,
                      decoration: InputDecoration(
                        labelText: '종료일',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        if (_startDateController.text.isEmpty) {
                          Get.snackbar(
                            '알림',
                            '시작일을 먼저 선택해주세요',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }
                        final startDate = DateTime.parse(_startDateController.text);
                        final date = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: startDate,
                          lastDate: startDate.add(Duration(days: 365)),
                        );
                        if (date != null) {
                          _endDateController.text = 
                              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '종료일을 선택해주세요';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<ProjectCategory>(
                value: _selectedCategory.value,
                decoration: InputDecoration(
                  labelText: '카테고리',
                  border: OutlineInputBorder(),
                ),
                items: ProjectCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _selectedCategory.value = value;
                  }
                },
              )),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: 프로젝트 생성 로직 구현
                    Get.back();
                  }
                },
                child: Text('프로젝트 생성'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _importFromCsv(BuildContext context) {
    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..accept = '.csv';
    input.click();

    input.onChange.listen((event) {
      final file = input.files!.first;
      final reader = html.FileReader();

      reader.onLoad.listen((event) {
        try {
          final String csvString = reader.result as String;
          final List<List<dynamic>> rows = 
              const CsvToListConverter().convert(csvString);

          // 헤더를 제외한 첫 번째 행만 처리
          if (rows.length > 1) {
            final row = rows[1];
            final category = row[0] as String;
            final classification = row[1] as String;
            final detail = row[2] as String;
            final procedure = row[3] as String;
            final content = row[4] as String;

            final now = DateTime.now();
            final year = now.year;
            final detailNumber = '001';  // 새 프로젝트는 항상 001
            final projectName = 
                '${category}_${classification}_${detail}_[${year}_$detailNumber]';

            final description = '[업무내용]\n$content\n\n[업무절차]\n$procedure';

            _nameController.text = projectName;
            _descriptionController.text = description;
            
            final projectCategory = _getCategoryFromString(category);
            if (projectCategory != null) {
              _selectedCategory.value = projectCategory;
            }

            Get.snackbar(
              '성공',
              'CSV 파일을 성공적으로 불러왔습니다.',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        } catch (e) {
          Get.snackbar(
            '오류',
            'CSV 파일 불러오기 실패: ${e.toString()}',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      });

      reader.readAsText(file);
    });
  }

  ProjectCategory? _getCategoryFromString(String category) {
    switch (category.toLowerCase()) {
      case '인사':
        return ProjectCategory.humanResource;
      case '급여':
        return ProjectCategory.payroll;
      case '채용':
        return ProjectCategory.recruitment;
      case '교육':
        return ProjectCategory.training;
      case '성과관리':
        return ProjectCategory.performance;
      default:
        return ProjectCategory.other;
    }
  }
} 