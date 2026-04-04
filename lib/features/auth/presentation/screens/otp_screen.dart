import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<String> _digits = ['', '', '', '', '', ''];
  int _activeIndex = 3; // demo: first 3 filled
  int _timer = 58;
  Timer? _countdown;

  @override
  void initState() {
    super.initState();
    _digits[0] = '4';
    _digits[1] = '7';
    _digits[2] = '2';
    _startTimer();
  }

  void _startTimer() {
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timer > 0) {
        setState(() => _timer--);
      } else {
        _countdown?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),
              // Back button
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x100F1923),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text('←', style: TextStyle(fontSize: 16.sp)),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text('📱', style: TextStyle(fontSize: 32.sp)),
              SizedBox(height: 10.h),
              Text('أدخل رمز التحقق', style: AppTextStyles.h1),
              SizedBox(height: 6.h),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.text2,
                    height: 1.6,
                  ),
                  children: const [
                    TextSpan(text: 'تم إرسال رمز مكوّن من 6 أرقام إلى\n'),
                    TextSpan(
                      text: '+966 5X XXX XXXX',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F1923),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28.h),
              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final isFilled = _digits[i].isNotEmpty;
                  final isActive = i == _activeIndex;
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.w),
                    width: 46.w,
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: isFilled
                          ? AppColors.greenLite
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isActive
                            ? AppColors.green
                            : isFilled
                                ? AppColors.green
                                : AppColors.border,
                        width: isActive ? 1.5 : 1.0,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.greenLite,
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        isFilled
                            ? _digits[i]
                            : isActive
                                ? '_'
                                : '',
                        style: AppTextStyles.amtCardValue.copyWith(
                          fontSize: 22.sp,
                          color: AppColors.text1,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 24.h),
              // Verify button
              GestureDetector(
                onTap: () => context.push(AppRoutes.home),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.greenGlow,
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'تحقق ودخول',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.button.copyWith(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Resend
              Center(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.text3),
                    children: [
                      const TextSpan(text: 'لم تستلم الرمز؟ '),
                      TextSpan(
                        text: _timer > 0
                            ? 'إعادة إرسال ($_timer)'
                            : 'إعادة إرسال',
                        style: TextStyle(
                          color: _timer > 0
                              ? AppColors.text3
                              : AppColors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              // Security note
              Container(
                padding: EdgeInsets.all(13.r),
                decoration: BoxDecoration(
                  color: AppColors.greenLite,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.green.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🔒', style: TextStyle(fontSize: 16.sp)),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'رسالتك الآمنة من عوائد. لا تشارك هذا الرمز مع أحد. فريق عوائد لن يطلب منك هذا الرمز.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.text2,
                          height: 1.6,
                        ),
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
