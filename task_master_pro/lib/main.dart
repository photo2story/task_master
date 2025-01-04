// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'services/project_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectService()),
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
        primarySwatch: Colors.blue,
        cardTheme: CardTheme(
          elevation: 2,
          margin: EdgeInsets.all(8),
        ),
      ),
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