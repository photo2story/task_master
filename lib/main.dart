// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'services/project_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/database_service.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/user_service.dart';
import 'services/csv_service.dart';
import 'screens/user_login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 웹과 네이티브 모두에서 작동하도록 수정
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('환경 변수 로드 실패: $e');
    // 기본값 설정 또는 에러 처리
  }

  // 가로 모드 활성화
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);

  final prefs = await SharedPreferences.getInstance();
  final userService = UserService(prefs);
  final csvService = CsvService(userService);
  await csvService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<UserService>(create: (_) => userService),
        Provider<CsvService>(create: (_) => csvService),
        ChangeNotifierProvider<ProjectService>(
          create: (context) => ProjectService(csvService),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Master',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        cardTheme: CardTheme(
          elevation: 2,
          margin: EdgeInsets.all(8),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        cardTheme: CardTheme(
          elevation: 2,
          margin: EdgeInsets.all(8),
          color: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
          surface: Colors.black,
          background: Colors.black,
        ),
        listTileTheme: ListTileThemeData(
          tileColor: Colors.transparent,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.dark,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ko', 'KR'),
        const Locale('en', 'US'),
      ],
      locale: const Locale('ko', 'KR'),
      home: context.watch<UserService>().isLoggedIn
          ? DashboardScreen()
          : UserLoginScreen(),
    );
  }
}


// flutter run -d chrome