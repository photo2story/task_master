import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:task_master_pro/models/project/project.dart';
import 'package:csv/csv.dart';

class ProjectController extends GetxController {
  final RxList<Project> projects = <Project>[].obs;

  void importFromCsv(String csvData) {
    print('[DEBUG] ===== Starting CSV Parsing =====');
    try {
      print('[DEBUG] CSV data received. Length: ${csvData.length}');
      print('[DEBUG] First line of CSV:');
      print(csvData.split('\n').first);

      // Parse CSV data
      List<List<dynamic>> rowsAsListOfValues = 
        const CsvToListConverter().convert(csvData);
      
      print('[DEBUG] CSV parsed into ${rowsAsListOfValues.length} rows');
      print('[DEBUG] Headers: ${rowsAsListOfValues[0]}');
      
      if (rowsAsListOfValues.length > 1) {
        List<List<dynamic>> dataRows = rowsAsListOfValues.sublist(1);
        print('[DEBUG] Data rows count: ${dataRows.length}');
        
        // Clear existing projects
        projects.clear();
        print('[DEBUG] Cleared existing projects');
        
        // Convert CSV data to Project objects
        for (var row in dataRows) {
          try {
            print('[DEBUG] Processing row: $row');
            if (row.length >= 7) {
              Project project = Project(
                category: row[0].toString(),
                classification: row[1].toString(),
                detail: row[2].toString(),
                content: row[3].toString(),
                manager: row[4].toString(),
                supervisor: row[5].toString(),
                procedure: row[6].toString(),
              );
              projects.add(project);
              print('[DEBUG] Added project: ${project.name}');
            } else {
              print('[WARN] Skipping row - insufficient columns: $row');
            }
          } catch (e) {
            print('[ERROR] Failed to parse row: $row');
            print('[ERROR] Error: $e');
          }
        }
        print('[DEBUG] Total projects imported: ${projects.length}');
      }
      print('[DEBUG] ===== CSV Parsing Completed =====');
    } catch (e) {
      print('[ERROR] ===== CSV Parsing Failed =====');
      print('[ERROR] Error type: ${e.runtimeType}');
      print('[ERROR] Error message: $e');
      Get.snackbar(
        'Error',
        'Failed to import CSV file: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }
} 