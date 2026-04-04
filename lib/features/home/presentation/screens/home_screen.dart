import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common/app_loading_error.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/hero_portfolio_card.dart';
import '../widgets/murabaha_banner_widget.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/watchlist_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return switch (state) {
              HomeInitial() || HomeLoading() => const AppLoadingWidget(),
              HomeError(:final message) => AppErrorWidget(
                  message: message,
                  onRetry: () => context.read<HomeCubit>().refresh(),
                ),
              HomeLoaded(:final summary, :final watchlist) =>
                RefreshIndicator(
                  color: AppColors.navy,
                  onRefresh: () => context.read<HomeCubit>().refresh(),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 12.h),
                            _HomeHeader(
                              name: summary.userName,
                              initial: summary.userInitial,
                            ),
                            SizedBox(height: 16.h),
                            HeroPortfolioCard(summary: summary),
                            SizedBox(height: 16.h),
                            QuickActionsWidget(
                              onDeposit: () => context.push(AppRoutes.deposit),
                              onWithdraw: () => context.push(AppRoutes.deposit),
                              onOrders: () => context.push(AppRoutes.orders),
                              onStatement: () =>
                                  context.push(AppRoutes.statement),
                            ),
                            SizedBox(height: 14.h),
                            MurabahaBannerWidget(
                              onTap: () => context.go(AppRoutes.murabaha),
                            ),
                            SizedBox(height: 10.h),
                            _FeatureBanner(
                              icon: '📈',
                              title: 'الاستثمار الدوري (DCA)',
                              subtitle:
                                  'استثمر تلقائياً بمبلغ ثابت كل أسبوع أو شهر',
                              badge: 'جديد',
                              badgeColor: AppColors.gold,
                              badgeLite: AppColors.goldLite,
                              onTap: () => context.push(AppRoutes.dca),
                            ),
                            SizedBox(height: 10.h),
                            _FeatureBanner(
                              icon: '🔔',
                              title: 'تنبيهات الأسعار',
                              subtitle:
                                  'احصل على تنبيه فور وصول السهم لسعرك المستهدف',
                              badge: 'نشط',
                              badgeColor: AppColors.green,
                              badgeLite: AppColors.greenLite,
                              onTap: () => context.push(AppRoutes.priceAlerts),
                            ),
                            SizedBox(height: 4.h),
                            WatchlistSection(
                              items: watchlist,
                              onViewAll: () => context.go(AppRoutes.markets),
                              onItemTap: (item) => context.push(
                                AppRoutes.tradeRoute(item.symbol),
                              ),
                            ),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            };
          },
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.name, required this.initial});

  final String name;
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.navyGlow,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً بعودتك 👋',
                    style: AppTextStyles.caption,
                  ),
                  Text(
                    name,
                    style: AppTextStyles.h4,
                  ),
                ],
              ),
            ],
          ),
          // Notification bell
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
              boxShadow: AppShadows.sm,
            ),
            alignment: Alignment.center,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Text('🔔', style: TextStyle(fontSize: 16.sp)),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Feature banner card ──────────────────────────────────────────────────────────
class _FeatureBanner extends StatelessWidget {
  const _FeatureBanner({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.badgeLite,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final Color badgeLite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 22.w),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: badgeLite,
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: Text(icon, style: TextStyle(fontSize: 22.sp)),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.labelMd
                          .copyWith(color: AppColors.text1)),
                  SizedBox(height: 2.h),
                  Text(subtitle,
                      style:
                          AppTextStyles.caption.copyWith(color: AppColors.text3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: badgeLite,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                    color: badgeColor.withValues(alpha: 0.2)),
              ),
              child: Text(badge,
                  style: AppTextStyles.caption.copyWith(
                      color: badgeColor,
                      fontWeight: FontWeight.w700)),
            ),
            SizedBox(width: 6.w),
            Icon(Icons.chevron_left_rounded,
                color: AppColors.text3, size: 18.r),
          ],
        ),
      ),
    );
  }
}
