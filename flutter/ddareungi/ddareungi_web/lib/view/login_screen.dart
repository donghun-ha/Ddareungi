import 'package:ddareungi_web/model/responsive_config.dart';
import 'package:flutter/material.dart';
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
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.directions_bike,
                    size: 120,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: '아이디',
                      border: const OutlineInputBorder(),
                      prefixIcon:
                          Icon(Icons.email, color: colorScheme.secondary),
                      labelStyle:
                          TextStyle(color: colorScheme.onSurface, fontSize: 18),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: colorScheme.primary, width: 2),
                      ),
                    ),
                    style: const TextStyle(fontSize: 18),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      border: const OutlineInputBorder(),
                      prefixIcon:
                          Icon(Icons.lock, color: colorScheme.secondary),
                      labelStyle:
                          TextStyle(color: colorScheme.onSurface, fontSize: 18),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: colorScheme.primary, width: 2),
                      ),
                    ),
                    style: const TextStyle(fontSize: 18),
                    obscureText: true,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      // 로그인 로직
                    },
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
