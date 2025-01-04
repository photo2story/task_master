import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_master_pro/models/project/project.dart';
import 'package:task_master_pro/constants/routes.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'dart:math' as math;
import 'package:task_master_pro/controllers/project/project_controller.dart';
import 'package:http/http.dart' as http;
import 'package:task_master_pro/controllers/auth/auth_controller.dart';
import 'package:task_master_pro/services/api_service.dart';

class ProjectListScreen extends StatelessWidget {
  final ProjectController _projectController = Get.find<ProjectController>();

  @override
  Widget build(BuildContext context) {
    print('Building ProjectListScreen');
    return Scaffold(
      appBar: AppBar(
        title: Text('Project List'),
        actions: [
          IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: () {
              print('CSV import button clicked');
              _importFromCsv();
            },
            tooltip: 'Import CSV',
          ),
        ],
      ),
      body: Obx(() {
        print('Building Obx project list: ${_projectController.projects.length} items');
        return ListView.builder(
          itemCount: _projectController.projects.length,
          itemBuilder: (context, index) {
            final project = _projectController.projects[index];
            print('Building project card #$index: ${project.name}');
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
                        Chip(label: Text(project.manager)),
                      ],
                    ),
                  ],
                ),
                isThreeLine: true,
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  print('Project card clicked: ${project.name}');
                  // TODO: Navigate to project detail screen
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('New project button clicked');
          Get.toNamed(Routes.projectCreate);
        },
        child: Icon(Icons.add),
        tooltip: 'New Project',
      ),
    );
  }

  void _importFromCsv() async {
    print('\n[DEBUG] ===== Starting CSV Import Process =====');
    print('[DEBUG] Time: ${DateTime.now()}');
    
    try {
      final authController = Get.find<AuthController>();
      final currentToken = authController.token.value;
      print('[DEBUG] Token available: ${currentToken.isNotEmpty}');
      if (currentToken.isNotEmpty) {
        print('[DEBUG] Token preview: ${currentToken.substring(0, 20)}...');
      }
      
      if (currentToken.isEmpty) {
        print('[ERROR] No auth token available');
        throw Exception('Authentication token is missing');
      }
      
      print('[DEBUG] Making API request to fetch CSV file...');
      final response = await http.get(
        Uri.parse('${ApiService.apiUrl}/projects/csv'),
        headers: {
          'Authorization': 'Bearer $currentToken',
          'Accept': 'text/csv',
        },
      );
      
      print('[DEBUG] Response received');
      print('[DEBUG] Status code: ${response.statusCode}');
      print('[DEBUG] Headers: ${response.headers}');
      print('[DEBUG] Content length: ${response.contentLength}');
      
      if (response.statusCode == 200) {
        final csvData = response.body;
        print('[DEBUG] CSV data received (${csvData.length} bytes)');
        print('[DEBUG] First 200 chars: ${csvData.substring(0, math.min(200, csvData.length))}');
        
        print('[DEBUG] Passing data to ProjectController...');
        _projectController.importFromCsv(csvData);
        
        print('[DEBUG] CSV import completed successfully');
      } else {
        print('[ERROR] Failed to fetch CSV file');
        print('[ERROR] Status code: ${response.statusCode}');
        print('[ERROR] Response body: ${response.body}');
        throw Exception('Failed to load CSV file: ${response.statusCode}');
      }
      
    } catch (e, stackTrace) {
      print('[ERROR] ===== CSV Import Failed =====');
      print('[ERROR] Error type: ${e.runtimeType}');
      print('[ERROR] Error message: $e');
      print('[ERROR] Stack trace:');
      print(stackTrace);
      
      // Show error message to user
      Get.snackbar(
        'Error',
        'Failed to import CSV file: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      print('[DEBUG] ===== CSV Import Process Ended =====\n');
    }
  }
} 