import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class KycStepsBar extends StatelessWidget {
  final int activeIndex; // 0-based
  final int doneCount; // how many steps are fully done

  const KycStepsBar({
    super.key,
    required this.activeIndex,
    required this.doneCount,
  });

  static const _labels = ['الجوال', 'الهوية', 'السيلفي', 'البنك', 'مراجعة'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          // connector line
          final stepIndex = i ~/ 2;
          final isDone = stepIndex < doneCount;
          return Expanded(
            child: Container(
              height: 2.h,
              color: isDone ? AppColors.green : AppColors.border,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final isDone = stepIndex < doneCount;
        final isActive = stepIndex == activeIndex;
        return _StepDot(
          label: _labels[stepIndex],
          isDone: isDone,
          isActive: isActive,
          index: stepIndex + 1,
        );
      }),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool isDone;
  final bool isActive;
  final int index;

  const _StepDot({
    required this.label,
    required this.isDone,
    required this.isActive,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = isDone
        ? AppColors.green
        : isActive
            ? AppColors.green
            : AppColors.border;
    final Color fg = (isDone || isActive) ? AppColors.white : AppColors.text3;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28.r,
          height: 28.r,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isDone
              ? Icon(Icons.check, size: 14.r, color: fg)
              : Text(
                  '$index',
                  style: AppTextStyles.labelSm.copyWith(color: fg),
                ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: (isDone || isActive) ? AppColors.green : AppColors.text3,
          ),
        ),
      ],
    );
  }
}
