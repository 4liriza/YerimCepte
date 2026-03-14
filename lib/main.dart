import 'core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'features/home/screens/home_screen.dart';

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
      theme: AppTheme.lightTheme, // Hazırladığımız temayı bağladık
      home: const HomeScreen(),
    );
  }
}