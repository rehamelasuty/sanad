import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/market_index.dart';

class IndexCardsRow extends StatelessWidget {
  const IndexCardsRow({super.key, required this.indices});

  final List<MarketIndex> indices;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Row(
        children: <Widget>[
          for (var i = 0; i < indices.length; i++) ...[
            if (i > 0) SizedBox(width: 10.w),
            Expanded(child: _buildCard(indices[i])),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(MarketIndex index) {
    final isPos = index.isPositive;
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            index.name,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            index.value.toStringAsFixed(0),
            style: AppTextStyles.monoSm.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.text1,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            '${isPos ? '▲ +' : '▼ '}${index.changePercent.abs().toStringAsFixed(2)}%',
            style: AppTextStyles.badgeSm.copyWith(
              color: isPos ? AppColors.green : AppColors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

