import 'package:dio/dio.dart';
import 'package:task_master_pro/models/user/user.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  late final Dio _dio;
  final String baseUrl = 'http://127.0.0.1:5000/api';

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
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
      final response = await _dio.request(
        path,
        data: data,
        options: Options(
          method: method,
          headers: headers,
        ),
      );
      return response;
    } catch (e) {
      print('API 요청 실패: $e');
      throw e;
    }
  }

  // 로그인 요청
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await request(
      method: 'POST',
      path: '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    return response.data;
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
} 