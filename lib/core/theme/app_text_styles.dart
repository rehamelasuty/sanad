import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  // ── Base helper ───────────────────────────────
  static TextStyle _sans({
    required double size,
    required FontWeight weight,
    Color color = AppColors.text1,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.ibmPlexSansArabic(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height ?? 1.4,
        letterSpacing: letterSpacing,
      );

  static TextStyle _mono({
    required double size,
    required FontWeight weight,
    Color color = AppColors.text1,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.ibmPlexMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height ?? 1.0,
        letterSpacing: letterSpacing,
      );

  // ── Display / Price ────────────────────────────
  static TextStyle get priceDisplay => _mono(
        size: 40.sp,
        weight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.0,
      );

  static TextStyle get heroPrice => _mono(
        size: 36.sp,
        weight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.0,
        color: AppColors.white,
      );

  static TextStyle get portValue => _mono(
        size: 30.sp,
        weight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle get murabahaRate => _mono(
        size: 34.sp,
        weight: FontWeight.w700,
        color: AppColors.white,
      );

  // ── Headings ──────────────────────────────────
  static TextStyle get h1 => _sans(
        size: 22.sp,
        weight: FontWeight.w700,
      );

  static TextStyle get h2 => _sans(
        size: 19.sp,
        weight: FontWeight.w700,
      );

  static TextStyle get h3 => _sans(
        size: 17.sp,
        weight: FontWeight.w700,
      );

  static TextStyle get h4 => _sans(
        size: 15.sp,
        weight: FontWeight.w700,
      );

  // ── Body ─────────────────────────────────────
  static TextStyle get bodyLg => _sans(
        size: 14.sp,
        weight: FontWeight.w600,
      );

  static TextStyle get bodyMd => _sans(
        size: 13.sp,
        weight: FontWeight.w400,
      );

  static TextStyle get bodySm => _sans(
        size: 12.sp,
        weight: FontWeight.w400,
      );

  // ── Labels ────────────────────────────────────
  static TextStyle get labelLg => _sans(
        size: 13.sp,
        weight: FontWeight.w600,
      );

  static TextStyle get labelMd => _sans(
        size: 12.sp,
        weight: FontWeight.w500,
        color: AppColors.text2,
      );

  static TextStyle get labelSm => _sans(
        size: 11.sp,
        weight: FontWeight.w500,
        color: AppColors.text2,
      );

  static TextStyle get caption => _sans(
        size: 10.sp,
        weight: FontWeight.w400,
        color: AppColors.text3,
      );

  // ── Mono Numbers ──────────────────────────────
  static TextStyle get priceM => _mono(
        size: 14.sp,
        weight: FontWeight.w600,
      );

  static TextStyle get priceSm => _mono(
        size: 13.sp,
        weight: FontWeight.w600,
      );

  static TextStyle get monoSm => _mono(
        size: 12.sp,
        weight: FontWeight.w400,
        color: AppColors.text3,
      );

  static TextStyle get holdingPrice => _mono(
        size: 14.sp,
        weight: FontWeight.w600,
      );

  static TextStyle get amtInput => _mono(
        size: 22.sp,
        weight: FontWeight.w700,
      );

  static TextStyle get amtCardValue => _mono(
        size: 28.sp,
        weight: FontWeight.w700,
      );

  // ── Section titles ────────────────────────────
  static TextStyle get sectionTitle => _sans(
        size: 15.sp,
        weight: FontWeight.w700,
      );

  static TextStyle get sectionAction => _sans(
        size: 12.sp,
        weight: FontWeight.w500,
        color: AppColors.navy,
      );

  // ── Buttons ───────────────────────────────────
  static TextStyle get button => _sans(
        size: 15.sp,
        weight: FontWeight.w700,
        color: AppColors.white,
        letterSpacing: 0.01,
      );

  // ── Badges ────────────────────────────────────
  static TextStyle get badgeMd => _sans(
        size: 11.sp,
        weight: FontWeight.w600,
      );

  static TextStyle get badgeSm => _sans(
        size: 10.sp,
        weight: FontWeight.w700,
      );

  // ── Contextual colour variants ─────────────────
  static TextStyle get positivePrice => priceM.copyWith(color: AppColors.green);
  static TextStyle get negativePrice => priceM.copyWith(color: AppColors.red);
  static TextStyle get greenLabel => labelMd.copyWith(color: AppColors.green);
  static TextStyle get mutedCaption => caption.copyWith(color: AppColors.text3);
}
