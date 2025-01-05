import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project.dart';
import '../config/database_config.dart';

class DatabaseService {
  final String baseUrl = DatabaseConfig.projectsUrl;

  Future<void> insertProject(Project project) async {
    try {
      print('\n프로젝트 저장 시도:');
      print('URL: $baseUrl');
      print('프로젝트명: ${project.name}');
      print('업무절차: ${project.procedure}');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'id': project.id,
          'name': project.name,
          'category': project.category,
          'subcategory': project.subCategory,
          'detail': project.detail,
          'description': project.description,
          'manager': project.manager,
          'supervisor': project.supervisor,
          'procedure': project.procedure,
          'startDate': project.startDate.toIso8601String(),
          'status': project.status,
          'createdAt': project.createdAt.toIso8601String(),
          'updatedAt': project.updatedAt.toIso8601String(),
        }),
      );

      print('서버 응답: ${response.statusCode}');
      print('응답 내용: ${response.body}');

      if (response.statusCode == 201) {
        print('프로젝트 저장 완료');
      } else {
        throw Exception('프로젝트 저장 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('프로젝트 저장 에러: $e');
      rethrow;
    }
  }

  Future<List<Project>> getProjects() async {
    try {
      print('\n프로젝트 목록 조회 시도');
      final response = await http.get(Uri.parse(baseUrl));
      
      print('서버 응답: ${response.statusCode}');
      print('응답 내용: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        
        print('조회된 프로젝트 수: ${jsonList.length}');
        
        return jsonList.map((json) => Project(
          id: json['id'],
          name: json['name'],
          category: json['category'],
          subCategory: json['subcategory'],
          detail: json['detail'],
          description: json['description'],
          manager: json['manager'],
          supervisor: json['supervisor'],
          procedure: json['procedure'] ?? '',
          startDate: DateTime.parse(json['start_date']),
          status: json['status'],
          createdAt: DateTime.parse(json['created_at']),
          updatedAt: DateTime.parse(json['updated_at']),
        )).toList();
      } else {
        throw Exception('프로젝트 목록 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('프로젝트 목록 조회 에러: $e');
      rethrow;
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      print('\n프로젝트 수정 시도:');
      print('URL: $baseUrl/${project.id}');
      print('프로젝트명: ${project.name}');

      final response = await http.put(
        Uri.parse('$baseUrl/${project.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': project.name,
          'category': project.category,
          'subcategory': project.subCategory,
          'detail': project.detail,
          'description': project.description,
          'manager': project.manager,
          'supervisor': project.supervisor,
          'procedure': project.procedure,
          'startDate': project.startDate.toIso8601String(),
          'status': project.status,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('프로젝트 수정 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('프로젝트 수정 에러: $e');
      rethrow;
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      print('\n프로젝트 삭제 시도:');
      print('URL: $baseUrl/$projectId');

      final response = await http.delete(
        Uri.parse('$baseUrl/$projectId'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('프로젝트 삭제 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('프로젝트 삭제 에러: $e');
      rethrow;
    }
  }
} 