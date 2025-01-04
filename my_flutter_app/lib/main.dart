import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:task_master_pro/constants/routes.dart';
import 'package:task_master_pro/routes/app_pages.dart';
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
  await initServices();  // 서비스 초기화
  runApp(MyApp());
}

Future<void> initServices() async {
  print('[INIT] Starting services initialization...');
  
  // GetStorage 초기화
  await GetStorage.init();
  
  // 컨트롤러 초기화
  Get.put(AuthController(), permanent: true);
  Get.put(ProjectController(), permanent: true);
  
  print('[INIT] All services initialized');
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Task Master Pro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: Routes.splash,  // 스플래시 스크린으로 시작
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
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
