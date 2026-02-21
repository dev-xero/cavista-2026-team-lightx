import 'package:flutter/material.dart';

import 'src/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Scaffold
    scaffoldBackgroundColor: const Color(0xFFF2F2F2),

    // // AppBar
    // appBarTheme: const AppBarTheme(
    //   backgroundColor: AppColors.primary,
    //   foregroundColor: AppColors.neutralWhite50,
    //   elevation: 0,
    //   centerTitle: true,
    //   iconTheme: IconThemeData(color: AppColors.neutralWhite50),
    // ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.neutralWhite100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.neutralBlack200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.neutralBlack200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.red500),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.neutralWhite50,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.neutralWhite50,
      elevation: 4,
    ),

    // Divider
    dividerTheme: const DividerThemeData(color: AppColors.neutralBlack200, thickness: 1, space: 1),

    // Icon
    iconTheme: const IconThemeData(color: AppColors.neutralBlack700, size: 24),
    fontFamily: "Manrope",

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 128, // 8rem
        height: 1.0, // 8rem / 8rem
        fontWeight: FontWeight.w600,
        color: AppColors.neutralBlack900,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 96, // 6rem
        height: 1.0, // 6rem / 6rem
        fontWeight: FontWeight.w600,
        color: AppColors.neutralBlack900,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 72, // 4.5rem
        height: 1.0, // 4.5rem / 4.5rem
        fontWeight: FontWeight.w600,
        color: AppColors.neutralBlack900,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 60, // 3.75rem
        height: 1.0, // 3.75rem / 3.75rem
        fontWeight: FontWeight.w600,
        color: AppColors.neutralBlack900,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 48, // 3rem
        height: 1.0, // 3rem / 3rem
        fontWeight: FontWeight.w600,
        color: AppColors.neutralBlack900,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 36, // 2.25rem
        height: 1.111, // 2.5rem / 2.25rem
        fontWeight: FontWeight.w600,
        color: AppColors.neutralBlack900,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 30, // 1.875rem
        height: 1.2, // 2.25rem / 1.875rem
        fontWeight: FontWeight.w600,
        color: AppColors.neutralBlack900,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 24, // 1.5rem
        height: 1.333, // 2rem / 1.5rem
        fontWeight: FontWeight.w500,
        color: AppColors.neutralBlack900,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 20, // 1.25rem
        height: 1.4, // 1.75rem / 1.25rem
        fontWeight: FontWeight.w500,
        color: AppColors.neutralBlack900,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 18, // 1.125rem
        height: 1.556, // 1.75rem / 1.125rem
        fontWeight: FontWeight.w400,
        color: AppColors.neutralBlack800,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 16, // 1rem
        height: 1.5, // 1.5rem / 1rem
        fontWeight: FontWeight.w400,
        color: AppColors.neutralBlack800,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 14, // 0.875rem
        height: 1.429, // 1.25rem / 0.875rem
        fontWeight: FontWeight.w400,
        color: AppColors.neutralBlack700,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 14, // 0.875rem
        height: 1.429, // 1.25rem / 0.875rem
        fontWeight: FontWeight.w500,
        color: AppColors.neutralBlack900,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 12, // 0.75rem
        height: 1.333, // 1rem / 0.75rem
        fontWeight: FontWeight.w500,
        color: AppColors.neutralBlack900,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 12, // 0.75rem (text-xxs)
        height: 1.333, // 1rem / 0.75rem
        fontWeight: FontWeight.w500,
        color: AppColors.neutralBlack800,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(), // Android default
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(), // iOS default
        TargetPlatform.windows: ZoomPageTransitionsBuilder(), // Windows default
      },
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      strokeCap: StrokeCap.round,
      refreshBackgroundColor: AppColors.neutralWhite100,
    ),
  );
}
