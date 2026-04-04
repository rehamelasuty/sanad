import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';

class SessionStatusBar extends StatelessWidget {
  const SessionStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 8.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.goldLite,
          borderRadius: AppRadius.xsAll,
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'السوق الأمريكي قبل الافتتاح',
                  style: AppTextStyles.labelMd,
                ),
              ],
            ),
            Text(
              'يفتح بعد 2:14 ساعة',
              style: AppTextStyles.badgeSm.copyWith(color: AppColors.gold),
            ),
          ],
        ),
      ),
    );
  }
}
