// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'services/project_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/database_service.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // 가로 모드 활성화
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MultiProvider(
      providers: [
        Provider(
          create: (_) => DatabaseService(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProjectService(),
        ),
      ],
      child: TaskMasterApp(),
    ),
  );
}

class TaskMasterApp extends StatelessWidget {
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
      home: DashboardScreen(),
    );
  }
}


// flutter run -d chrome