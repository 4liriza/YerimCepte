import 'core/theme/app_theme.dart';
import 'package:flutter/material.dart'; 
import 'core/theme/app_theme.dart';

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
      home: const Placeholder(), // Şimdilik boş bir yer tutucu
    );
  }
}