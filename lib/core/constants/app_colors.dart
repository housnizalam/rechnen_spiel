import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary structural colors
  static const Color black = Color(0xFF000000);
  static const Color red = Color(0xFF8B0000);
  static const Color redDark = Color(0xFF5A0000);
  static const Color redDeep = Color(0xFF320000);

  // Accent and text emphasis
  static const Color gold = Color(0xFFFFC107);
  static const Color goldSoft = Color(0xFFF7D56B);
  static const Color goldMuted = Color(0xCCFFC107);

  // Utility shades for borders/surfaces
  static const Color borderRed = Color(0xAA8B0000);
  static const Color borderGold = Color(0x88FFC107);
  static const Color surfaceDark = Color(0xCC120000);
  static const Color surfaceDarker = Color(0xE6000000);

  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      black,
      redDeep,
      redDark,
      black,
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      surfaceDark,
      surfaceDarker,
    ],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      red,
      redDark,
    ],
  );
}
