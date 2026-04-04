import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';

class MarketsSearchBox extends StatefulWidget {
  const MarketsSearchBox({super.key, this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  State<MarketsSearchBox> createState() => _MarketsSearchBoxState();
}

class _MarketsSearchBoxState extends State<MarketsSearchBox> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.smAll,
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          children: [
            Text('🔍', style: TextStyle(fontSize: 15.sp)),
            SizedBox(width: 10.w),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: widget.onChanged,
                style: AppTextStyles.bodyMd,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'ابحث عن سهم أو ETF...',
                  hintStyle:
                      AppTextStyles.bodyMd.copyWith(color: AppColors.text3),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.greenLite,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '☽ الشريعة',
                style: AppTextStyles.badgeSm
                    .copyWith(color: AppColors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
