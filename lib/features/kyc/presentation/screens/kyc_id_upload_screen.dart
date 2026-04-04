import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/kyc_steps_bar.dart';

class KycIdUploadScreen extends StatefulWidget {
  const KycIdUploadScreen({super.key});

  @override
  State<KycIdUploadScreen> createState() => _KycIdUploadScreenState();
}

class _KycIdUploadScreenState extends State<KycIdUploadScreen> {
  bool _frontUploaded = true;
  bool _backUploaded = false;

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
          'التحقق من الهوية',
          style: AppTextStyles.labelLg.copyWith(color: AppColors.text1),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              const KycStepsBar(activeIndex: 1, doneCount: 1),
              SizedBox(height: 28.h),
              // Header
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      alignment: Alignment.center,
                      child: Text('🪪', style: TextStyle(fontSize: 22.sp)),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الخطوة 2 — رفع الهوية الوطنية',
                            style: AppTextStyles.labelMd
                                .copyWith(color: AppColors.white),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'ارفع صورة واضحة للوجهين',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.white.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'صور الهوية الوطنية',
                style: AppTextStyles.sectionTitle.copyWith(color: AppColors.text1),
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: _UploadBox(
                      label: 'الوجه الأمامي',
                      icon: '🪪',
                      isUploaded: _frontUploaded,
                      onTap: () => setState(() => _frontUploaded = true),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: _UploadBox(
                      label: 'الوجه الخلفي',
                      icon: '🔄',
                      isUploaded: _backUploaded,
                      onTap: () => setState(() => _backUploaded = true),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              // Requirements note
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
                      '📋 متطلبات الصورة',
                      style:
                          AppTextStyles.labelMd.copyWith(color: AppColors.text1),
                    ),
                    SizedBox(height: 10.h),
                    for (final req in const [
                      'صورة واضحة غير مشوشة',
                      'خلفية مضاءة بشكل جيد',
                      'بدون انعكاسات أو ظلال',
                      'هوية سارية المفعول',
                    ])
                      Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                size: 14.r, color: AppColors.green),
                            SizedBox(width: 8.w),
                            Text(req,
                                style: AppTextStyles.bodySm
                                    .copyWith(color: AppColors.text2)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              _KycButton(
                label: 'متابعة',
                enabled: _frontUploaded && _backUploaded,
                onTap: () => context.push(AppRoutes.kycSelfie),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  final String label;
  final String icon;
  final bool isUploaded;
  final VoidCallback onTap;

  const _UploadBox({
    required this.label,
    required this.icon,
    required this.isUploaded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUploaded ? null : onTap,
      child: Container(
        height: 130.h,
        decoration: BoxDecoration(
          color: isUploaded
              ? AppColors.greenLite
              : AppColors.bgApp,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isUploaded ? AppColors.green : AppColors.border,
            width: isUploaded ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUploaded)
              Icon(Icons.check_circle_rounded,
                  size: 32.r, color: AppColors.green)
            else ...[
              Text(icon, style: TextStyle(fontSize: 28.sp)),
              SizedBox(height: 8.h),
              Icon(Icons.upload_rounded, size: 18.r, color: AppColors.text3),
            ],
            SizedBox(height: 8.h),
            Text(
              isUploaded ? 'تم الرفع ✓' : label,
              style: AppTextStyles.labelSm.copyWith(
                color: isUploaded ? AppColors.green : AppColors.text2,
              ),
            ),
            if (!isUploaded)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  'اضغط للرفع',
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.text3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _KycButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _KycButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          gradient: enabled ? AppColors.primaryGradient : null,
          color: enabled ? null : AppColors.border,
          borderRadius: BorderRadius.circular(14.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}
