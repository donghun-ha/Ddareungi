import 'package:ddareungi_web/utils/responsive_config.dart';
import 'package:ddareungi_web/view/rebalance_ai.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:ddareungi_web/constants/color.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 레이아웃
          ResponsiveBreakpoints.builder(
            breakpoints: ResponsiveConfig.breakpoints,
            child: Center(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 왼쪽 절반: 이미지
                    Expanded(
                      flex: 1,
                      child: Image.asset(
                        "images/ddareungi.png",
                        fit: BoxFit.cover, // 이미지를 가득 채움
                        height: MediaQuery.of(context).size.height, // 화면 높이에 맞춤
                      ),
                    ),
                    // 오른쪽 절반: 로그인 폼
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 32), // 상단 여백
                            loginFunctions(context), // 입력 필드 및 버튼
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 왼쪽 상단 로고
          Positioned(
            top: 16,
            left: 16,
            child: Image.asset(
              "images/logo.png",
              width: MediaQuery.of(context).size.width * 0.2, // 적절한 크기로 조정
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      backgroundColor: backClr,
    );
  }

  // Functions
  Widget loginFunctions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 이메일 입력 필드
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'User Name',
            prefixIcon: Icon(
              Icons.email,
              color: logintxtClr,
            ),
            labelStyle: TextStyle(
              fontSize: 18,
              color: logintxtClr,
            ),
          ),
          style: const TextStyle(fontSize: 18),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 80), // 입력 필드 간 간격
        // 비밀번호 입력 필드
        TextFormField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(
              Icons.lock_outline,
              color: logintxtClr,
            ),
            labelStyle: TextStyle(
              fontSize: 18,
              color: logintxtClr,
            ),
          ),
          style: const TextStyle(
            fontSize: 18,
          ),
          obscureText: true,
        ),
        const SizedBox(height: 100), // 버튼 위 간격
        // 로그인 버튼
        ElevatedButton(
          onPressed: () {
            Get.off(() => const RebalanceAi(),
                transition: Transition.noTransition);
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
      ],
    );
  }
}
