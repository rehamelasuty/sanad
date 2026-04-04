import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common/sharia_badge.dart';
import '../../domain/entities/stock_detail.dart';

class StockHeaderCard extends StatelessWidget {
  const StockHeaderCard({super.key, required this.stock});

  final StockDetail stock;

  @override
  Widget build(BuildContext context) {
    final isPos = stock.isPositive;
    final changeColor = isPos ? AppColors.green : AppColors.red;
    final changeSign = isPos ? '+' : '';
    final logoColor =
        Color(stock.logoColor ?? AppColors.green.toARGB32());

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo circle
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: logoColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  stock.symbol.substring(0, 1),
                  style: AppTextStyles.h3.copyWith(color: logoColor),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stock.name, style: AppTextStyles.h3),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Text(
                          '${stock.symbol} · ${stock.exchange}',
                          style: AppTextStyles.caption,
                        ),
                        SizedBox(width: 8.w),
                        if (stock.isShariaCompliant) const ShariaBadge(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                stock.currentPrice.toStringAsFixed(2),
                style: AppTextStyles.priceDisplay,
              ),
              SizedBox(width: 4.w),
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(
                  stock.exchange == 'تداول' ? 'ر.س' : 'USD',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.text3,
                  ),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$changeSign${stock.changeToday.toStringAsFixed(2)}',
                    style: AppTextStyles.monoSm.copyWith(
                      color: changeColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                    ),
                  ),
                  Text(
                    '$changeSign${stock.changeTodayPercent.toStringAsFixed(2)}%',
                    style: AppTextStyles.monoSm.copyWith(
                      color: changeColor,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _StatsRow(stock: stock),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stock});

  final StockDetail stock;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _Stat(label: 'افتتاح', value: stock.open.toStringAsFixed(2)),
        _Stat(label: 'أعلى', value: stock.high.toStringAsFixed(2)),
        _Stat(label: 'أدنى', value: stock.low.toStringAsFixed(2)),
        _Stat(
            label: 'إغلاق سابق',
            value: stock.previousClose.toStringAsFixed(2)),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.monoSm.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.text1,
          ),
        ),
        SizedBox(height: 2.h),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
