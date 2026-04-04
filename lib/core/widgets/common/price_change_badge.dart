import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_text_styles.dart';

/// Badge showing +1.82% or −0.93% with green/red background.
class PriceChangeBadge extends StatelessWidget {
  const PriceChangeBadge({
    super.key,
    required this.value,
    this.isPercent = true,
    this.compact = false,
  });

  final double value;
  final bool isPercent;
  final bool compact;

  bool get _isPositive => value >= 0;

  @override
  Widget build(BuildContext context) {
    final bgColor = _isPositive ? AppColors.greenLite : AppColors.redLite;
    final fgColor = _isPositive ? AppColors.green : AppColors.red;
    final sign = _isPositive ? '+' : '';
    final suffix = isPercent ? '%' : '';
    final formatted = '$sign${value.toStringAsFixed(2)}$suffix';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6.w : 8.w,
        vertical: compact ? 2.h : 3.h,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.xsAll,
      ),
      child: Text(
        formatted,
        style: AppTextStyles.badgeMd.copyWith(color: fgColor),
      ),
    );
  }
}
