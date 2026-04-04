import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text_styles.dart';

/// Primary action button with gradient background.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isLoading;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          gradient: color == null
              ? AppColors.primaryGradient
              : LinearGradient(colors: [color!, color!]),
          borderRadius: AppRadius.smAll,
          boxShadow: AppShadows.navyGlow,
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: const CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[icon!, SizedBox(width: 8.w)],
                  Text(label, style: AppTextStyles.button),
                ],
              ),
      ),
    );
  }
}
