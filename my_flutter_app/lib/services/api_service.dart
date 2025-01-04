import 'package:dio/dio.dart';
import 'package:task_master_pro/models/user/user.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  late final Dio _dio;
  static const String baseUrl = 'http://127.0.0.1:5000';
  static const String apiUrl = '$baseUrl/api';

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: apiUrl,
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    if (true) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  // 일반적인 HTTP 요청 메서드
  Future<Response> request({
    required String method,
    required String path,
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      print('[DEBUG] Making API request:');
      print('[DEBUG] Method: $method');
      print('[DEBUG] Path: $path');
      print('[DEBUG] Headers: $headers');
      
      final response = await _dio.request(
        path,
        data: data,
        options: Options(
          method: method,
          headers: headers,
          validateStatus: (status) => status! < 500,  // 5xx 에러만 예외 처리
        ),
      );
      
      print('[DEBUG] Response status: ${response.statusCode}');
      print('[DEBUG] Response data: ${response.data}');
      
      if (response.statusCode! >= 400) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Request failed with status: ${response.statusCode}',
        );
      }
      
      return response;
    } catch (e) {
      print('[ERROR] API request failed: $e');
      rethrow;
    }
  }

  // 로그인 요청
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting login for email: $email');
      final response = await request(
        method: 'POST',
        path: '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      print('Login response: ${response.data}');
      return response.data;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // 회원가입
  Future<User> register({
    required String email,
    required String password,
    required String name,
    required String role,
    required String department,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'name': name,
        'role': role,
        'department': department,
      });

      return User.fromMap(response.data['user']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? '알 수 없는 오류가 발생했습니다.';
    }
    return '서버와 통신할 수 없습니다.';
  }

  // CSV 파일 가져오기
  static Future<String> fetchCsvFile(String token) async {
    try {
      print('[DEBUG] ===== Starting CSV File Request =====');
      final url = '$apiUrl/projects/csv';
      print('[DEBUG] Request URL: $url');
      print('[DEBUG] Using token: ${token.substring(0, 20)}...');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'text/csv',
        },
      );

      print('[DEBUG] Response status: ${response.statusCode}');
      print('[DEBUG] Response headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        print('[DEBUG] Response body length: ${response.body.length}');
        print('[DEBUG] First 100 chars: ${response.body.substring(0, math.min(100, response.body.length))}');
        return response.body;
      } else {
        print('[ERROR] Request failed with status: ${response.statusCode}');
        print('[ERROR] Response body: ${response.body}');
        throw Exception('Failed to load CSV file: ${response.statusCode}');
      }
    } catch (e) {
      print('[ERROR] Request error: $e');
      rethrow;
    }
  }
} 