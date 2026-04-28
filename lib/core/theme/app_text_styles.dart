import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle title = TextStyle(
    color: AppColors.gold,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subtitle = TextStyle(
    color: AppColors.gold,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.goldMuted,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle button = TextStyle(
    color: AppColors.gold,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle small = TextStyle(
    color: AppColors.goldMuted,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
}
