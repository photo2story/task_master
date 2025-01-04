import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_master_pro/models/project/project.dart';
import 'package:task_master_pro/constants/routes.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'package:task_master_pro/controllers/project/project_controller.dart';

class ProjectListScreen extends StatelessWidget {
  final ProjectController _projectController = Get.find<ProjectController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로젝트 목록'),
        actions: [
          IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: _importFromCsv,
            tooltip: 'CSV 불러오기',
          ),
        ],
      ),
      body: Obx(() => ListView.builder(
        itemCount: _projectController.projects.length,
        itemBuilder: (context, index) {
          final project = _projectController.projects[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(project.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(project.content),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Chip(label: Text(project.category)),
                      SizedBox(width: 8),
                      Chip(label: Text(project.classification)),
                      SizedBox(width: 8),
                      Chip(label: Text(project.status)),
                    ],
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: 프로젝트 상세화면으로 이동
              },
            ),
          );
        },
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.projectCreate),
        child: Icon(Icons.add),
        tooltip: '새 프로젝트',
      ),
    );
  }

  void _importFromCsv() async {
    try {
      // static 폴더의 CSV 파일을 로드
      final String csvData = await rootBundle.loadString('packages/task_master_pro/static/task_list.csv');
      print('CSV 파일 로드 시도...');
      print('CSV 데이터: ${csvData.substring(0, 100)}...'); // 디버그용
      _projectController.importFromCsv(csvData);
    } catch (e) {
      print('CSV 파일 로드 실패: $e');
      // 파일 선택 다이얼로그로 폴백
      final html.FileUploadInputElement input = html.FileUploadInputElement()
        ..accept = '.csv';
      input.click();

      input.onChange.listen((event) {
        final file = input.files!.first;
        final reader = html.FileReader();

        reader.onLoad.listen((event) {
          final String csvData = reader.result as String;
          print('파일 선택 후 데이터: ${csvData.substring(0, 100)}...'); // 디버그용
          _projectController.importFromCsv(csvData);
        });

        reader.readAsText(file);
      });
    }
  }
} 