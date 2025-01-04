import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:task_master_pro/models/user/user.dart';
import 'package:task_master_pro/services/api_service.dart';
import 'package:task_master_pro/services/storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();
  
  AuthService._internal();

  // 회원가입
  Future<User> register({
    required String email,
    required String password,
    required String name,
    required String role,
    required String department,
  }) async {
    return await _apiService.register(
      email: email,
      password: password,
      name: name,
      role: role,
      department: department,
    );
  }

  // 이메일/비밀번호 로그인
  Future<LoginResponse> signInWithEmail(String email, String password) async {
    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );
      return LoginResponse(
        token: response['token'],
        user: User.fromMap(response['user']),
      );
    } catch (e) {
      print('로그인 실패: $e');
      throw e;
    }
  }

  // Google 로그인
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return false;
      
      // TODO: Flask 서버와 연동하여 토큰 검증
      return true;
    } catch (e) {
      print('Google 로그인 실패: $e');
      return false;
    }
  }

  // Apple 로그인 (iOS only)
  Future<bool> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      // TODO: Flask 서버와 연동하여 토큰 검증
      return true;
    } catch (e) {
      print('Apple 로그인 실패: $e');
      return false;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      // 로컬 스토리지의 토큰 삭제
      await _storage.clearAll();
      return;
    } catch (e) {
      print('로그아웃 실패: $e');
      throw e;
    }
  }

  Future<bool> validateToken(String token) async {
    try {
      final response = await _apiService.request(
        method: 'GET',
        path: '/auth/validate',
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('토큰 검증 실패: $e');
      return false;
    }
  }
}

// 로그인 응답 클래스 추가
class LoginResponse {
  final String? token;
  final User? user;

  LoginResponse({this.token, this.user});
} 