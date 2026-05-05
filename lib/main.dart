import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vanguard/screens/auth/auth_screen.dart';
import 'package:vanguard/screens/home/home_screen.dart';
import 'package:vanguard/controllers/auth_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'VanguardNet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF000000),
        primaryColor: const Color(0xFFD32F2F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD32F2F),
          secondary: Color(0xFF4CAF50),
          surface: Color(0xFF1E1E1E),
        ),
      ),
      initialRoute: '/auth',
      getPages: [
        GetPage(
          name: '/auth',
          page: () => const AuthScreen(),
          binding: BindingsBuilder(() {
            Get.put(AuthController());
          }),
        ),
        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
          middlewares: [AuthMiddleware()],
        ),
      ],
    );
  }
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    if (authController.currentUser.value == null) {
      return const RouteSettings(name: '/auth');
    }
    return null;
  }
}

