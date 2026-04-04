import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/market_feed_cubit.dart';
import '../cubit/market_feed_state.dart';
import '../widgets/stock_tick_tile.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MarketFeedScreen  —  live real-time market feed
//
// Layout
// ──────
// ┌─────────────────────────────────┐
// │ AppBar: title + status dot      │
// ├─────────────────────────────────┤
// │ Stats bar: UPS · stocks · time  │
// ├─────────────────────────────────┤
// │ ListView (stable order)         │
// │  StockTickTile × N              │
// ├─────────────────────────────────┤
// │ (error overlay / connecting     │
// │  overlay when applicable)       │
// └─────────────────────────────────┘
//
// Performance
// ───────────
// • The ListView itself rebuilds only when [symbols] list changes (first time).
// • Each [StockTickTile] uses BlocSelector — rebuilds ONLY when its own tick
//   changes (see stock_tick_tile.dart for details).
// • [itemExtent] set so Flutter can skip layout for off-screen tiles.
// ─────────────────────────────────────────────────────────────────────────────

class MarketFeedScreen extends StatefulWidget {
  const MarketFeedScreen({super.key});

  @override
  State<MarketFeedScreen> createState() => _MarketFeedScreenState();
}

class _MarketFeedScreenState extends State<MarketFeedScreen> {
  // Server URL — use Mac's LAN IP so physical devices can reach the dev server.
  // localhost only works on emulators (use 10.0.2.2 for Android emulator).
  static const _wsUrl = 'ws://192.168.1.13:8080';

  @override
  void initState() {
    super.initState();
    // Defer until widget is mounted so context is valid.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketFeedCubit>().connectToFeed(wsUrl: _wsUrl);
    });
  }

  @override
  void dispose() {
    context.read<MarketFeedCubit>().disconnectFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    return Scaffold(
      backgroundColor: cs.bgPage,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Sticky app bar ──────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: cs.bgPage,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18.r, color: cs.text1),
              onPressed: () => context.pop(),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'السوق المباشر',
                  style: AppTextStyles.h3.copyWith(color: cs.text1),
                ),
                SizedBox(width: 10.w),
                BlocSelector<MarketFeedCubit, MarketFeedState, bool>(
                  selector: (s) => s is MarketFeedConnected,
                  builder: (_, connected) => _ConnectionDot(live: connected),
                ),
              ],
            ),
            centerTitle: false,
            actions: [
              // Retry button — shown only on error / disconnected states.
              BlocSelector<MarketFeedCubit, MarketFeedState, bool>(
                selector: (s) =>
                    s is MarketFeedError || s is MarketFeedDisconnected,
                builder: (ctx, showRetry) {
                  if (!showRetry) return const SizedBox.shrink();
                  return TextButton.icon(
                    onPressed: () =>
                        ctx.read<MarketFeedCubit>().connectToFeed(wsUrl: _wsUrl),
                    icon: Icon(Icons.refresh_rounded,
                        size: 16.r, color: AppColors.navy),
                    label: Text('إعادة',
                        style: AppTextStyles.labelSm
                            .copyWith(color: AppColors.navy)),
                  );
                },
              ),
              SizedBox(width: 8.w),
            ],
          ),

          // ── Stats bar ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: BlocBuilder<MarketFeedCubit, MarketFeedState>(
              buildWhen: (prev, curr) =>
                  (prev is MarketFeedConnected) !=
                      (curr is MarketFeedConnected) ||
                  (curr is MarketFeedConnected &&
                      prev is MarketFeedConnected &&
                      (curr.updatesPerSecond != prev.updatesPerSecond ||
                          curr.symbols.length != prev.symbols.length)),
              builder: (_, state) => _StatsBar(state: state),
            ),
          ),

          // ── Main content ───────────────────────────────────────────────
          BlocBuilder<MarketFeedCubit, MarketFeedState>(
            // Only rebuild the list scaffolding when symbols list changes.
            buildWhen: (prev, curr) {
              if (prev.runtimeType != curr.runtimeType) return true;
              if (curr is MarketFeedConnected && prev is MarketFeedConnected) {
                return curr.symbols.length != prev.symbols.length;
              }
              return true;
            },
            builder: (_, state) {
              if (state is MarketFeedInitial) {
                return const SliverFillRemaining(child: SizedBox.shrink());
              }
              if (state is MarketFeedConnecting) {
                return SliverFillRemaining(
                  child: _ConnectingPlaceholder(cs: cs),
                );
              }
              if (state is MarketFeedReconnecting) {
                return SliverFillRemaining(
                  child: _ReconnectingPlaceholder(state: state, cs: cs),
                );
              }
              if (state is MarketFeedError) {
                return SliverFillRemaining(
                  child: _ErrorPlaceholder(message: state.message, cs: cs),
                );
              }
              if (state is MarketFeedDisconnected) {
                return SliverFillRemaining(
                  child: _DisconnectedPlaceholder(cs: cs),
                );
              }

              final connected = state as MarketFeedConnected;
              return SliverList.builder(
                itemCount: connected.symbols.length + 1, // +1 for bottom pad
                itemBuilder: (_, i) {
                  if (i == connected.symbols.length) {
                    return SizedBox(height: 24.h);
                  }
                  return StockTickTile(symbol: connected.symbols[i]);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Connection status dot ─────────────────────────────────────────────────────
class _ConnectionDot extends StatelessWidget {
  const _ConnectionDot({required this.live});
  final bool live;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width:  8.r,
      height: 8.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: live ? AppColors.green : AppColors.red,
        boxShadow: live
            ? [BoxShadow(color: AppColors.green.withValues(alpha: 0.5), blurRadius: 6)]
            : [],
      ),
    );
  }
}

// ── Stats bar ─────────────────────────────────────────────────────────────────
class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.state});
  final MarketFeedState state;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;

    if (state is! MarketFeedConnected) {
      return Container(
        height: 36.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: cs.border),
        ),
      );
    }

    final s = state as MarketFeedConnected;
    final elapsed = DateTime.now().difference(s.connectedAt);
    final hh = elapsed.inHours.toString().padLeft(2, '0');
    final mm = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: cs.border),
      ),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.bolt_rounded,
            value: '${s.updatesPerSecond}',
            label: 'تحديث/ث',
            color: AppColors.gold,
          ),
          _divider(cs),
          _StatChip(
            icon: Icons.bar_chart_rounded,
            value: '${s.symbols.length}',
            label: 'سهم',
            color: AppColors.navy,
          ),
          _divider(cs),
          _StatChip(
            icon: Icons.timer_outlined,
            value: '$hh:$mm:$ss',
            label: 'وقت الاتصال',
            color: cs.text3,
          ),
          const Spacer(),
          _StatChip(
            icon: Icons.trending_up_rounded,
            value: '${s.totalUpdates}',
            label: 'إجمالي',
            color: AppColors.green,
          ),
        ],
      ),
    );
  }

  Widget _divider(AppColorSet cs) => Container(
        width: 1,
        height: 18.h,
        margin: EdgeInsets.symmetric(horizontal: 10.w),
        color: cs.divider,
      );
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.r, color: color),
        SizedBox(width: 4.w),
        Text(
          value,
          style: AppTextStyles.monoSm.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 11.sp,
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}

// ── Loading / error placeholders ──────────────────────────────────────────────
class _ConnectingPlaceholder extends StatelessWidget {
  const _ConnectingPlaceholder({required this.cs});
  final AppColorSet cs;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.navy,
            strokeWidth: 2.5,
          ),
          SizedBox(height: 16.h),
          Text('جارٍ الاتصال بالسوق…',
              style: AppTextStyles.bodyMd.copyWith(color: cs.text2)),
        ],
      ),
    );
  }
}

class _ReconnectingPlaceholder extends StatelessWidget {
  const _ReconnectingPlaceholder({
    required this.state,
    required this.cs,
  });
  final MarketFeedReconnecting state;
  final AppColorSet cs;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48.r, color: AppColors.gold),
          SizedBox(height: 16.h),
          Text(
            'إعادة الاتصال… (${state.attempt}/${state.maxAttempts})',
            style: AppTextStyles.bodyMd.copyWith(color: cs.text2),
          ),
        ],
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({required this.message, required this.cs});
  final String    message;
  final AppColorSet cs;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48.r, color: AppColors.red),
            SizedBox(height: 16.h),
            Text(message,
                style: AppTextStyles.bodyMd.copyWith(color: cs.text2),
                textAlign: TextAlign.center),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => context
                  .read<MarketFeedCubit>()
                  .connectToFeed(wsUrl: 'ws://localhost:8080'),
              icon: Icon(Icons.refresh_rounded, size: 16.r),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisconnectedPlaceholder extends StatelessWidget {
  const _DisconnectedPlaceholder({required this.cs});
  final AppColorSet cs;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 48.r, color: cs.text3),
          SizedBox(height: 16.h),
          Text('تم قطع الاتصال',
              style: AppTextStyles.bodyMd.copyWith(color: cs.text2)),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => context
                .read<MarketFeedCubit>()
                .connectToFeed(wsUrl: 'ws://localhost:8080'),
            icon: Icon(Icons.refresh_rounded, size: 16.r),
            label: const Text('اتصال'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
