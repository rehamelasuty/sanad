import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text_styles.dart';
import '../common/price_change_badge.dart';
import '../common/sparkline_widget.dart';

/// Reusable stock list tile used in Home watchlist and Markets screens.
class StockListTile extends StatelessWidget {
  const StockListTile({
    super.key,
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.price,
    required this.changePercent,
    required this.sparklineData,
    required this.currency,
    this.isShariaCompliant = false,
    this.isLast = false,
    this.onTap,
    this.logoColor,
  });

  final String symbol;
  final String name;
  final String exchange;
  final double price;
  final double changePercent;
  final List<double> sparklineData;
  final String currency;
  final bool isShariaCompliant;
  final bool isLast;
  final VoidCallback? onTap;
  final Color? logoColor;

  @override
  Widget build(BuildContext context) {
    final isPositive = changePercent >= 0;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 11.h),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.border),
                ),
        ),
        child: Row(
          children: [
            // Logo
            _StockLogo(symbol: symbol, color: logoColor),
            SizedBox(width: 12.w),
            // Name + exchange
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppTextStyles.bodyLg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Text(
                        '$exchange · $exchange',
                        style: AppTextStyles.caption,
                      ),
                      if (isShariaCompliant) ...[
                        SizedBox(width: 4.w),
                        const Text('☽',
                            style: TextStyle(
                                color: AppColors.green, fontSize: 10)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Sparkline + price
            SparklineWidget(
              data: sparklineData,
              positive: isPositive,
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$currency${price.toStringAsFixed(2)}',
                  style: AppTextStyles.priceM,
                ),
                SizedBox(height: 3.h),
                PriceChangeBadge(value: changePercent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StockLogo extends StatelessWidget {
  const _StockLogo({required this.symbol, this.color});

  final String symbol;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
        color: color?.withValues(alpha: 0.12) ?? AppColors.white,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      alignment: Alignment.center,
      child: Text(
        symbol.length > 4 ? symbol.substring(0, 4) : symbol,
        style: AppTextStyles.monoSm.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 9.sp,
          color: color ?? AppColors.text2,
        ),
      ),
    );
  }
}
