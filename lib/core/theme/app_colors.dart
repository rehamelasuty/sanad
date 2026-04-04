import 'package:flutter/material.dart';

abstract class AppColors {
  // ── Backgrounds ──────────────────────────────
  static const Color bgPage = Color(0xFFF0F2F7);
  static const Color bgApp = Color(0xFFF7F8FC);
  static const Color white = Color(0xFFFFFFFF);

  // ── Brand Navy ────────────────────────────────
  static const Color navy = Color(0xFF0D1B2E);
  static const Color navy2 = Color(0xFF162338);
  static const Color navyGlow = Color(0x230D1B2E);

  // ── Brand Gold ────────────────────────────────
  static const Color gold = Color(0xFFC9922A);
  static const Color gold2 = Color(0xFFE8A830);
  static const Color goldLite = Color(0xFFFDF5E6);
  static const Color goldLiteLite = Color(0xFFFEF9F0);

  // ── Green (positive / Sharia) ─────────────────
  static const Color green = Color(0xFF1A7C5E);
  static const Color greenMid = Color(0xFF20996F);
  static const Color greenLite = Color(0xFFE6F5EF);

  // ── Status ────────────────────────────────────
  static const Color red = Color(0xFFC9323C);
  static const Color redLite = Color(0xFFFDEAEA);

  // ── Blue ──────────────────────────────────────
  static const Color blue = Color(0xFF1B4FA8);
  static const Color blueLite = Color(0xFFE8EFF9);

  // ── Text ──────────────────────────────────────
  static const Color text1 = Color(0xFF0D1B2E);
  static const Color text2 = Color(0xFF3D506A);
  static const Color text3 = Color(0xFF7A91A8);
  static const Color text4 = Color(0xFFB8C8D8);

  // ── Borders ───────────────────────────────────
  static const Color border = Color(0x120D1B2E);
  static const Color border2 = Color(0x1F0D1B2E);

  // ── Gradients ─────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy2, navy],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.55, 1.0],
    colors: [navy2, navy, Color(0xFF0A1424)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold2, gold],
  );

  static const LinearGradient portfolioSummaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x0A0D1B2E), Color(0x0FC9922A)],
  );

  static const LinearGradient murabahaBgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFEF9F0), Color(0xFFFDF5E6)],
  );
}
