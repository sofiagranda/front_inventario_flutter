import 'package:flutter/material.dart';

class AppColors {
  static const Color slate950 = Color(0xFF020617);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color cyan400 = Color(0xFF22D3EE); // El cian neón de Tailwind
  static const Color cyan600 = Color(0xFF0891B2);
  static const Color cyan500 = Color(0xFF06B6D4);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color slate400 = Color(0xFF94A3B8); // El que te faltaba
}

class AppTheme {
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.slate950,
    cardColor: AppColors.slate900,
    dividerColor: AppColors.slate800,
    primaryColor: AppColors.cyan600,
    
    // Estilo para los Inputs (como tus inputs de React)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.slate900.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.slate800),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cyan500),
      ),
    ),
  );
}