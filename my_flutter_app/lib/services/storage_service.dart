import 'dart:convert';
import 'package:task_master_pro/models/user/user.dart';
import 'package:get_storage/get_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  
  final _storage = GetStorage();
  static const String TOKEN_KEY = 'auth_token';
  static const String USER_KEY = 'user';
  static const String AUTO_LOGIN_KEY = 'auto_login';

  StorageService._internal();

  Future<void> init() async {
    await GetStorage.init();
  }

  // 토큰 저장
  Future<void> saveToken(String token) async {
    print('[DEBUG] Saving token: $token');
    await _storage.write(TOKEN_KEY, token);
    print('[DEBUG] Token saved successfully');
  }

  // 토큰 가져오기
  String? getToken() {
    final token = _storage.read<String>(TOKEN_KEY);
    print('[DEBUG] Retrieved token: $token');
    return token;
  }

  // 사용자 정보 저장
  Future<void> saveUser(User user) async {
    await _storage.write(USER_KEY, jsonEncode(user.toMap()));
  }

  // 사용자 정보 가져오기
  User? getUser() {
    final userStr = _storage.read<String>(USER_KEY);
    if (userStr == null) return null;
    return User.fromMap(jsonDecode(userStr));
  }

  // 로그아웃 (데이터 삭제)
  Future<void> clearAll() async {
    print('[DEBUG] Clearing all storage');
    await _storage.erase();
  }

  // 자동 로그인 설정 저장
  Future<void> setAutoLogin(bool value) async {
    print('[DEBUG] Setting auto login: $value');
    await _storage.write(AUTO_LOGIN_KEY, value);
  }

  // 자동 로그인 설정 가져오기
  bool getAutoLogin() {
    final autoLogin = _storage.read<bool>(AUTO_LOGIN_KEY) ?? false;
    print('[DEBUG] Auto login status: $autoLogin');
    return autoLogin;
  }
} 