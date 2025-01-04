import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_master_pro/controllers/auth/auth_controller.dart';

class RegisterScreen extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  
  final List<String> roles = ['PM', 'PE', 'Coordinator'];
  final RxString selectedRole = 'PM'.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '이름',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: '이메일',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                
                TextField(
                  controller: _departmentController,
                  decoration: InputDecoration(
                    labelText: '부서',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                
                Obx(() => DropdownButtonFormField<String>(
                  value: selectedRole.value,
                  decoration: InputDecoration(
                    labelText: '역할',
                    border: OutlineInputBorder(),
                  ),
                  items: roles.map((String role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      selectedRole.value = newValue;
                    }
                  },
                )),
                SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _authController.register(
                        email: _emailController.text,
                        password: _passwordController.text,
                        name: _nameController.text,
                        role: selectedRole.value,
                        department: _departmentController.text,
                      );
                    } catch (e) {
                      Get.snackbar(
                        '오류',
                        e.toString(),
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  child: Text('회원가입'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
                
                SizedBox(height: 16),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('이미 계정이 있으신가요? 로그인하기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 