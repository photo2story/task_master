import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_master_pro/controllers/auth/auth_controller.dart';
import 'package:task_master_pro/constants/routes.dart';

class DashboardScreen extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('대시보드'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: Text('로그아웃'),
                  content: Text('정말 로그아웃 하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        _authController.signOut();
                      },
                      child: Text('확인'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘의 할 일',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.task),
                title: Text('프로젝트 관리'),
                subtitle: Text('진행 중인 프로젝트: 0개'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => Get.toNamed(Routes.projectList),
              ),
            ),
            SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('일정 관리'),
                subtitle: Text('오늘의 일정: 0개'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: 캘린더로 이동
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.projectCreate),
        child: Icon(Icons.add),
        tooltip: '새 프로젝트',
      ),
    );
  }
} 