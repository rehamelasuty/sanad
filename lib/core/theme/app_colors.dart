import 'package:flutter/material.dart';

abstract class AppColors {
  // ── Backgrounds ──────────────────────────────
  static const Color bgPage = Color(0xFFEEF0F5);
  static const Color bgApp = Color(0xFFF7F8FC);
  static const Color white = Color(0xFFFFFFFF);

  // ── Brand Greens ──────────────────────────────
  static const Color green = Color(0xFF0B7A5E);
  static const Color greenMid = Color(0xFF0D9970);
  static const Color greenLite = Color(0xFFE6F5F0);
  static const Color greenGlow = Color(0x230B7A5E);
  static const Color emerald = Color(0xFF05513F);

  // ── Status ────────────────────────────────────
  static const Color red = Color(0xFFD63F52);
  static const Color redLite = Color(0xFFFDEDF0);

  // ── Gold ──────────────────────────────────────
  static const Color gold = Color(0xFFB07D2A);
  static const Color goldLite = Color(0xFFFDF4E3);

  // ── Blue ──────────────────────────────────────
  static const Color blue = Color(0xFF2060C8);
  static const Color blueLite = Color(0xFFEBF1FB);

  // ── Text ──────────────────────────────────────
  static const Color text1 = Color(0xFF0F1923);
  static const Color text2 = Color(0xFF4A5568);
  static const Color text3 = Color(0xFF8A95A3);
  static const Color text4 = Color(0xFFBCC4CE);

  // ── Borders ───────────────────────────────────
  static const Color border = Color(0x120F1923);
  static const Color border2 = Color(0x1F0F1923);

  // ── Gradients ─────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [greenMid, emerald],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.6, 1.0],
    colors: [green, Color(0xFF054D3C), Color(0xFF03362A)],
  );

  static const LinearGradient portfolioSummaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEBF5F1), Color(0xFFF2F9F6)],
  );

  static const LinearGradient murabahaBgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFDF8EE), Color(0xFFFDF4E0)],
  );
}
