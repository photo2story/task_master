import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import 'dashboard_screen.dart';

class UserLoginScreen extends StatefulWidget {
  @override
  _UserLoginScreenState createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('사용자 설정')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '사용자 이름',
                  hintText: '프로젝트 관리에 사용할 이름을 입력하세요',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return '사용자 이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    await context.read<UserService>().setUserName(_nameController.text);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => DashboardScreen()),
                    );
                  }
                },
                child: Text('시작하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 