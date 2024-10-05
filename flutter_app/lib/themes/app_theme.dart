import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFF7F8FA),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF4A90E2),
      secondary: Color(0xFF6495ED),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF666666)),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF1E1E1E),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF4A90E2),
      secondary: Color(0xFFB0C4DE),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFFF1F1F1),
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFB0B0B0)),
    ),
  );
}
