import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.darkBackground,

    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.darkSurface,
      error: AppColors.error,
    ),

    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),

    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      indicatorColor: AppColors.primary.withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    dividerColor: AppColors.borderDark,
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    scaffoldBackgroundColor: AppColors.lightBackground,

    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.lightSurface,
      error: AppColors.error,
    ),

    textTheme: GoogleFonts.interTextTheme(),

    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),

    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: AppColors.primary.withValues(alpha: 0.15),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    dividerColor: AppColors.borderLight,
  );
}
