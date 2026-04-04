import 'package:flutter/material.dart';

abstract class AppRadius {
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 18.0;
  static const double lg = 24.0;
  static const double full = 100.0;

  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));
}
