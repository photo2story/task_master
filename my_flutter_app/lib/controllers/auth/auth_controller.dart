import 'package:get/get.dart';
import 'package:task_master_pro/services/auth_service.dart';
import 'package:task_master_pro/constants/routes.dart';
import 'package:task_master_pro/services/storage_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final StorageService _storage = StorageService();
  
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    errorMessage.value = null;  // 초기화 시 에러 메시지 클리어
    checkAutoLogin();  // 앱 시작 시 자동 로그인 체크
  }

  Future<void> checkAutoLogin() async {
    if (_storage.getAutoLogin()) {
      final token = _storage.getToken();
      if (token != null) {
        try {
          // 토큰 유효성 검증
          final success = await _authService.validateToken(token);
          if (success) {
            isLoggedIn.value = true;
            Get.offAllNamed(Routes.dashboard);
          }
        } catch (e) {
          print('자동 로그인 실패: $e');
        }
      }
    }
  }

  // 이메일/비밀번호 로그인
  Future<void> signInWithEmail(String email, String password, bool autoLogin) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final response = await _authService.signInWithEmail(email, password);
      
      if (response.token != null) {
        // 토큰 저장
        await _storage.saveToken(response.token!);
        // 자동 로그인 설정 저장
        await _storage.setAutoLogin(autoLogin);
        
        isLoggedIn.value = true;
        Get.offAllNamed(Routes.dashboard);
      } else {
        errorMessage.value = '로그인에 실패했습니다.';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Google 로그인
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final success = await _authService.signInWithGoogle();
      if (success) {
        isLoggedIn.value = true;
        Get.offAllNamed(Routes.dashboard);
      } else {
        errorMessage.value = 'Google 로그인에 실패했습니다.';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Apple 로그인
  Future<void> signInWithApple() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final success = await _authService.signInWithApple();
      if (success) {
        isLoggedIn.value = true;
        Get.offAllNamed(Routes.dashboard);
      } else {
        errorMessage.value = 'Apple 로그인에 실패했습니다.';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String role,
    required String department,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final user = await _authService.register(
        email: email,
        password: password,
        name: name,
        role: role,
        department: department,
      );
      
      // 회원가입 성공 시 자동 로그인
      isLoggedIn.value = true;
      Get.offAllNamed(Routes.dashboard);
      Get.snackbar(
        '성공',
        '회원가입이 완료되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      throw e;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _storage.setAutoLogin(false);  // 자동 로그인 해제
      await _storage.clearAll();  // 저장된 데이터 모두 삭제
      isLoggedIn.value = false;
      Get.offAllNamed(Routes.login);
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }
} 