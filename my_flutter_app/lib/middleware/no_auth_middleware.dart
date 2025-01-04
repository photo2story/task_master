import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_master_pro/constants/routes.dart';
import 'package:task_master_pro/controllers/auth/auth_controller.dart';

class NoAuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    
    if (authController.isLoggedIn.value) {
      print('[DEBUG] User already authenticated, redirecting to dashboard');
      return RouteSettings(name: Routes.dashboard);
    }
    
    print('[DEBUG] User not authenticated, proceeding to $route');
    return null;
  }
} 