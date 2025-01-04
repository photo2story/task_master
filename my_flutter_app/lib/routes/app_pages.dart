import 'package:get/get.dart';
import 'package:task_master_pro/constants/routes.dart';
import 'package:task_master_pro/screens/auth/login_screen.dart';
import 'package:task_master_pro/screens/auth/register_screen.dart';
import 'package:task_master_pro/screens/dashboard/dashboard_screen.dart';
import 'package:task_master_pro/screens/project/project_create_screen.dart';
import 'package:task_master_pro/screens/project/project_list_screen.dart';
import 'package:task_master_pro/screens/splash/splash_screen.dart';
import 'package:task_master_pro/middleware/auth_middleware.dart';
import 'package:task_master_pro/middleware/no_auth_middleware.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => SplashScreen(),
    ),
    GetPage(
      name: Routes.login,
      page: () => LoginScreen(),
      middlewares: [NoAuthMiddleware()],
    ),
    GetPage(
      name: Routes.register,
      page: () => RegisterScreen(),
      middlewares: [NoAuthMiddleware()],
    ),
    GetPage(
      name: Routes.dashboard,
      page: () => DashboardScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.projectList,
      page: () => ProjectListScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.projectCreate,
      page: () => ProjectCreateScreen(),
      middlewares: [AuthMiddleware()],
    ),
  ];
} 