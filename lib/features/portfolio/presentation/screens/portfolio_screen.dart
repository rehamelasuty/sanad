import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common/app_loading_error.dart';
import '../../../../core/widgets/common/price_change_badge.dart';
import '../../../../core/widgets/common/sharia_badge.dart';
import '../../domain/entities/asset_allocation.dart';
import '../../domain/entities/portfolio_holding.dart';
import '../cubit/portfolio_cubit.dart';
import '../cubit/portfolio_state.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PortfolioCubit>()..loadPortfolio(),
      child: const _PortfolioView(),
    );
  }
}

class _PortfolioView extends StatelessWidget {
  const _PortfolioView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: BlocBuilder<PortfolioCubit, PortfolioState>(
        builder: (context, state) => switch (state) {
          PortfolioInitial() || PortfolioLoading() =>
            const Center(child: AppLoadingWidget()),
          PortfolioError(:final message) => Center(
              child: AppErrorWidget(
                message: message,
                onRetry: () => context.read<PortfolioCubit>().loadPortfolio(),
              ),
            ),
          PortfolioLoaded() => _PortfolioContent(state: state),
        },
      ),
    );
  }
}

class _PortfolioContent extends StatelessWidget {
  const _PortfolioContent({required this.state});

  final PortfolioLoaded state;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.green,
      onRefresh: () => context.read<PortfolioCubit>().refresh(),
      child: CustomScrollView(
        slivers: [
          _PortfolioAppBar(
            hideValues: state.hideValues,
            onToggleHide: () =>
                context.read<PortfolioCubit>().toggleHideValues(),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                _SummaryCard(state: state),
                SizedBox(height: 20.h),
                _AllocationPieCard(
                  allocations: state.allocations,
                  hideValues: state.hideValues,
                ),
                SizedBox(height: 20.h),
                _HoldingsHeader(currentSort: state.sortOrder),
                SizedBox(height: 8.h),
                ...state.sortedHoldings.map(
                  (h) => _HoldingTile(
                    holding: h,
                    hideValues: state.hideValues,
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioAppBar extends StatelessWidget {
  const _PortfolioAppBar({
    required this.hideValues,
    required this.onToggleHide,
  });

  final bool hideValues;
  final VoidCallback onToggleHide;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.bgApp,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      title: Text('محفظتي', style: AppTextStyles.h3),
      centerTitle: false,
      actions: [
        IconButton(
          icon: Icon(
            hideValues
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 22.r,
            color: AppColors.text2,
          ),
          onPressed: onToggleHide,
        ),
        SizedBox(width: 8.w),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.state});

  final PortfolioLoaded state;

  @override
  Widget build(BuildContext context) {
    final isProfit = state.totalReturn >= 0;
    final sign = isProfit ? '+' : '';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 22.w),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: AppRadius.lgAll,
        boxShadow: AppShadows.greenGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إجمالي المحفظة',
            style: AppTextStyles.labelMd.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            state.hideValues
                ? '•••••• ر.س'
                : '${state.totalMarketValue.toStringAsFixed(2)} ر.س',
            style: AppTextStyles.priceDisplay.copyWith(color: Colors.white),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isProfit
                      ? Colors.white.withValues(alpha: 0.18)
                      : AppColors.red.withValues(alpha: 0.3),
                  borderRadius: AppRadius.fullAll,
                ),
                child: Text(
                  state.hideValues
                      ? '•••'
                      : '$sign${state.totalReturn.toStringAsFixed(2)} ($sign${state.totalReturnPercent.toStringAsFixed(2)}%)',
                  style: AppTextStyles.monoSm.copyWith(
                    color: isProfit
                        ? Colors.white
                        : const Color(0xFFFFCDD2),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AllocationPieCard extends StatelessWidget {
  const _AllocationPieCard({
    required this.allocations,
    required this.hideValues,
  });

  final List<AssetAllocation> allocations;
  final bool hideValues;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 22.w),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.mdAll,
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('توزيع الأصول', style: AppTextStyles.h4),
          SizedBox(height: 16.h),
          Row(
            children: [
              SizedBox(
                width: 110.r,
                height: 110.r,
                child: PieChart(
                  PieChartData(
                    sections: allocations
                        .map(
                          (a) => PieChartSectionData(
                            value: a.percentage,
                            color: a.color,
                            radius: 36.r,
                            title: '${a.percentage.toStringAsFixed(0)}%',
                            titleStyle: AppTextStyles.badgeSm.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                        .toList(),
                    centerSpaceRadius: 28.r,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: allocations.map((a) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          Container(
                            width: 10.r,
                            height: 10.r,
                            decoration: BoxDecoration(
                              color: a.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(a.label, style: AppTextStyles.bodyMd),
                          ),
                          Text(
                            hideValues
                                ? '•••'
                                : '${a.value.toStringAsFixed(0)} ر.س',
                            style: AppTextStyles.monoSm.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.text1,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HoldingsHeader extends StatelessWidget {
  const _HoldingsHeader({required this.currentSort});

  final HoldingSortOrder currentSort;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('الأوراق المالية', style: AppTextStyles.h4),
          DropdownButtonHideUnderline(
            child: DropdownButton<HoldingSortOrder>(
              value: currentSort,
              style: AppTextStyles.labelMd.copyWith(color: AppColors.green),
              icon: Icon(
                Icons.sort_rounded,
                size: 18.r,
                color: AppColors.green,
              ),
              items: HoldingSortOrder.values
                  .map(
                    (o) => DropdownMenuItem(
                      value: o,
                      child: Text(o.label),
                    ),
                  )
                  .toList(),
              onChanged: (o) {
                if (o != null) {
                  context.read<PortfolioCubit>().changeSortOrder(o);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HoldingTile extends StatelessWidget {
  const _HoldingTile({required this.holding, required this.hideValues});

  final PortfolioHolding holding;
  final bool hideValues;

  @override
  Widget build(BuildContext context) {
    final logoColor = Color(holding.logoColor ?? AppColors.green.toARGB32());

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 5.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.smAll,
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: logoColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              holding.symbol.substring(0, 1),
              style: AppTextStyles.h4.copyWith(color: logoColor),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        holding.name,
                        style: AppTextStyles.h4,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (holding.isShariaCompliant) const ShariaBadge(),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  hideValues
                      ? '${holding.quantity.toInt()} سهم'
                      : '${holding.quantity.toInt()} سهم · متوسط ${holding.averageCost.toStringAsFixed(2)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hideValues
                    ? '••••'
                    : holding.marketValue.toStringAsFixed(2),
                style: AppTextStyles.monoSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text1,
                ),
              ),
              SizedBox(height: 4.h),
              PriceChangeBadge(
                value: hideValues ? 0 : holding.totalReturnPercent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
