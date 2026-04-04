import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/trade_state.dart';

class TradeChart extends StatelessWidget {
  const TradeChart({
    super.key,
    required this.data,
    required this.selectedRange,
    required this.isPositive,
    required this.onRangeSelected,
  });

  final List<double> data;
  final ChartRange selectedRange;
  final bool isPositive;
  final ValueChanged<ChartRange> onRangeSelected;

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppColors.green : AppColors.red;
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return Column(
      children: [
        SizedBox(
          height: 160.h,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.white,
                  getTooltipItems: (spots) => spots
                      .map(
                        (s) => LineTooltipItem(
                          s.y.toStringAsFixed(2),
                          AppTextStyles.monoSm.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.35,
                  color: color,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withValues(alpha: 0.18),
                        color.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ChartRange.values.map((r) {
            final isSelected = r == selectedRange;
            return GestureDetector(
              onTap: () => onRangeSelected(r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  r.label,
                  style: AppTextStyles.labelMd.copyWith(
                    color: isSelected ? Colors.white : AppColors.text3,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
