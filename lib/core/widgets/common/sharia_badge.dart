import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_text_styles.dart';

/// ☽ شريعة compliance indicator chip.
class ShariaBadge extends StatelessWidget {
  const ShariaBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6.w : 10.w,
        vertical: compact ? 2.h : 4.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.greenLite,
        border: Border.all(color: const Color(0x260B7A5E)),
        borderRadius: AppRadius.fullAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '☽',
            style: TextStyle(fontSize: compact ? 9.sp : 10.sp),
          ),
          SizedBox(width: 3.w),
          Text(
            'متوافق',
            style: AppTextStyles.badgeSm.copyWith(
              color: AppColors.green,
              fontSize: compact ? 9.sp : 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}
