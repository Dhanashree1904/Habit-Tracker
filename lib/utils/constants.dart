import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Colors.black; // Blue
  static const Color accent = Colors.black87; // Light Blue
  static const Color background = Color(0xFFE8EAF6); // Deep black
  static const Color card = Color(0xFF1F1F1F); // Slightly lighter black
  static const Color textLight = Colors.black87;
  static const Color text = Color(0xFF1C1C1E);
  static const Color textDark = Colors.black45;
  static const Color hint = Colors.blueGrey;
  static const Color error = Color(0xFFEF5350); // Red
  static const Color success = Color(0xFF66BB6A); // Green
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.text,
  );

  static const TextStyle hint = TextStyle(
    fontSize: 14,
    fontStyle: FontStyle.italic,
    color: AppColors.hint,
  );

  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.accent,
  );

  static const TextStyle streak = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.success,
  );
}

class AppPadding {
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: 24, vertical: 18);
  static const EdgeInsets card = EdgeInsets.all(16);
}
