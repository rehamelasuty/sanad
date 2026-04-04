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
                  color: AppColors.green,
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
                              onDeposit: () {},
                              onWithdraw: () {},
                              onOrders: () {},
                              onStatement: () {},
                            ),
                            SizedBox(height: 14.h),
                            MurabahaBannerWidget(
                              onTap: () => context.go(AppRoutes.murabaha),
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
                      color: AppColors.greenGlow,
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
                      color: AppColors.green,
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
