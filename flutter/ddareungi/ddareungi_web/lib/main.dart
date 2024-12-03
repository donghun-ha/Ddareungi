import 'package:ddareungi_web/model/responsive_config.dart';
import 'package:ddareungi_web/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // ******Responsive******
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: ResponsiveConfig.breakpoints,
      ),
      // **********************
      title: '따릉이',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
