import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_master_pro/constants/routes.dart';
import 'package:task_master_pro/controllers/auth/auth_controller.dart';
import 'package:task_master_pro/controllers/project/project_controller.dart';
import 'package:task_master_pro/screens/auth/login_screen.dart';
import 'package:task_master_pro/screens/auth/register_screen.dart';
import 'package:task_master_pro/screens/dashboard/dashboard_screen.dart';
import 'package:task_master_pro/screens/project/project_create_screen.dart';
import 'package:task_master_pro/screens/project/project_list_screen.dart';
import 'package:task_master_pro/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // StorageService 초기화
  await StorageService().init();
  
  Get.put(AuthController());
  Get.put(ProjectController());
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Task Master Pro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: Routes.login,
      getPages: [
        GetPage(name: Routes.login, page: () => LoginScreen()),
        GetPage(name: Routes.register, page: () => RegisterScreen()),
        GetPage(name: Routes.dashboard, page: () => DashboardScreen()),
        GetPage(name: Routes.projectCreate, page: () => ProjectCreateScreen()),
        GetPage(name: Routes.projectList, page: () => ProjectListScreen()),
        // 다른 라우트들은 추후 추가
      ],
    );
  }
}


// flutter devices

// flutter run -d R3CX404VPHE
// flutter run --release -d R3CX404VPHE

// flutter clean
// flutter pub get
// flutter pub run build_runner build

// flutter run -d chrome

// flutter build apk --release

// flutter run -d web-server --wasm

// flutter build appbundle --release