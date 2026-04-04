import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.navy,
          primary: AppColors.navy,
          secondary: AppColors.gold,
          surface: AppColors.white,
          error: AppColors.red,
        ),
        scaffoldBackgroundColor: AppColors.bgPage,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.bgApp,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: AppTextStyles.h3,
          iconTheme: const IconThemeData(color: AppColors.text1),
        ),
        cardTheme: CardThemeData(
          color: AppColors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.smAll,
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: AppColors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
            textStyle: AppTextStyles.button,
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          border: OutlineInputBorder(
            borderRadius: AppRadius.smAll,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.smAll,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.smAll,
            borderSide: const BorderSide(color: AppColors.navy, width: 1.5),
          ),
          hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.text3),
        ),
        textTheme: TextTheme(
          headlineLarge: AppTextStyles.h1,
          headlineMedium: AppTextStyles.h2,
          headlineSmall: AppTextStyles.h3,
          titleLarge: AppTextStyles.h3,
          titleMedium: AppTextStyles.h4,
          bodyLarge: AppTextStyles.bodyLg,
          bodyMedium: AppTextStyles.bodyMd,
          bodySmall: AppTextStyles.bodySm,
          labelLarge: AppTextStyles.labelLg,
          labelMedium: AppTextStyles.labelMd,
          labelSmall: AppTextStyles.labelSm,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          space: 0,
          thickness: 1,
        ),
        splashColor: const Color(0x0A0D1B2E),
        highlightColor: Colors.transparent,
      );

  // ── Dark Theme ─────────────────────────────────────────────────────────────
  static const Color _darkBg = Color(0xFF08111C);
  static const Color _darkBgApp = Color(0xFF0D1B2E);
  static const Color _darkSurface = Color(0xFF162338);
  static const Color _darkBorder = Color(0x1AFFFFFF);
  static const Color _darkText1 = Color(0xFFF0F2F7);
  static const Color _darkText2 = Color(0xFFB8C8D8);
  static const Color _darkText3 = Color(0xFF7A91A8);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.gold,
          brightness: Brightness.dark,
          primary: AppColors.gold2,
          secondary: AppColors.navy,
          surface: _darkSurface,
          error: AppColors.red,
        ),
        scaffoldBackgroundColor: _darkBg,
        appBarTheme: AppBarTheme(
          backgroundColor: _darkBgApp,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: const IconThemeData(color: _darkText1),
          titleTextStyle: AppTextStyles.h3.copyWith(color: _darkText1),
        ),
        cardTheme: CardThemeData(
          color: _darkSurface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.smAll,
            side: const BorderSide(color: _darkBorder),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
            textStyle: AppTextStyles.button,
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _darkSurface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          border: OutlineInputBorder(
            borderRadius: AppRadius.smAll,
            borderSide: const BorderSide(color: _darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.smAll,
            borderSide: const BorderSide(color: _darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.smAll,
            borderSide:
                const BorderSide(color: AppColors.gold2, width: 1.5),
          ),
          hintStyle: AppTextStyles.bodyMd.copyWith(color: _darkText3),
        ),
        textTheme: TextTheme(
          headlineLarge: AppTextStyles.h1.copyWith(color: _darkText1),
          headlineMedium: AppTextStyles.h2.copyWith(color: _darkText1),
          headlineSmall: AppTextStyles.h3.copyWith(color: _darkText1),
          titleLarge: AppTextStyles.h3.copyWith(color: _darkText1),
          titleMedium: AppTextStyles.h4.copyWith(color: _darkText1),
          bodyLarge: AppTextStyles.bodyLg.copyWith(color: _darkText1),
          bodyMedium: AppTextStyles.bodyMd.copyWith(color: _darkText2),
          bodySmall: AppTextStyles.bodySm.copyWith(color: _darkText3),
          labelLarge: AppTextStyles.labelLg.copyWith(color: _darkText1),
          labelMedium: AppTextStyles.labelMd.copyWith(color: _darkText2),
          labelSmall: AppTextStyles.labelSm.copyWith(color: _darkText3),
        ),
        dividerTheme: const DividerThemeData(
          color: _darkBorder,
          space: 0,
          thickness: 1,
        ),
        splashColor: const Color(0x14FFFFFF),
        highlightColor: Colors.transparent,
      );
}
