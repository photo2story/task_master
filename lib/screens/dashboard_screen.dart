import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/project_list_widget.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/today_tasks_widget.dart';
import '../widgets/quick_input_widget.dart';
import '../services/project_service.dart';
import 'project_create_screen.dart';
import 'task_template_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 프로젝트 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectService>().loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Master'),
        actions: [
          IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskTemplateScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskTemplateScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // 모바일 레이아웃
              return Column(
                children: [
                  Expanded(
                    child: ProjectListWidget(),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: CalendarWidget(),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: TodayTasksWidget(),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: QuickInputWidget(),
                  ),
                ],
              );
            } else {
              // 데스크톱 레이아웃
              return Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ProjectListWidget(),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: CalendarWidget(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TodayTasksWidget(),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: QuickInputWidget(),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
} 