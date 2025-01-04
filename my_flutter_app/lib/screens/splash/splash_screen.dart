import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_master_pro/constants/routes.dart';
import 'package:task_master_pro/controllers/auth/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      print('[DEBUG] Checking authentication status...');
      await Future.delayed(Duration(seconds: 2));  // 최소 표시 시간
      
      if (_authController.isLoggedIn.value) {
        Get.offAllNamed(Routes.dashboard);
      } else {
        Get.offAllNamed(Routes.login);
      }
    } catch (e) {
      print('[ERROR] Auth check failed: $e');
      Get.offAllNamed(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
} 