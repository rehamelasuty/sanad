import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class KycApprovedScreen extends StatelessWidget {
  const KycApprovedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 40.h),
              // Celebration icon
              Container(
                width: 88.r,
                height: 88.r,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text('🎉', style: TextStyle(fontSize: 40.sp)),
              ),
              SizedBox(height: 20.h),
              Text(
                'مبروك! تم تفعيل حسابك',
                style: AppTextStyles.h3.copyWith(color: AppColors.text1),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'حسابك الاستثماري جاهز\nيمكنك الآن بدء رحلتك الاستثمارية المتوافقة مع الشريعة',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.text3),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28.h),
              // Account summary card
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'حساب Sanad الاستثماري',
                              style: AppTextStyles.labelMd
                                  .copyWith(color: AppColors.white),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'محمد عبدالله الراشد',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.white.withOpacity(0.8)),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'مُفعّل ✅',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Divider(
                        color: AppColors.white.withOpacity(0.2), height: 1),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _AccountStat(
                            label: 'نوع الحساب', value: 'اسلامي 🕌'),
                        _AccountStat(
                            label: 'رقم الحساب', value: 'AWD-29183'),
                        _AccountStat(label: 'الرصيد', value: 'SAR 0.00'),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('☽', style: TextStyle(fontSize: 16.sp)),
                          SizedBox(width: 8.w),
                          Text(
                            'الفلتر الشرعي مفعّل — الأوراق المالية المتوافقة فقط',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              // Features unlocked
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: AppColors.greenLite,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔓 الميزات المتاحة الآن',
                      style: AppTextStyles.labelMd
                          .copyWith(color: AppColors.green),
                    ),
                    SizedBox(height: 10.h),
                    for (final feat in const [
                      'تداول الأسهم المحلية والأمريكية',
                      'الاستثمار في صناديق المرابحة',
                      'الاشتراك في الاكتتابات الجديدة',
                      'الإيداع والسحب الفوري',
                    ])
                      Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 14.r, color: AppColors.green),
                            SizedBox(width: 8.w),
                            Text(feat,
                                style: AppTextStyles.bodySm
                                    .copyWith(color: AppColors.green)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
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
                    'ابدأ الاستثمار الآن 🚀',
                    style: AppTextStyles.button.copyWith(color: AppColors.white),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () => context.push(AppRoutes.deposit),
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
                    'إيداع أول مبلغ 💰',
                    style:
                        AppTextStyles.button.copyWith(color: AppColors.green),
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

class _AccountStat extends StatelessWidget {
  final String label;
  final String value;

  const _AccountStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.labelSm.copyWith(color: AppColors.white),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: AppTextStyles.caption
              .copyWith(color: AppColors.white.withOpacity(0.7)),
        ),
      ],
    );
  }
}
