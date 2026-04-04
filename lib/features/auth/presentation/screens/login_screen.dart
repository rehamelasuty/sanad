import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo row
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(
                          'ع',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text('عوائد', style: AppTextStyles.h2),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('مرحباً بك 👋', style: AppTextStyles.h1),
                    SizedBox(height: 6.h),
                    Text(
                      'سجّل دخولك للوصول إلى محفظتك واستثماراتك',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.text2,
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 28.h),
                    // Phone label
                    Text(
                      'رقم الجوال',
                      style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.text2),
                    ),
                    SizedBox(height: 6.h),
                    // Phone input
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 14.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.bgApp,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12.r),
                                bottomRight: Radius.circular(12.r),
                              ),
                              border: Border(
                                left: BorderSide(color: AppColors.border),
                              ),
                            ),
                            child: Text(
                              '🇸🇦 +966',
                              style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.text2),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.ltr,
                              style: AppTextStyles.bodyMd,
                              decoration: InputDecoration(
                                hintText: '5X XXX XXXX',
                                hintStyle: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.text4),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 14.h,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // CTA
                    _GreenButton(
                      label: 'متابعة',
                      onTap: () => context.push(AppRoutes.otp),
                    ),
                    SizedBox(height: 20.h),
                    // Divider or
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: AppColors.border, height: 1),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text(
                            'أو',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.text3),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: AppColors.border, height: 1),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _SocialButton(
                      icon: '🏦',
                      label: 'الدخول عبر أبشر',
                      onTap: () {},
                    ),
                    SizedBox(height: 10.h),
                    _SocialButton(
                      icon: 'G',
                      label: 'الدخول عبر Google',
                      onTap: () {},
                      isGoogle: true,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'بالمتابعة أنت توافق على شروط الاستخدام وسياسة الخصوصية\nمرخصة من هيئة سوق المالية · 03-22247',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.text3,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreenButton extends StatelessWidget {
  const _GreenButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.navyGlow,
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.button.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isGoogle = false,
  });
  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool isGoogle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.border.withValues(alpha: 0.5),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: TextStyle(
                fontSize: isGoogle ? 16.sp : 18.sp,
                fontWeight:
                    isGoogle ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.text1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
