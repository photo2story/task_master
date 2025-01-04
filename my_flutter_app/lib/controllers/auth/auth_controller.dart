import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:task_master_pro/services/auth_service.dart';
import 'package:task_master_pro/constants/routes.dart';
import 'package:task_master_pro/services/storage_service.dart';
import 'package:task_master_pro/models/user/user.dart';
import 'package:task_master_pro/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final RxBool isLoggedIn = false.obs;
  final RxString token = ''.obs;
  final RxBool isLoading = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);
  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    checkAutoLogin();
  }

  Future<void> signInWithEmail(String email, String password, bool autoLogin) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      print('[DEBUG] Signing in with email: $email');
      final response = await ApiService().login(
        email: email,
        password: password,
      );
      
      print('[DEBUG] Login response received: $response');
      final newToken = response['token'];
      
      if (newToken != null) {
        print('[DEBUG] Token received: $newToken');
        await setLoginState(newToken);
        if (autoLogin) {
          await storage.write('token', newToken);
        }
        Get.offAllNamed(Routes.dashboard);
      } else {
        print('[DEBUG] No token received in response');
        errorMessage.value = '로그인에 실패했습니다.';
      }
    } catch (e) {
      print('[ERROR] Login failed: $e');
      errorMessage.value = '로그인에 실패했습니다.';
      Get.snackbar(
        '로그인 실패',
        errorMessage.value!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    // TODO: Implement Google Sign In
    throw UnimplementedError();
  }

  Future<void> signInWithApple() async {
    // TODO: Implement Apple Sign In
    throw UnimplementedError();
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String role,
    required String department,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      
      final user = await ApiService().register(
        email: email,
        password: password,
        name: name,
        role: role,
        department: department,
      );
      
      Get.snackbar(
        '성공',
        '회원가입이 완료되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      Get.offAllNamed(Routes.login);
    } catch (e) {
      errorMessage.value = e.toString();
      throw e;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkAutoLogin() async {
    print('[DEBUG] Checking auto login...');
    try {
      final savedToken = storage.read('token');
      if (savedToken != null) {
        print('[DEBUG] Found saved token: ${savedToken.substring(0, 20)}...');
        
        // 토큰 유효성 검사
        final isValid = await validateToken(savedToken);
        if (isValid) {
          print('[DEBUG] Token is valid, proceeding with auto login');
          await setLoginState(savedToken);
          return;
        } else {
          print('[DEBUG] Token is invalid, clearing saved data');
          await storage.remove('token');
        }
      } else {
        print('[DEBUG] No saved token found');
      }
      
      print('[DEBUG] Auto login is disabled');
      isLoggedIn.value = false;
      token.value = '';
      
    } catch (e) {
      print('[ERROR] Auto login error: $e');
      isLoggedIn.value = false;
      token.value = '';
    }
  }

  Future<bool> validateToken(String token) async {
    try {
      print('[DEBUG] Validating token...');
      final response = await ApiService().request(
        method: 'GET',
        path: '/auth/validate',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print('[DEBUG] Token validation successful');
      return true;
    } catch (e) {
      print('[DEBUG] Token validation failed: $e');
      return false;
    }
  }

  Future<void> setLoginState(String newToken) async {
    print('[DEBUG] Setting login state with token: ${newToken.substring(0, 20)}...');
    token.value = newToken;
    isLoggedIn.value = true;
    await storage.write('token', newToken);
    print('[DEBUG] Login state set successfully');
  }

  Future<void> logout() async {
    print('[DEBUG] Logging out...');
    token.value = '';
    isLoggedIn.value = false;
    await storage.remove('token');
    Get.offAllNamed(Routes.login);
    print('[DEBUG] Logout completed');
  }

  Future<void> signOut() async {
    await logout();  // 기존 logout 메서드 사용
  }
} 