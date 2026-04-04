import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common/app_loading_error.dart';
import '../cubit/trade_cubit.dart';
import '../cubit/trade_state.dart';
import '../widgets/order_sheet.dart';
import '../widgets/sharia_info_card.dart';
import '../widgets/stock_header_card.dart';
import '../widgets/trade_chart.dart';

class TradeScreen extends StatelessWidget {
  const TradeScreen({super.key, required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<TradeCubit>()..loadStock(symbol),
      child: const _TradeView(),
    );
  }
}

class _TradeView extends StatelessWidget {
  const _TradeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: BlocBuilder<TradeCubit, TradeState>(
        builder: (context, state) {
          return switch (state) {
            TradeInitial() || TradeLoading() => const Center(
                child: AppLoadingWidget(),
              ),
            TradeError(:final message) => Center(
                child: AppErrorWidget(
                  message: message,
                  onRetry: () {
                    // symbol comes from parent widget — re-fetch via cubit
                  },
                ),
              ),
            TradeLoaded(:final stock) => CustomScrollView(
                slivers: [
                  _TradeAppBar(symbol: stock.symbol, name: stock.name),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SizedBox(height: 16.h),
                        StockHeaderCard(stock: stock),
                        SizedBox(height: 20.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22.w),
                          child: TradeChart(
                            data: stock.chartData,
                            selectedRange: state.selectedChartRange,
                            isPositive: stock.isPositive,
                            onRangeSelected: context
                                .read<TradeCubit>()
                                .selectChartRange,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        OrderSheet(),
                        SizedBox(height: 20.h),
                        ShariaInfoCard(stock: stock),
                        SizedBox(height: 24.h),
                        _FundamentalsCard(stock: stock),
                        SizedBox(height: 20.h),
                        _TradingHoursChip(),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ],
              ),
          };
        },
      ),
    );
  }
}

class _TradeAppBar extends StatelessWidget {
  const _TradeAppBar({required this.symbol, required this.name});

  final String symbol;
  final String name;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.bgApp,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      title: Column(
        children: [
          Text(name, style: AppTextStyles.h4),
          Text(symbol, style: AppTextStyles.caption),
        ],
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20.r,
          color: AppColors.text1,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.bookmark_border_rounded,
            size: 22.r,
            color: AppColors.text2,
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _FundamentalsCard extends StatelessWidget {
  const _FundamentalsCard({required this.stock});

  final stock;

  @override
  Widget build(BuildContext context) {
    final currency = stock.exchange == 'تداول' ? 'ر.س' : 'USD';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('المؤشرات الأساسية', style: AppTextStyles.h4),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: [
              _FundStat(
                label: 'القيمة السوقية',
                value: _formatMarketCap(stock.marketCap, currency),
              ),
              _FundStat(
                label: 'مضاعف الربحية',
                value: stock.peRatio.toStringAsFixed(1),
              ),
              _FundStat(
                label: 'أعلى 52 أسبوع',
                value: stock.week52High.toStringAsFixed(2),
              ),
              _FundStat(
                label: 'أدنى 52 أسبوع',
                value: stock.week52Low.toStringAsFixed(2),
              ),
              _FundStat(
                label: 'الحجم',
                value: _formatVolume(stock.volume),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatMarketCap(double cap, String currency) {
    if (cap >= 1e12) return '${(cap / 1e12).toStringAsFixed(1)}ت $currency';
    if (cap >= 1e9) return '${(cap / 1e9).toStringAsFixed(1)}م $currency';
    return '${(cap / 1e6).toStringAsFixed(1)}م $currency';
  }

  String _formatVolume(double vol) {
    if (vol >= 1e6) return '${(vol / 1e6).toStringAsFixed(1)}م';
    if (vol >= 1e3) return '${(vol / 1e3).toStringAsFixed(1)}ألف';
    return vol.toStringAsFixed(0);
  }
}

class _FundStat extends StatelessWidget {
  const _FundStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 56.w) / 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMd),
          Text(
            value,
            style: AppTextStyles.monoSm.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.text1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Trading hours chip ───────────────────────────────────────────────────────

class _TradingHoursChip extends StatelessWidget {
  const _TradingHoursChip();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: GestureDetector(
        onTap: () => _showTradingHoursModal(context),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 8.r,
                height: 8.r,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFF9800), // orange = pre-market
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ما قبل السوق',
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '04:00 – 09:30 صباحاً',
                      style: AppTextStyles.monoSm.copyWith(
                        color: AppColors.text3,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'جدول الأوقات',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.chevron_right_rounded, size: 16.r, color: AppColors.green),
            ],
          ),
        ),
      ),
    );
  }

  void _showTradingHoursModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TradingHoursModal(),
    );
  }
}

// ── Trading hours modal ──────────────────────────────────────────────────────

class _TradingHoursModal extends StatelessWidget {
  const _TradingHoursModal();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(22.w, 16.h, 22.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 18.h),
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('جدول أوقات التداول', style: AppTextStyles.h4),
              Text(
                'الثلاثاء، 27 مايو',
                style: AppTextStyles.caption.copyWith(color: AppColors.text3),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Colored segment bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: SizedBox(
              height: 10.h,
              child: Row(
                children: const [
                  _SegmentBar(flex: 20, color: Color(0xFFFF9800)),
                  _SegmentBar(flex: 35, color: Color(0xFF2ECC71)),
                  _SegmentBar(flex: 25, color: Color(0xFFFFC107)),
                  _SegmentBar(flex: 20, color: Color(0xFFEF5350)),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
          // Session rows
          _ThItem(
            dotColor: const Color(0xFFFF9800),
            label: 'ما قبل السوق',
            timeRange: '04:00 – 09:30 ص',
          ),
          _ThDivider(),
          _ThItem(
            dotColor: const Color(0xFF2ECC71),
            label: 'السوق مفتوح',
            timeRange: '09:30 ص – 04:00 م',
          ),
          _ThDivider(),
          _ThItem(
            dotColor: const Color(0xFFFFC107),
            label: 'ما بعد السوق',
            timeRange: '04:00 – 08:00 م',
          ),
          _ThDivider(),
          _ThItem(
            dotColor: const Color(0xFFEF5350),
            label: 'السوق مغلق',
            timeRange: '08:00 م – 04:00 ص',
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

class _SegmentBar extends StatelessWidget {
  const _SegmentBar({required this.flex, required this.color});
  final int flex;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: ColoredBox(color: color, child: const SizedBox.expand()),
    );
  }
}

class _ThItem extends StatelessWidget {
  const _ThItem({
    required this.dotColor,
    required this.label,
    required this.timeRange,
  });
  final Color dotColor;
  final String label;
  final String timeRange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 10.r,
            height: 10.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(label,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                )),
          ),
          Text(
            timeRange,
            style: AppTextStyles.monoSm.copyWith(
              color: AppColors.text2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: AppColors.border);
}
