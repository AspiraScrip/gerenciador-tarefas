import 'package:flutter/material.dart';

class AppTheme {
  static const Color _semente = Color(0xFF3F51B5);

  static ThemeData _base(Brightness brilho) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _semente,
        brightness: brilho,
      ),
      appBarTheme: const AppBarTheme(centerTitle: true),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
        ),
      ),
    );
  }

  static final ThemeData lightTheme = _base(Brightness.light);
  static final ThemeData darkTheme = _base(Brightness.dark);
}
