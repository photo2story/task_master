import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project.dart';
import '../config/database_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';

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
          updateNotes: json['update_notes'] ?? '',
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
          'updateNotes': project.updateNotes,
        }),
      );

      print('서버 응답: ${response.statusCode}');
      print('응답 내용: ${response.body}');

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

  Future<Project> getProject(String projectId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$projectId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Project(
          id: data['id'],
          name: data['name'],
          category: data['category'],
          subCategory: data['subcategory'],
          detail: data['detail'],
          description: data['description'],
          manager: data['manager'],
          supervisor: data['supervisor'],
          procedure: data['procedure'],
          startDate: DateTime.parse(data['start_date']),
          status: data['status'],
          createdAt: DateTime.parse(data['created_at']),
          updatedAt: DateTime.parse(data['updated_at']),
          updateNotes: data['update_notes'] ?? '',
        );
      } else {
        throw Exception('프로젝트 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('프로젝트 조회 에러: $e');
      rethrow;
    }
  }

  Future<String> loadCsvData() async {
    try {
      final csvUrl = dotenv.env['CSV_URL'] ?? 
        'https://raw.githubusercontent.com/photo2story/my-flutter-app/main/static/images/stock_market.csv';
      
      print('CSV 로드 시도: $csvUrl');
      final response = await http.get(Uri.parse(csvUrl));
      
      if (response.statusCode == 200) {
        print('CSV 로드 성공');
        return response.body;
      } else {
        print('CSV 로드 실패: ${response.statusCode}');
        throw Exception('CSV 로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('CSV 파일 로드 에러: $e');
      throw e;
    }
  }
} 