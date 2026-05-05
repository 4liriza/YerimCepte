import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';

void main() {
  runApp(const YerimCepApp());
}

class YerimCepApp extends StatelessWidget {
  const YerimCepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YerimCep',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}