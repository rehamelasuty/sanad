import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';

/// Consistent card container used throughout the app.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.border,
    this.shadow = AppShadows.sm,
    this.color = AppColors.white,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow> shadow;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius ?? AppRadius.smAll,
        border: border ??
            Border.all(color: AppColors.border, width: 1),
        boxShadow: shadow,
      ),
      child: child,
    );
  }
}
