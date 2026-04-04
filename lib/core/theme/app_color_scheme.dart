import 'package:flutter/material.dart';
import 'app_colors.dart';

// ─── Colour set (one instance per brightness) ─────────────────────────────────
class AppColorSet {
  const AppColorSet._({
    required this.bgPage,
    required this.bgApp,
    required this.surface,
    required this.cardBorder,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.text4,
    required this.border,
    required this.border2,
    required this.divider,
    required this.navy,
    required this.navy2,
    required this.navyGlow,
    required this.gold,
    required this.gold2,
    required this.goldLite,
    required this.goldLiteLite,
    required this.green,
    required this.greenLite,
    required this.red,
    required this.redLite,
    required this.blue,
    required this.blueLite,
    required this.white,
  });

  final Color bgPage;
  final Color bgApp;
  final Color surface;
  final Color cardBorder;
  final Color text1;
  final Color text2;
  final Color text3;
  final Color text4;
  final Color border;
  final Color border2;
  final Color divider;
  final Color navy;
  final Color navy2;
  final Color navyGlow;
  final Color gold;
  final Color gold2;
  final Color goldLite;
  final Color goldLiteLite;
  final Color green;
  final Color greenLite;
  final Color red;
  final Color redLite;
  final Color blue;
  final Color blueLite;
  final Color white;

  // ── Light ────────────────────────────────────────────────────────────────
  static const AppColorSet light = AppColorSet._(
    bgPage: AppColors.bgPage,
    bgApp: AppColors.bgApp,
    surface: AppColors.white,
    cardBorder: AppColors.border,
    text1: AppColors.text1,
    text2: AppColors.text2,
    text3: AppColors.text3,
    text4: AppColors.text4,
    border: AppColors.border,
    border2: AppColors.border2,
    divider: AppColors.border,
    navy: AppColors.navy,
    navy2: AppColors.navy2,
    navyGlow: AppColors.navyGlow,
    gold: AppColors.gold,
    gold2: AppColors.gold2,
    goldLite: AppColors.goldLite,
    goldLiteLite: AppColors.goldLiteLite,
    green: AppColors.green,
    greenLite: AppColors.greenLite,
    red: AppColors.red,
    redLite: AppColors.redLite,
    blue: AppColors.blue,
    blueLite: AppColors.blueLite,
    white: AppColors.white,
  );

  // ── Dark ─────────────────────────────────────────────────────────────────
  static const AppColorSet dark = AppColorSet._(
    bgPage: Color(0xFF08111C),
    bgApp: Color(0xFF0D1B2E),
    surface: Color(0xFF162338),
    cardBorder: Color(0x1AFFFFFF),
    text1: Color(0xFFF0F2F7),
    text2: Color(0xFFB8C8D8),
    text3: Color(0xFF7A91A8),
    text4: Color(0xFF3D506A),
    border: Color(0x1AFFFFFF),
    border2: Color(0x26FFFFFF),
    divider: Color(0x14FFFFFF),
    navy: Color(0xFFE8EFF9),
    navy2: Color(0xFFB8C8D8),
    navyGlow: Color(0x33FFFFFF),
    gold: AppColors.gold,
    gold2: AppColors.gold2,
    goldLite: Color(0xFF1E1608),
    goldLiteLite: Color(0xFF180F04),
    green: AppColors.green,
    greenLite: Color(0xFF0D1F19),
    red: AppColors.red,
    redLite: Color(0xFF1E0A0C),
    blue: Color(0xFF5B8DD9),
    blueLite: Color(0xFF0D1527),
    white: Color(0xFF162338),
  );
}

// ─── BuildContext extension ────────────────────────────────────────────────────
extension AppColorsContext on BuildContext {
  AppColorSet get cs =>
      Theme.of(this).brightness == Brightness.dark
          ? AppColorSet.dark
          : AppColorSet.light;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
