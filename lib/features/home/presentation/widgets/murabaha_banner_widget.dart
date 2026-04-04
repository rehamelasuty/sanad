import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';

class MurabahaBannerWidget extends StatelessWidget {
  const MurabahaBannerWidget({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            gradient: AppColors.murabahaBgGradient,
            borderRadius: AppRadius.smAll,
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
            boxShadow: AppShadows.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShariaBadge(),
                    SizedBox(height: 5.h),
                    Text(
                      'استثمر في المرابحة',
                      style: AppTextStyles.bodyLg
                          .copyWith(color: AppColors.text1),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'عوائد من 100 ر.س · 4.8% سنوياً',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.text2),
                    ),
                  ],
                ),
              ),
              Text('🌙', style: TextStyle(fontSize: 32.sp)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShariaBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.goldLite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
      ),
      child: Text(
        '☽ متوافق مع الشريعة',
        style: AppTextStyles.badgeSm.copyWith(color: AppColors.gold),
      ),
    );
  }
}
