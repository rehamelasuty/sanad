import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/kyc_steps_bar.dart';

class KycSelfieScreen extends StatelessWidget {
  const KycSelfieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgApp,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.text1,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'التحقق البيومتري',
          style: AppTextStyles.labelLg.copyWith(color: AppColors.text1),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              const KycStepsBar(activeIndex: 2, doneCount: 2),
              SizedBox(height: 28.h),
              // Camera viewfinder
              Container(
                width: 240.r,
                height: 240.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A14),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.green, width: 2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Oval face outline
                    Container(
                      width: 160.r,
                      height: 200.r,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(80.r),
                        border: Border.all(
                          color: AppColors.green.withOpacity(0.6),
                          width: 2,
                        ),
                      ),
                    ),
                    // Scanning line animation placeholder
                    Positioned(
                      top: 40.h,
                      child: Container(
                        width: 160.r,
                        height: 2,
                        color: AppColors.green.withOpacity(0.8),
                      ),
                    ),
                    // Corner brackets
                    ..._buildCorners(),
                    Positioned(
                      bottom: 16.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'ضع وجهك داخل الإطار',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.green),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'التحقق من الوجه',
                style: AppTextStyles.h4.copyWith(color: AppColors.text1),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'سيتم مقارنة صورتك مع هويتك الوطنية للتحقق',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.text3),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              // Instructions
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: AppColors.bgApp,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 تعليمات',
                      style:
                          AppTextStyles.labelMd.copyWith(color: AppColors.text1),
                    ),
                    SizedBox(height: 10.h),
                    for (final tip in const [
                      'تأكد من إضاءة جيدة',
                      'أنظر مباشرة للكاميرا',
                      'لا تضع نظارات أو قناع',
                      'ابتعد عن الخلفيات المشبعة',
                    ])
                      Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                size: 14.r, color: AppColors.green),
                            SizedBox(width: 8.w),
                            Text(tip,
                                style: AppTextStyles.bodySm
                                    .copyWith(color: AppColors.text2)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              _buildButton(context),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCorners() {
    return [
      Positioned(
        top: 12,
        left: 12,
        child: _Corner(top: true, left: true),
      ),
      Positioned(
        top: 12,
        right: 12,
        child: _Corner(top: true, left: false),
      ),
      Positioned(
        bottom: 12,
        left: 12,
        child: _Corner(top: false, left: true),
      ),
      Positioned(
        bottom: 12,
        right: 12,
        child: _Corner(top: false, left: false),
      ),
    ];
  }

  Widget _buildButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.kycBank),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'التقاط صورة',
              style: AppTextStyles.button.copyWith(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final bool top;
  final bool left;

  const _Corner({required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _CornerPainter(top: top, left: left),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool top;
  final bool left;

  _CornerPainter({required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (top && left) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!top && left) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}
