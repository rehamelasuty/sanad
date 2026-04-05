import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../market_feed/domain/entities/market_tick.dart';
import '../../../market_feed/presentation/cubit/market_feed_cubit.dart';
import '../../../market_feed/presentation/cubit/market_feed_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

const _kWsUrl = 'ws://192.168.1.13:8080';

bool _isSaudiSymbol(String s) => RegExp(r'^\d{4}$').hasMatch(s);

bool _isSaudiOpen() {
  final now = DateTime.now().toUtc().add(const Duration(hours: 3));
  final mins = now.hour * 60 + now.minute;
  final isDay = (now.weekday >= 1 && now.weekday <= 4) || now.weekday == 7;
  return isDay && mins >= 600 && mins < 900;
}

bool _isUSOpen() {
  final now = DateTime.now().toUtc().subtract(const Duration(hours: 4));
  final mins = now.hour * 60 + now.minute;
  return now.weekday >= 1 && now.weekday <= 5 && mins >= 570 && mins < 960;
}

const _kLogoColors = <Color>[
  Color(0xFF1A7C5E),
  Color(0xFF1B4FA8),
  Color(0xFFC9322A),
  Color(0xFFC9922A),
  Color(0xFF5E348B),
  Color(0xFF0D6E8C),
  Color(0xFF2E7D32),
  Color(0xFF8D1F8D),
];

Color _logoColor(String symbol) =>
    _kLogoColors[symbol.hashCode.abs() % _kLogoColors.length];

String _shortLabel(String s) => s.length > 4 ? s.substring(0, 4) : s;

// ─────────────────────────────────────────────────────────────────────────────
// Root screen
// ─────────────────────────────────────────────────────────────────────────────

class InvestmentsStocksScreen extends StatefulWidget {
  const InvestmentsStocksScreen({super.key});

  @override
  State<InvestmentsStocksScreen> createState() =>
      _InvestmentsStocksScreenState();
}

class _InvestmentsStocksScreenState extends State<InvestmentsStocksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MarketFeedCubit>().connectToFeed(wsUrl: _kWsUrl);
      }
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _StocksAppBar(),
            const _SearchBar(),
            _MarketTabBar(controller: _tab),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: ColoredBox(
                color: AppColors.bgPage,
                child: TabBarView(
                  controller: _tab,
                  children: const [
                    _MarketContent(isSaudi: true),
                    _MarketContent(isSaudi: false),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App bar
// ─────────────────────────────────────────────────────────────────────────────

class _StocksAppBar extends StatelessWidget {
  const _StocksAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      // RTL Row: first child → rightmost, last → leftmost
      // Visual L→R: person | bell | bookmark  …  الأسهم
      child: Row(
        children: [
          Text('الأسهم', style: AppTextStyles.h2),
          const Spacer(),
          _NotifIcon(icon: Icons.bookmarks_outlined, hasBadge: false),
          SizedBox(width: 4.w),
          _NotifIcon(icon: Icons.notifications_outlined, hasBadge: true),
          SizedBox(width: 4.w),
          _NotifIcon(icon: Icons.person_outline_rounded, hasBadge: true),
        ],
      ),
    );
  }
}

class _NotifIcon extends StatelessWidget {
  const _NotifIcon({required this.icon, required this.hasBadge});
  final IconData icon;
  final bool hasBadge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34.w,
      height: 34.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, size: 24.sp, color: AppColors.text1),
          if (hasBadge)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search bar
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.stockSearch),
      child: Container(
        color: AppColors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: AppColors.bgPage,
            borderRadius: AppRadius.fullAll,
          ),
          child: Row(
            children: [
              SizedBox(width: 12.w),
              Icon(Icons.search_rounded, color: AppColors.text3, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'جرب البحث الذكي',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.text3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Market tab bar
// ─────────────────────────────────────────────────────────────────────────────

class _MarketTabBar extends StatelessWidget {
  const _MarketTabBar({required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final saudiOpen = _isSaudiOpen();
    final usOpen = _isUSOpen();

    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: controller,
        labelColor: AppColors.navy,
        unselectedLabelColor: AppColors.text3,
        indicatorColor: AppColors.navy,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: AppTextStyles.labelLg,
        unselectedLabelStyle: AppTextStyles.bodyMd,
        tabs: [
          Tab(
            child: _MarketTabLabel(
              flag: '🇸🇦',
              name: 'السوق السعودي',
              isOpen: saudiOpen,
            ),
          ),
          Tab(
            child: _MarketTabLabel(
              flag: '🇺🇸',
              name: 'السوق الأمريكي',
              isOpen: usOpen,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketTabLabel extends StatelessWidget {
  const _MarketTabLabel({
    required this.flag,
    required this.name,
    required this.isOpen,
  });
  final String flag, name;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final dotColor = isOpen ? AppColors.green : AppColors.red;
    // RTL Row → first = rightmost
    // Visual L→R:  [مفتوح][●][🇸🇦]  السوق السعودي
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(name),
        SizedBox(width: 6.w),
        Text(flag, style: const TextStyle(fontSize: 15)),
        SizedBox(width: 5.w),
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        if (isOpen) ...[
          SizedBox(width: 4.w),
          Text(
            'مفتوح',
            style: AppTextStyles.caption.copyWith(color: AppColors.green),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Market content tab
// ─────────────────────────────────────────────────────────────────────────────

class _MarketContent extends StatelessWidget {
  const _MarketContent({required this.isSaudi});
  final bool isSaudi;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketFeedCubit, MarketFeedState>(
      // Rebuild the list SKELETON only when symbols list changes (first batch).
      // Individual rows react via BlocSelector inside _DiscoverRowLive.
      buildWhen: (prev, next) {
        if (prev.runtimeType != next.runtimeType) return true;
        if (prev is MarketFeedConnected && next is MarketFeedConnected) {
          return prev.symbols != next.symbols;
        }
        return true;
      },
      builder: (context, state) {
        if (state is MarketFeedInitial || state is MarketFeedConnecting) {
          return const _LoadingState();
        }
        if (state is MarketFeedReconnecting) {
          return const _LoadingState(label: 'جارٍ إعادة الاتصال…');
        }
        if (state is MarketFeedError) {
          return _ErrorState(
            message: state.message,
            onRetry: () =>
                context.read<MarketFeedCubit>().connectToFeed(wsUrl: _kWsUrl),
          );
        }
        if (state is MarketFeedConnected) {
          final symbols = state.symbols
              .where((s) =>
                  isSaudi ? _isSaudiSymbol(s) : !_isSaudiSymbol(s))
              .toList();

          if (symbols.isEmpty) return const _EmptyState();

          final trendingSymbols = symbols.take(8).toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: 4.h)),

              // ── Trending ────────────────────────────────────
              SliverToBoxAdapter(
                child: _SectionHeader(
                    title: 'الشائع', onViewAll: () {}),
              ),
              SliverToBoxAdapter(
                child: _TrendingScrollView(symbols: trendingSymbols),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 8.h)),

              // ── Discover ────────────────────────────────────
              SliverToBoxAdapter(
                child: _SectionHeader(
                    title: 'استكشف الأسهم', onViewAll: () {}),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.white,
                  child: Column(
                    children: [
                      for (int i = 0; i < symbols.length; i++) ...[
                        _DiscoverRowLive(symbol: symbols[i]),
                        if (i < symbols.length - 1)
                          Divider(
                            height: 1,
                            indent: 68.w,
                            endIndent: 16.w,
                            color: AppColors.border,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 24.h)),
            ],
          );
        }
        return const _EmptyState();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onViewAll});
  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    // RTL spaceBetween → title RIGHT, "عرض الكل" LEFT
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.sectionTitle),
          GestureDetector(
            onTap: onViewAll,
            child: Row(
              children: [
                Text('عرض الكل', style: AppTextStyles.sectionAction),
                SizedBox(width: 2.w),
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 11.sp,
                  color: AppColors.navy,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trending cards
// ─────────────────────────────────────────────────────────────────────────────

class _TrendingScrollView extends StatelessWidget {
  const _TrendingScrollView({required this.symbols});
  final List<String> symbols;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 158.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: symbols.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (_, i) => _TrendingCardLive(symbol: symbols[i]),
      ),
    );
  }
}

class _TrendingCardLive extends StatelessWidget {
  const _TrendingCardLive({required this.symbol});
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MarketFeedCubit, MarketFeedState, MarketTick?>(
      selector: (state) =>
          state is MarketFeedConnected ? state.tickMap[symbol] : null,
      builder: (_, tick) {
        if (tick == null) return SizedBox(width: 130.w);
        return GestureDetector(
          onTap: () => context.push(AppRoutes.tradeRoute(symbol)),
          child: _TrendingCard(tick: tick),
        );
      },
    );
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({required this.tick});
  final MarketTick tick;

  static final _fmt = NumberFormat('#,##0.##');

  @override
  Widget build(BuildContext context) {
    final isUp = tick.change >= 0;
    final color = isUp ? AppColors.green : AppColors.red;
    final sign = isUp ? '+' : '';

    return Container(
      width: 130.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.mdAll,
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LogoBadge(symbol: tick.symbol, size: 42),
          SizedBox(height: 8.h),
          Text(
            _shortLabel(tick.symbol),
            style: AppTextStyles.labelLg,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 3.h),
          Text(
            '﷼ ${_fmt.format(tick.price)}',
            style: AppTextStyles.holdingPrice,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          Text(
            '$sign${_fmt.format(tick.change)} ($sign${tick.changePercent.toStringAsFixed(2)}%)',
            style: AppTextStyles.badgeSm.copyWith(color: color),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Discover list row
// ─────────────────────────────────────────────────────────────────────────────

class _DiscoverRowLive extends StatelessWidget {
  const _DiscoverRowLive({required this.symbol});
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MarketFeedCubit, MarketFeedState, MarketTick?>(
      selector: (state) =>
          state is MarketFeedConnected ? state.tickMap[symbol] : null,
      builder: (_, tick) {
        if (tick == null) return const SizedBox.shrink();
        return InkWell(
          onTap: () => context.push(AppRoutes.tradeRoute(symbol)),
          child: _DiscoverRow(tick: tick),
        );
      },
    );
  }
}

class _DiscoverRow extends StatelessWidget {
  const _DiscoverRow({required this.tick});
  final MarketTick tick;

  static final _fmt = NumberFormat('#,##0.##');

  @override
  Widget build(BuildContext context) {
    final isUp = tick.change >= 0;
    final color = isUp ? AppColors.green : AppColors.red;
    final sign = isUp ? '+' : '';

    // RTL Row: first child = rightmost (logo), last = leftmost (price)
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
      child: Row(
        children: [
          // ① Logo — rightmost in RTL
          _LogoBadge(symbol: tick.symbol, size: 40),
          SizedBox(width: 10.w),

          // ② Symbol + company name
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // start = RIGHT in RTL ✓
              children: [
                Text(
                  _shortLabel(tick.symbol),
                  style: AppTextStyles.bodyLg,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  tick.name,
                  style: AppTextStyles.labelSm,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          // ③ Price + change — leftmost in RTL
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end, // end = LEFT in RTL ✓
            children: [
              Text(
                '﷼ ${_fmt.format(tick.price)}',
                style: AppTextStyles.holdingPrice,
              ),
              SizedBox(height: 2.h),
              Text(
                '$sign${_fmt.format(tick.change)} ($sign${tick.changePercent.toStringAsFixed(2)}%)',
                style: AppTextStyles.priceSm.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared logo badge
// ─────────────────────────────────────────────────────────────────────────────

class _LogoBadge extends StatelessWidget {
  const _LogoBadge({required this.symbol, required this.size});
  final String symbol;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = _logoColor(symbol);
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        _shortLabel(symbol),
        style: TextStyle(
          fontSize: (size * 0.21).sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.clip,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// State overlays
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState({this.label = 'جارٍ الاتصال بالسوق…'});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.navy,
            strokeWidth: 2.5,
          ),
          SizedBox(height: 16.h),
          Text(label,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.text2)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 44.sp, color: AppColors.text3),
            SizedBox(height: 12.h),
            Text(
              message,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: AppRadius.smAll,
                ),
                child:
                    Text('أعد المحاولة', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.show_chart, size: 44.sp, color: AppColors.text4),
          SizedBox(height: 12.h),
          Text(
            'لا توجد بيانات للسوق',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.text3),
          ),
        ],
      ),
    );
  }
}
