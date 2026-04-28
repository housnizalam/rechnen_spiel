import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_gradients.dart';
import 'app_text_styles.dart';

class AppDecorations {
  AppDecorations._();

  static BoxDecoration pageBackground() {
    return const BoxDecoration(
      gradient: AppGradients.mainBackgroundGradient,
    );
  }

  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      gradient: AppGradients.cardGradient,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.borderRed),
    );
  }

  static BoxDecoration buttonDecoration() {
    return BoxDecoration(
      gradient: AppGradients.buttonGradient,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.borderGold),
    );
  }

  static ShapeDecoration dialogDecoration() {
    return ShapeDecoration(
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.borderRed),
      ),
    );
  }

  static InputDecoration inputDecoration({
    required String labelText,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: AppTextStyles.subtitle.copyWith(
        fontSize: 20,
        color: AppColors.goldMuted,
      ),
      errorText: errorText,
      errorStyle: AppTextStyles.small,
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.borderGold, width: 2),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.gold, width: 2),
      ),
    );
  }
}
