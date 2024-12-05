import 'package:ddareungi_web/vm/login_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ddareungi_web/utils/responsive_config.dart';
import 'package:ddareungi_web/constants/color.dart';
import 'package:responsive_framework/responsive_framework.dart';

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final LoginHandler loginHandler = Get.put(LoginHandler()); // GetX 컨트롤러 등록

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ResponsiveBreakpoints.builder(
            breakpoints: ResponsiveConfig.breakpoints,
            child: Center(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 왼쪽 이미지
                    Expanded(
                      flex: 1,
                      child: Image.asset(
                        "images/ddareungi.png",
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.height,
                      ),
                    ),
                    // 오른쪽 폼
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 32),
                            _buildLoginFields(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 상단 로고
          Positioned(
            top: 16,
            left: 16,
            child: Image.asset(
              "images/logo.png",
              width: MediaQuery.of(context).size.width * 0.2,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      backgroundColor: backClr,
    );
  }

  Widget _buildLoginFields() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ID 입력
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'User Name',
              prefixIcon: Icon(Icons.email, color: logintxtClr),
              labelStyle: TextStyle(fontSize: 18, color: logintxtClr),
            ),
            style: const TextStyle(fontSize: 18),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 80),
          // 비밀번호 입력
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline, color: logintxtClr),
              labelStyle: TextStyle(fontSize: 18, color: logintxtClr),
            ),
            style: const TextStyle(fontSize: 18),
            obscureText: true,
          ),
          const SizedBox(height: 100),
          // 로그인 버튼
          loginHandler.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: () {
                    loginHandler.login(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: loginbuttonClr,
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: loginbuttontxtClr,
                    ),
                  ),
                ),
          // 에러 메시지
          if (loginHandler.errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                loginHandler.errorMessage.value,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      );
    });
  }
}
