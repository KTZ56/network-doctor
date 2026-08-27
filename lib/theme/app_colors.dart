import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF06B6D4);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Dark Theme
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1A2332);

  // Light Theme
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;

  // Text
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Colors.white70;

  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);

  // Borders
  static const Color borderDark = Color(0xFF334155);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Dashboard Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFF87171)],
  );
}
