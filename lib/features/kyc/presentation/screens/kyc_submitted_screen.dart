import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class KycSubmittedScreen extends StatelessWidget {
  const KycSubmittedScreen({super.key});

  static const _timeline = [
    {
      'label': 'استلام الطلب',
      'sub': 'تم استلام طلبك بنجاح',
      'done': true,
    },
    {
      'label': 'مراجعة المستندات',
      'sub': 'جاري مراجعة هويتك والمستندات',
      'done': false,
    },
    {
      'label': 'التحقق البنكي',
      'sub': 'التحقق من حسابك البنكي',
      'done': false,
    },
    {
      'label': 'تفعيل الحساب',
      'sub': 'سيتم إشعارك بعد التفعيل',
      'done': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 48.h),
              // Hero icon
              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text('📋', style: TextStyle(fontSize: 36.sp)),
              ),
              SizedBox(height: 20.h),
              Text(
                'تم إرسال الطلب!',
                style: AppTextStyles.h3.copyWith(color: AppColors.text1),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'سيتم مراجعة طلبك خلال 1-3 أيام عمل\nوسنرسل لك إشعاراً فور الانتهاء',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.text3),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              // Timeline
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.bgApp,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: List.generate(_timeline.length, (i) {
                    final step = _timeline[i];
                    final isDone = step['done'] as bool;
                    final isLast = i == _timeline.length - 1;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 28.r,
                              height: 28.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDone
                                    ? AppColors.green
                                    : AppColors.bgPage,
                                border: isDone
                                    ? null
                                    : Border.all(color: AppColors.border),
                              ),
                              alignment: Alignment.center,
                              child: isDone
                                  ? Icon(Icons.check,
                                      size: 14.r, color: AppColors.white)
                                  : Container(
                                      width: 8.r,
                                      height: 8.r,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.border,
                                      ),
                                    ),
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 32.h,
                                color: isDone
                                    ? AppColors.green
                                    : AppColors.border,
                              ),
                          ],
                        ),
                        SizedBox(width: 14.w),
                        Padding(
                          padding: EdgeInsets.only(top: 4.h, bottom: isLast ? 0 : 28.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['label'] as String,
                                style: AppTextStyles.labelMd.copyWith(
                                  color: isDone
                                      ? AppColors.text1
                                      : AppColors.text3,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                step['sub'] as String,
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.text4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              // Info note
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.goldLite,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Text('⏰', style: TextStyle(fontSize: 16.sp)),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'وقت المراجعة المتوقع: 1-3 أيام عمل',
                        style:
                            AppTextStyles.bodySm.copyWith(color: AppColors.gold),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // CTA buttons
              GestureDetector(
                onTap: () => context.go(AppRoutes.home),
                child: Container(
                  width: double.infinity,
                  height: 52.h,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'استعراض التطبيق',
                    style: AppTextStyles.button.copyWith(color: AppColors.white),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: AppColors.bgApp,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.green),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'تتبع حالة الطلب',
                    style: AppTextStyles.button.copyWith(color: AppColors.green),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
