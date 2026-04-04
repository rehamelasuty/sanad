import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Full-screen loading indicator.
class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
            strokeWidth: 2.5,
          ),
          if (message != null) ...[
            SizedBox(height: 16.h),
            Text(message!, style: AppTextStyles.bodyMd),
          ],
        ],
      ),
    );
  }
}

/// Error state with retry button.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('⚠️', style: TextStyle(fontSize: 40.sp)),
            SizedBox(height: 12.h),
            Text(
              message,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16.h),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'إعادة المحاولة',
                  style: AppTextStyles.labelMd
                      .copyWith(color: AppColors.green),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
