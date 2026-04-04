import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common/app_loading_error.dart';
import '../../../../core/widgets/common/section_header.dart';
import '../../../../core/widgets/common/stock_list_tile.dart';
import '../bloc/markets_bloc.dart';
import '../bloc/markets_event.dart';
import '../bloc/markets_state.dart';
import '../widgets/filter_pills_row.dart';
import '../widgets/index_cards_row.dart';
import '../widgets/market_mini_chart.dart';
import '../widgets/markets_search_box.dart';
import '../widgets/session_status_bar.dart';

class MarketsScreen extends StatelessWidget {
  const MarketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: BlocBuilder<MarketsBloc, MarketsState>(
          builder: (context, state) {
            return switch (state) {
              MarketsInitial() || MarketsLoading() =>
                const AppLoadingWidget(),
              MarketsError(:final message) => AppErrorWidget(
                  message: message,
                  onRetry: () => context
                      .read<MarketsBloc>()
                      .add(const MarketsLoadRequested()),
                ),
              MarketsLoaded() => _MarketsBody(state: state),
            };
          },
        ),
      ),
    );
  }
}

class _MarketsBody extends StatelessWidget {
  const _MarketsBody({required this.state});

  final MarketsLoaded state;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.green,
      onRefresh: () async =>
          context.read<MarketsBloc>().add(const MarketsRefreshRequested()),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MarketsHeader(),
                SizedBox(height: 12.h),
                MarketsSearchBox(
                  onChanged: (q) => context
                      .read<MarketsBloc>()
                      .add(MarketsSearchChanged(q)),
                ),
                SizedBox(height: 12.h),
                // Popular stocks horizontal scroll
                _PopularScrollRow(stocks: state.filteredStocks),
                SizedBox(height: 4.h),
                IndexCardsRow(indices: state.indices),
                SizedBox(height: 4.h),
                const MarketMiniChart(),
                SizedBox(height: 4.h),
                // Exchange tab row (US / Saudi)
                _ExchangeTabRow(
                  activeFilter: state.activeFilter,
                  onFilterChanged: (cat) => context
                      .read<MarketsBloc>()
                      .add(MarketsFilterChanged(cat)),
                ),
                FilterPillsRow(
                  activeFilter: state.activeFilter,
                  onFilterChanged: (cat) => context
                      .read<MarketsBloc>()
                      .add(MarketsFilterChanged(cat)),
                ),
                const SessionStatusBar(),
                SizedBox(height: 4.h),
                SectionHeader(
                  title: 'الأكثر ارتفاعاً',
                  actionLabel: 'عرض الكل ←',
                  onAction: () {},
                ),
                ...state.filteredStocks.asMap().entries.map((entry) {
                  final i = entry.key;
                  final stock = entry.value;
                  return StockListTile(
                    symbol: stock.symbol,
                    name: stock.name,
                    exchange: stock.exchange,
                    price: stock.price,
                    changePercent: stock.changePercent,
                    sparklineData: stock.sparklineData,
                    currency: stock.currency,
                    isShariaCompliant: stock.isShariaCompliant,
                    logoColor: stock.logoColor,
                    isLast: i == state.filteredStocks.length - 1,
                    onTap: () =>
                        context.push(AppRoutes.tradeRoute(stock.symbol)),
                  );
                }),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 14.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('الأسواق', style: AppTextStyles.h1),
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: Text('⚙', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }
}

// ── Popular horizontal scroll ────────────────────────────────────────────────

class _PopularScrollRow extends StatelessWidget {
  const _PopularScrollRow({required this.stocks});

  final List<dynamic> stocks;

  @override
  Widget build(BuildContext context) {
    if (stocks.isEmpty) return const SizedBox.shrink();
    final popular = stocks.take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          child: Text('الأكثر شعبية', style: AppTextStyles.labelLg),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 100.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 22.w),
            itemCount: popular.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, i) {
              final stock = popular[i];
              final isPositive = (stock.changePercent) >= 0;
              return GestureDetector(
                onTap: () =>
                    context.push(AppRoutes.tradeRoute(stock.symbol)),
                child: Container(
                  width: 120.w,
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28.r,
                            height: 28.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: stock.logoColor != null
                                  ? Color(stock.logoColor!).withValues(alpha: 0.15)
                                  : AppColors.greenLite,
                            ),
                            child: Center(
                              child: Text(
                                stock.symbol.length > 2
                                    ? stock.symbol.substring(0, 2)
                                    : stock.symbol,
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 8.sp,
                                  color: stock.logoColor != null
                                      ? Color(stock.logoColor!)
                                      : AppColors.green,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 6.r,
                            height: 6.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isPositive ? AppColors.green : AppColors.red,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stock.symbol,
                            style: AppTextStyles.labelMd.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${stock.currency == 'SAR' ? '﷼' : '\$'} ${stock.price.toStringAsFixed(2)}',
                            style: AppTextStyles.monoSm.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.text1,
                            ),
                          ),
                          Text(
                            '${isPositive ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 10.sp,
                              color: isPositive ? AppColors.green : AppColors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}

// ── Exchange tab row ─────────────────────────────────────────────────────────

class _ExchangeTabRow extends StatelessWidget {
  const _ExchangeTabRow({
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ('saudi', '🇸🇦', 'السوق السعودي'),
      ('us', '🇺🇸', 'السوق الأمريكي'),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Row(
        children: tabs.map((tab) {
          final key = tab.$1;
          final flag = tab.$2;
          final label = tab.$3;
          final isActive = activeFilter == key;
          return Expanded(
            child: GestureDetector(
              onTap: () => onFilterChanged(key),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? AppColors.green : AppColors.border,
                      width: isActive ? 2.0 : 1.0,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(flag, style: TextStyle(fontSize: 14.sp)),
                    SizedBox(width: 6.w),
                    Text(
                      label,
                      style: AppTextStyles.labelMd.copyWith(
                        color: isActive ? AppColors.text1 : AppColors.text3,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
