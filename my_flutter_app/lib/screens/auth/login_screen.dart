import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_master_pro/controllers/auth/auth_controller.dart';
import 'package:task_master_pro/constants/routes.dart';

class LoginScreen extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RxBool _autoLogin = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() => Stack(
            children: [
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Task Master Pro',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      if (_authController.errorMessage.value != null)
                        Container(
                          padding: EdgeInsets.all(8),
                          margin: EdgeInsets.only(bottom: 16),
                          color: Colors.red.shade100,
                          child: Text(
                            _authController.errorMessage.value!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: '이메일',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이메일을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: '비밀번호',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      Obx(() => CheckboxListTile(
                        title: Text('자동 로그인'),
                        value: _autoLogin.value,
                        onChanged: (value) {
                          _autoLogin.value = value ?? false;
                        },
                      )),
                      
                      ElevatedButton(
                        onPressed: _authController.isLoading.value
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  _authController.signInWithEmail(
                                    _emailController.text,
                                    _passwordController.text,
                                    _autoLogin.value,
                                  );
                                }
                              },
                        child: Text('로그인'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('또는'),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      OutlinedButton.icon(
                        onPressed: _authController.isLoading.value
                            ? null
                            : _authController.signInWithGoogle,
                        icon: Icon(Icons.g_mobiledata),
                        label: Text('Google로 계속하기'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      if (Theme.of(context).platform == TargetPlatform.iOS)
                        OutlinedButton.icon(
                          onPressed: _authController.isLoading.value
                              ? null
                              : _authController.signInWithApple,
                          icon: Icon(Icons.apple),
                          label: Text('Apple로 계속하기'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                          ),
                        ),
                      TextButton(
                        onPressed: () => Get.toNamed(Routes.register),
                        child: Text('계정이 없으신가요? 회원가입하기'),
                      ),
                    ],
                  ),
                ),
              ),
              if (_authController.isLoading.value)
                Container(
                  color: Colors.black26,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          )),
        ),
      ),
    );
  }
} 