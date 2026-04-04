import 'package:flutter/material.dart';

abstract class AppShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0F0D1B2E),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0D0D1B2E),
      blurRadius: 14,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x120D1B2E),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x140D1B2E),
      blurRadius: 28,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x140D1B2E),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x1A0D1B2E),
      blurRadius: 40,
      offset: Offset(0, 16),
    ),
  ];

  static const List<BoxShadow> navyGlow = [
    BoxShadow(
      color: Color(0x590D1B2E),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x4D0D1B2E),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> heroCard = [
    BoxShadow(
      color: Color(0x470D1B2E),
      blurRadius: 32,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x290D1B2E),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}
