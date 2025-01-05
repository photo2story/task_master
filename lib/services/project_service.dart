import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../models/task_template.dart';
import 'database_service.dart';
import 'package:uuid/uuid.dart';
import 'csv_service.dart';

class ProjectService extends ChangeNotifier {
  final CsvService _csvService = CsvService();
  List<Project> _projects = [];

  List<Project> get projects => _projects;

  Future<void> loadProjects() async {
    _projects = await _csvService.fetchProjects();
    notifyListeners();
  }

  Future<void> createProject(Project project) async {
    _projects = [..._projects, project];
    notifyListeners();
  }

  Future<void> updateProject(Project project) async {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    _projects.removeWhere((p) => p.id == projectId);
    notifyListeners();
  }

  Future<Project> getProject(String projectId) async {
    return _projects.firstWhere((p) => p.id == projectId);
  }
} 