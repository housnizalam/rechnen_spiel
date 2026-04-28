import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_gradients.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.black,
    primaryColor: AppColors.red,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      secondary: AppColors.gold,
      surface: AppColors.surfaceDark,
      error: AppColors.dangerRed,
    ),
    textTheme: const TextTheme(
      titleLarge: AppTextStyles.title,
      titleMedium: AppTextStyles.subtitle,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.body,
      labelLarge: AppTextStyles.button,
      bodySmall: AppTextStyles.small,
    ),
    iconTheme: const IconThemeData(color: AppColors.gold),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.black,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.gold),
      titleTextStyle: TextStyle(
        color: AppColors.gold,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.gold,
        backgroundColor: AppColors.red,
        textStyle: AppTextStyles.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderGold),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.gold,
        side: const BorderSide(color: AppColors.borderRed),
        textStyle: AppTextStyles.body,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: AppColors.goldMuted),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.borderGold, width: 2),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.gold, width: 2),
      ),
      errorStyle: TextStyle(
        color: AppColors.goldMuted,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.borderRed),
      ),
      titleTextStyle: AppTextStyles.subtitle,
      contentTextStyle: AppTextStyles.body,
    ),
    extensions: const <ThemeExtension<dynamic>>[],
  );

  static const BoxDecoration scaffoldGradientDecoration = BoxDecoration(
    gradient: AppGradients.mainBackgroundGradient,
  );
}
