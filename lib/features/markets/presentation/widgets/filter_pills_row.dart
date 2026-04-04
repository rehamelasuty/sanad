import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';

class FilterPillsRow extends StatelessWidget {
  const FilterPillsRow({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  static const _filters = [
    ('all', 'الكل'),
    ('saudi', 'السعودي'),
    ('us', 'أمريكي'),
    ('sharia', '☽ الشريعة'),
    ('etf', 'ETF'),
    ('top', 'الأكثر تداولاً'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 7.w),
        itemBuilder: (context, i) {
          final (key, label) = _filters[i];
          final isActive = activeFilter == key;
          return GestureDetector(
            onTap: () => onFilterChanged(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isActive ? AppColors.navy : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppColors.navy : AppColors.border,
                ),
                boxShadow: isActive ? AppShadows.navyGlow : AppShadows.sm,
              ),
              child: Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: isActive ? AppColors.white : AppColors.text2,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
