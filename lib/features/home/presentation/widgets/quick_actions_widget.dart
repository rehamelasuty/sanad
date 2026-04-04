import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key, this.onDeposit, this.onWithdraw, this.onOrders, this.onStatement});

  final VoidCallback? onDeposit;
  final VoidCallback? onWithdraw;
  final VoidCallback? onOrders;
  final VoidCallback? onStatement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Row(
        children: [
          _QAButton(
            icon: '💰',
            label: 'إيداع',
            bgColor: AppColors.greenLite,
            onTap: onDeposit,
          ),
          SizedBox(width: 10.w),
          _QAButton(
            icon: '📤',
            label: 'سحب',
            bgColor: const Color(0xFFFDF3F4),
            onTap: onWithdraw,
          ),
          SizedBox(width: 10.w),
          _QAButton(
            icon: '📊',
            label: 'أوامر',
            bgColor: AppColors.blueLite,
            onTap: onOrders,
          ),
          SizedBox(width: 10.w),
          _QAButton(
            icon: '📜',
            label: 'كشف',
            bgColor: AppColors.goldLite,
            onTap: onStatement,
          ),
        ],
      ),
    );
  }
}

class _QAButton extends StatelessWidget {
  const _QAButton({
    required this.icon,
    required this.label,
    required this.bgColor,
    this.onTap,
  });

  final String icon;
  final String label;
  final Color bgColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 6.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.smAll,
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.center,
                child: Text(icon, style: TextStyle(fontSize: 16.sp)),
              ),
              SizedBox(height: 7.h),
              Text(label, style: AppTextStyles.labelSm),
            ],
          ),
        ),
      ),
    );
  }
}
