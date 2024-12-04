import 'package:ddareungi_web/model/responsive_config.dart';
import 'package:ddareungi_web/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('따릉고', style: TextStyle(fontSize: 24)),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: ResponsiveBreakpoints.builder(
        breakpoints: ResponsiveConfig.breakpoints,
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.directions_bike,
                    size: _getIconSize(context),
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 48),
                  _buildTextFormField(
                    controller: emailController,
                    label: '아이디',
                    prefixIcon: Icons.email,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 24),
                  _buildTextFormField(
                    controller: passwordController,
                    label: '비밀번호',
                    prefixIcon: Icons.lock,
                    colorScheme: colorScheme,
                    obscureText: true,
                  ),
                  const SizedBox(height: 32),
                  _buildLoginButton(
                    onPressed: () {
                      Get.to(() => const HomeScreen(),
                          transition: Transition.noTransition);
                    },
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _getIconSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return 80; // 모바일
    } else if (screenWidth < 1200) {
      return 100; // 태블릿
    }
    return 120; // 데스크톱
  }

  _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    required ColorScheme colorScheme,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(prefixIcon, color: colorScheme.secondary),
        labelStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      style: const TextStyle(fontSize: 18),
      keyboardType: obscureText
          ? TextInputType.visiblePassword
          : TextInputType.emailAddress,
      obscureText: obscureText,
    );
  }

  _buildLoginButton({
    required VoidCallback onPressed,
    required ColorScheme colorScheme,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        '로그인',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
