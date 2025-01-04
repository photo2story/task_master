import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:task_master_pro/models/user/user.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  
  late final SharedPreferences _prefs;
  
  StorageService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 토큰 저장
  Future<void> saveToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  // 토큰 가져오기
  String? getToken() {
    return _prefs.getString('auth_token');
  }

  // 사용자 정보 저장
  Future<void> saveUser(User user) async {
    await _prefs.setString('user', jsonEncode(user.toMap()));
  }

  // 사용자 정보 가져오기
  User? getUser() {
    final userStr = _prefs.getString('user');
    if (userStr == null) return null;
    return User.fromMap(jsonDecode(userStr));
  }

  // 로그아웃 (데이터 삭제)
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // 자동 로그인 설정 저장
  Future<void> setAutoLogin(bool value) async {
    await _prefs.setBool('auto_login', value);
  }

  // 자동 로그인 설정 가져오기
  bool getAutoLogin() {
    return _prefs.getBool('auto_login') ?? false;
  }
} 