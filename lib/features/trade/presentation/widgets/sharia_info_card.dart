import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/stock_detail.dart';

class ShariaInfoCard extends StatelessWidget {
  const ShariaInfoCard({super.key, required this.stock});

  final StockDetail stock;

  @override
  Widget build(BuildContext context) {
    final isCompliant = stock.isShariaCompliant;
    final statusColor = isCompliant ? AppColors.green : AppColors.red;
    final statusLabel = isCompliant ? 'متوافق مع الشريعة' : 'غير متوافق';
    final statusIcon = isCompliant ? '☽' : '✕';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 22.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: isCompliant
              ? AppColors.green.withValues(alpha: 0.25)
              : AppColors.red.withValues(alpha: 0.20),
        ),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('الفحص الشرعي', style: AppTextStyles.h4),
              const Spacer(),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.fullAll,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      statusIcon,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: statusColor,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      statusLabel,
                      style: AppTextStyles.badgeSm.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _ShariaRow(
            label: 'نسبة الدين',
            value: '${(stock.debtToEquityRatio * 100).toStringAsFixed(1)}%',
            threshold: '< 33%',
            passed: stock.debtToEquityRatio < 0.33,
          ),
          SizedBox(height: 8.h),
          _ShariaRow(
            label: 'الإيرادات المحرمة',
            value: '${stock.prohibitedRevenuePercent.toStringAsFixed(1)}%',
            threshold: '< 5%',
            passed: stock.prohibitedRevenuePercent < 5,
          ),
          if (isCompliant && stock.purificationPercent > 0) ...[
            SizedBox(height: 8.h),
            _ShariaRow(
              label: 'نسبة التطهير',
              value: '${stock.purificationPercent.toStringAsFixed(2)}%',
              threshold: 'تطهير واجب',
              passed: true,
              isInfo: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _ShariaRow extends StatelessWidget {
  const _ShariaRow({
    required this.label,
    required this.value,
    required this.threshold,
    required this.passed,
    this.isInfo = false,
  });

  final String label;
  final String value;
  final String threshold;
  final bool passed;
  final bool isInfo;

  @override
  Widget build(BuildContext context) {
    final color = isInfo
        ? AppColors.gold
        : passed
            ? AppColors.green
            : AppColors.red;

    return Row(
      children: [
        Icon(
          isInfo
              ? Icons.info_outline_rounded
              : passed
                  ? Icons.check_circle_outline_rounded
                  : Icons.cancel_outlined,
          size: 16.r,
          color: color,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(label, style: AppTextStyles.bodyMd),
        ),
        Text(
          value,
          style: AppTextStyles.monoSm.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          threshold,
          style: AppTextStyles.caption.copyWith(color: AppColors.text3),
        ),
      ],
    );
  }
}
