import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_master_pro/constants/routes.dart';
import 'package:task_master_pro/controllers/auth/auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    
    if (!authController.isLoggedIn.value) {
      print('[DEBUG] User not authenticated, redirecting to login');
      return RouteSettings(name: Routes.login);
    }
    
    print('[DEBUG] User authenticated, proceeding to $route');
    return null;
  }
} 