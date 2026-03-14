import 'package:flutter/material.dart';

class AppTheme {
  // YerimCep Renk Paleti
  static const Color primaryColor = Color(0xFF6200EE); // Ana mor renk
  static const Color successColor = Colors.green;     // Boş masalar için
  static const Color errorColor = Colors.red;         // Dolu masalar için
  static const Color warningColor = Colors.orange;    // Moladaki masalar için

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: successColor,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}