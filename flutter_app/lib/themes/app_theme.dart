import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFF7F8FA), // Light background
    colorScheme: ColorScheme.light(
      primary: Color(0xFF4A90E2), // Primary blue color
      onPrimary: Colors.white, // Text/icon color on primary
      secondary: Color(0xFF6495ED), // Secondary lighter blue
      onSecondary: Colors.white, // Text/icon color on secondary
      surface: Colors.white, // Default surface color for cards, etc.
      onSurface: Color(0xFF333333), // Text color on surface
      background: Color(0xFFF7F8FA), // Background color
      onBackground: Color(0xFF666666), // Text color on background
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333), // Darker color for headings
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFF666666), // Lighter color for body text
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white, // Light card background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Color(0xFF4A90E2), // Button color matching primary
      textTheme: ButtonTextTheme.primary, // Button text color
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF1E1E1E), // Dark background
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF4A90E2), // Primary blue color
      onPrimary: Colors.white, // Text/icon color on primary
      secondary: Color(0xFFB0C4DE), // Secondary light blue
      onSecondary: Colors.black, // Text/icon color on secondary
      surface: Color(0xFF2E2E2E), // Dark surface color for cards, etc.
      onSurface: Color(0xFFF1F1F1), // Text color on surface
      background: Color(0xFF1E1E1E), // Dark background
      onBackground: Color(0xFFB0B0B0), // Text color on background
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFFF1F1F1), // Light color for headings
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFFB0B0B0), // Slightly muted color for body text
      ),
    ),
    cardTheme: CardTheme(
      color: Color(0xFF2E2E2E), // Dark card background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Color(0xFF4A90E2), // Button color matching primary
      textTheme: ButtonTextTheme.primary, // Button text color
    ),
  );
}
