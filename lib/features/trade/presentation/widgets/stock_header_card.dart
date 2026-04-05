import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common/sharia_badge.dart';
import '../../../market_feed/domain/entities/market_tick.dart';
import '../../domain/entities/stock_detail.dart';

class StockHeaderCard extends StatelessWidget {
  const StockHeaderCard({
    super.key,
    required this.stock,
    this.liveTick,
  });

  final StockDetail stock;

  /// When non-null, live price/change data from the WebSocket feed overrides
  /// the static values loaded from the data-source.
  final MarketTick? liveTick;

  @override
  Widget build(BuildContext context) {
    // Prefer live data from WebSocket when available.
    final price = liveTick?.price ?? stock.currentPrice;
    final change = liveTick?.change ?? stock.changeToday;
    final changePct = liveTick?.changePercent ?? stock.changeTodayPercent;

    final isPos = changePct >= 0;
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
                        // Live indicator dot
                        if (liveTick != null) ...[
                          SizedBox(width: 6.w),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'مباشر',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.green),
                          ),
                        ],
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
                price.toStringAsFixed(2),
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
                    '$changeSign${change.toStringAsFixed(2)}',
                    style: AppTextStyles.monoSm.copyWith(
                      color: changeColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                    ),
                  ),
                  Text(
                    '$changeSign${changePct.toStringAsFixed(2)}%',
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
